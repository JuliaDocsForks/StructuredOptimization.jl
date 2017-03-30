export problem, minimize

include("problems/split.jl")
include("problems/mergeProx.jl")
include("problems/primal.jl")
include("problems/dual.jl")

problem(h::CostFunction) = problem(h, Array{CostFunction,1}(0))
problem(h::CostFunction, cstr::CostFunction) = problem(h, [cstr])

function problem{T<:CostFunction}(cf::CostFunction, cstr::Array{T,1} )
	#add constraints to cost function
	for c in cstr
		cf += c
	end
	smooth, proximable, nonsmooth = split(cf)

	proximable =   mergeProx(variable(cf), proximable)
	smooth     = sort_and_expand(variable(cf), smooth    )
	nonsmooth  = sort_and_expand(variable(cf), nonsmooth    )

	if isempty(nonsmooth)
		return Primal(smooth,proximable)
	else
		if isempty(proximable) && length(terms(nonsmooth)) == 1
			return Dual(smooth,nonsmooth)
		else
			error("dual or smooth not implemented yet")
		end
	end


end

minimize(h::CostFunction, args...) = minimize(h, Array{CostFunction,1}(0), args...)
minimize(h::CostFunction, cstr::CostFunction, args...) = minimize(h, [cstr], args...)

function minimize{T<:CostFunction}(cf::CostFunction, cstr::Array{T,1}, slv::Solver=ZeroFPR())
	P = problem(cf,cstr)
	return solve(P,slv)
end

function sort_and_expand(x_sorted::Array{Variable,1}, cf::CostFunction)
	sA = Vector{AffineOperator}(length(affine(cf)))
	for i in eachindex(affine(cf)) 
		sA[i] = sort_and_expand(x_sorted,affine(cf)[i])
	end
	return CostFunction(x_sorted,cf.f,sA)
end
		














