abstract ExtendedRealValuedFunction
# should we remove these and keep only predicates?
abstract SmoothFunction    <: ExtendedRealValuedFunction
abstract QuadraticFunction <: SmoothFunction
abstract NonSmoothFunction <: ExtendedRealValuedFunction

include("functions/LeastSquares.jl")
include("functions/MoreauEnvelope.jl")

include("functions/Norm.jl")
include("functions/Box.jl")
include("functions/HingeLoss.jl")
include("functions/IndBallRank.jl")

gradient!(f::ExtendedRealValuedFunction, args...) = error("gradient not implemented for $f")

function gradient(f::ExtendedRealValuedFunction, x::AbstractArray)
	y = similar(x)
	fx = gradient!(y,f,x)
	return y, fx  
end

gradstep!(f::ExtendedRealValuedFunction, args...) = error("gradstep not implemented for $f")

function gradstep(f::ExtendedRealValuedFunction, x0::AbstractArray, gamma)
	x1 = similar(x0)
	fx1 = gradstep!(x1, f, x0, gamma)
	return x1, fx1  
end

lambda(f::ExtendedRealValuedFunction) = 1.0

isQuadratic(f::ExtendedRealValuedFunction) = false
isQuadratic(f::QuadraticFunction) = true

isSmooth(f::ExtendedRealValuedFunction) = false
isSmooth(f::SmoothFunction) = true






