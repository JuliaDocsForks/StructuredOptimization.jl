abstract Solver
abstract ForwardBackwardSolver <: Solver

export
  PG,
  FPG,
  ZeroFPR

include("solvers/pg.jl")
include("solvers/zerofpr.jl")

include("solvers/utils.jl")

# To print out solver objects

function Base.show(io::IO, slv::ForwardBackwardSolver)
	println(io, fun_name(slv) )
	println(io, "iterations : $(slv.it) / $(slv.maxit)")
	println(io, "fpr        : $(slv.normfpr)")
	println(io, "cost       : $(slv.cost)")
	println(io, "γ          : $(slv.gamma)")
	println(io, "time       : $(slv.time)")
	println(io, "prox   eval: $(slv.cnt_prox)")
	println(io, "matvec eval: $(slv.cnt_matvec)")
end

export solve, solve!

solve(A::AbstractArray, b::AbstractArray, g::ProximableFunction) =
solve(A, b, g, zeros(eltype(b), size(A,2)))

solve(A::AbstractArray, b::AbstractArray, g::ProximableFunction, x0::AbstractArray) = 
solve(A, b, g, x0, ZeroFPR() )

function solve(A::AbstractArray, b::AbstractArray, g::ProximableFunction, x0::AbstractArray, args...) 
	x = OptVar(deepcopy(x0))
	L = A*x+b
	solve(L, g, args...)
end

#
## when linear operator is composed with g (instead of the least squares term)
## then matrix/linear operator arguments is passed after g in the arguments list
## in this case the dual problem is solved, then the primal solution is recovered
#
function solve(b::AbstractArray, g::ProximableFunction, A::AbstractArray, args...)
	y, slv = solve(A', b, Conjugate(g), args...)
	return -A'*y+b, slv, y
end
#new solvers
function solve{T <: AffineOperator, S<:Solver}(A::T, g::ProximableFunction, slv::S)
	x0 = copy(optArray(A))
	slv2 = copy(slv) 
	x, slv2 = solve!(A, g, slv2)
	x_out = copy(x)
	optArray!(A,x0)
	return x_out, slv2
end

solve!{T <: AffineOperator}(A::T, args...) = solve!(optArray(A), A, args...)

