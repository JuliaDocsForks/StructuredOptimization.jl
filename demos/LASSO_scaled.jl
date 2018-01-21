
using RegLS
using BenchmarkTools
using PyCall
using JuMP
using SCS
using Mosek
using ECOS

@pyimport cvxpy as cvx
@pyimport scipy.sparse as sp

# currently PyCall converts sparse matrices into full ones 
PyObject(S::SparseMatrixCSC) = sp.csc_matrix((S.nzval, S.rowval .- 1, S.colptr .- 1), shape=size(S))

function set_up(S::Int) #S scales problem

	n = S
	m = div(S,4)
	SNR = 10

	srand(123)

	A = sprandn(n,m,2/n)
	x0 = zeros(m)
	x0[randperm(m)[1:div(m,4)+1]] = randn(div(m,4)+1)
	x0 /= norm(x0)^2

	y = A*x0
	y += 10^(-SNR/10)*sqrt(var(y))*randn(length(y))
	lambda = 0.01*norm(A'*y,Inf) 
	x = RegLS.Variable(m)
	@minimize ls(A*x-y)+lambda*norm(x,1) with ZeroFPR(verbose = 0, tol =1e-12) 
	setup = A, y, lambda, m
	x1 = ~x
	return ~x, setup
end


function solve_problem(slv::S, A, y, lambda, m) where {S <: RegLS.ForwardBackwardSolver}
	x = RegLS.Variable(m)
	slv = @minimize ls(A*x-y)+lambda*norm(x,1) with slv
	return ~x, slv.it
end

function solve_problem(slv::S, A, y, lambda, m) where {S <: MathProgBase.SolverInterface.AbstractMathProgSolver}
	M = Model(solver = slv)
	@variables M begin
		x[1:m]
		t[1:m]
		w
	end
	@objective(M,Min,[0.5;lambda*ones(m)]'*[w;t])
	@constraint(M, soc, norm( [1-w;2*(A*x-y)] ) <= 1+w)
	@constraint(M,  x .<= t)
	@constraint(M, -t .<= x)

	solve(M)
	return getvalue(x), 0
end

#cvxpy
function solve_problem(slv::S, A, y, lambda, m) where {S <: AbstractString}
	x = cvx.Variable(m)
	problem = cvx.Problem(cvx.Minimize(cvx.sum_squares(PyObject(A)*x-y)*0.5+cvx.norm1(x)*lambda))
	problem[:solve](solver = slv, verbose = false)
	return x[:value], 0
end

function benchmark_LASSO()
	suite = BenchmarkGroup()

	verbose, samples, seconds = 0, 7, 1e4

	solvers = [
		   "ECOSSolver",
		   "SCSSolver", 
		   "PG", 
		   "FPG", 
		   "ZeroFPR", 
		   ]
	slv_opt = ["(verbose = $verbose, maxit     = 100000000)", 
		   "(verbose = $verbose, max_iters = 100000000)", 
		   "(verbose = $verbose, maxit     = 100000000)", 
		   "(verbose = $verbose, maxit     = 100000000)", 
		   "(verbose = $verbose, maxit     = 100000000)"]
	iterations = Dict([(sol,0) for sol in solvers]) 
	nvar =  [100;1000;10000;100000;1000000]
#	nvar =  [100;1000;10000]
	err = Dict((n,Dict([(sol,0.) for sol in solvers])) for n in nvar) 
	its = Dict((n,Dict([(sol,0.) for sol in solvers])) for n in nvar) 

	for ii in nvar 
		suite[ii] = BenchmarkGroup()
		xopt, setup = set_up(ii)
		for i in eachindex(solvers)
			solver = eval(parse(solvers[i]*slv_opt[i]))

			suite[ii][solvers[i]] = 
			@benchmarkable((x,it) = solve_problem(solver, setup...), 
				       setup = (setup  = deepcopy($setup); 
						solver = deepcopy($solver);
						x = nothing;
						it = 0;
						), 
				       teardown = (
						   $err[$ii][$solvers[$i]] = norm(x-$xopt);
						   $its[$ii][$solvers[$i]] = it;
						   ), 
				       evals = 1, samples = samples, seconds = seconds)
		end

	end

	benchmarks = run(suite)

	return benchmarks, solvers, err, its, nvar
end
BLAS.set_num_threads(3)

benchmarks, solvers, err, its, nvar = benchmark_LASSO()

println("\n")
showall(median(benchmarks))
println("\n")

#using PyPlot
#figure()
#for slv in solvers
#	semilogx(nvar,[10*log10(time(median(benchmarks[i][slv]))) for i in nvar], label = slv)
#end
#legend()

import BenchmarkTools:prettytime


tab = "\\midrule \n"
for i in nvar
	tab *= "\\multirow{2}{*}{ \$ n = 10^$(Int(log10(i))) \$ } & "
	tab *= "\$ t \$ "
	for slv in solvers 
		tab *= "&  $(prettytime(time(median(benchmarks[i][slv]))))  "
	end
	tab *= "\\\\ \n\\cmidrule(lr){2-7}\n                                & \$ k \$ " 
	for slv in solvers 
		tab *= "& $(Int(its[i][slv])) "
	end
	tab *= "\\\\ \n \\midrule \n" 
end

tab = replace(tab, "μ", "\$\\mu\$")
println(tab)

















