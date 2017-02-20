type PG <: ForwardBackwardSolver
	tol::Float64
	maxit::Int64
	verbose::Int64
	halt::Function
	gamma::Float64
	it::Int
	normfpr::Float64
	cost::Float64
	time::Float64
	linesearch::Bool
	fast::Bool
	name::AbstractString
	cnt_matvec::Int
	cnt_prox::Int
end

"""
# Proximal Gradient Solver

## Usage


* `slv = PG()` creates a `Solver` object that can be used in the function `solve`.
* Can be used with convex regularizers only.
* After solving a problem use `show(slv)` to visualize number of iterations, fixed point residual value, cost funtion value and time elapsed.


## Keyword Arguments

* `tol::Float64=1e-8`: tolerance
* `maxit::Int64=10000`: maximum number of iterations
* `verbose::Int64=1`: `0` verbose off, `1` print every 100 iteration, `2` print every iteration
* `halt::Function`: custom stopping criterion function
  * this function may be specified by the user and must have the following structure:

    `myhalt(slv::ForwardBackwardSolver,normfpr0::Float64,Fcurr::Float64,Fprev::Float64)`

    * `normfpr0` is the fixed point residual at x0
    * `Fcurr` is the objective value at the current iteration
    * `Fprev` is the objective value at the previous iteration
    * example: `myhalt(slv,normfpr0,FBE,FBEx) = slv.normfpr < tol`

* `gamma::Float64=Inf`: stepsize γ, if γ = Inf upper bound is computed using:

  γ = || x0-(x0+ɛ) || / || ∇f(x0) - ∇f(x0+ɛ) ||

* `linesearch::Bool=true`: activates linesearch on stepsize γ
* `fast::Bool=true`: switches between proximal gradient and fast proximal gradient
"""

PG(; tol::Float64 = 1e-8,
      maxit::Int64 = 10000,
      verbose::Int64 = 1,
      halt::Function = halt_default,
      linesearch::Bool = true,
			fast::Bool = false,
      gamma::Float64 = Inf) =
	PG(tol, maxit, verbose, halt, gamma,  0, Inf, Inf, NaN, linesearch, fast, fast ? "Fast Proximal Gradient" : "Proximal Gradient", 0, 0)

# alias for fast = true
FPG(; tol::Float64 = 1e-8,
      maxit::Int64 = 10000,
      verbose::Int64 = 1,
      halt::Function = halt_default,
      linesearch::Bool = true,
      gamma::Float64 = Inf) =
	PG(tol = tol, maxit = maxit, verbose = verbose, halt = halt, linesearch = linesearch, fast = true, gamma = gamma)

function solve!(A::Union{AbstractArray,LinearOp}, b::AbstractArray, g::ProximableFunction, x::AbstractArray, slv::PG)

	tic()

	At = A'
	# compute least squares residual and f(x)
	resx = A*x - b
	gradx = At*resx
	slv.cnt_matvec += 2
	fx = 0.5*deepvecnorm(resx)^2
	fz = fx
	gz = Inf
	costprev = Inf
	normfpr0 = Inf

	if slv.gamma == Inf # compute upper bound for Lipschitz constant using fd
		resx_eps  = A*(x+sqrt(eps())) - b
		gradx_eps = At*resx_eps
		slv.cnt_matvec += 2
		Lf = deepvecnorm(gradx-gradx_eps)/(sqrt(eps()*deeplength(x)))
		slv.gamma = 1/Lf
	end

	# initialize variables
	xprev = deepcopy(x)
	resxprev = deepcopy(resx)
	y = deepcopy(x)
	fy = fx
	grady = gradx

	gradstep = deepcopy(x)

	for slv.it = 1:slv.maxit

		# stopping criterion
		if slv.halt(slv, normfpr0, costprev) break end

		# line search on gamma
		for j = 1:32
			gradstep .= (*).(-slv.gamma, grady)
			gradstep .+= y
			gz = prox!(g, gradstep, x, slv.gamma)
			slv.cnt_prox += 1
			fpr = y-x
			slv.normfpr = deepvecnorm(fpr)
			A_mul_B!(resx, A, x)
			resx .-= b
			slv.cnt_matvec += 1
			fz = 0.5*deepvecnorm(resx)^2
			if slv.linesearch == false break end
			uppbnd = fy - real(deepvecdot(grady,fpr)) + 1/(2*slv.gamma)*slv.normfpr^2
			if fz <= uppbnd break end
			slv.gamma = 0.5*slv.gamma
		end

		if slv.it == 1 normfpr0 = slv.normfpr end

		slv.cost = fz + gz

		# print out stuff
		print_status(slv)

		# extrapolation
		if slv.fast
			y = x + (slv.it-1)/(slv.it+2) * (x - xprev)
			resy = resx + (slv.it-1)/(slv.it+2) * (resx - resxprev)
		else
			y = x
			resy = resx
		end

		# compute gradient and f(y)
		fy = 0.5*deepvecnorm(resy)^2
		A_mul_B!(grady, At, resy)
		slv.cnt_matvec += 1

		# update iterates
		x, xprev = xprev, x
		resx, resxprev = resxprev, resx
		costprev = slv.cost

	end

	print_status(slv, 2*(slv.verbose>0))

	slv.time = toq()

	return x, slv

end
