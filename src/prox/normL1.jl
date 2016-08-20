# L1 norm (times a constant, or weighted)

immutable normL1{T <: Union{Float64,Array{Float64}}} <: ProximableFunction
  lambda::T
  normL1(lambda::Float64) = lambda < 0 ? error("parameter λ must be nonnegative") : new(lambda)
  normL1(lambda::Array{Float64}) = any(lambda .< 0) ? error("coefficients in λ must be nonnegative") : new(lambda)
end

"""
  normL1(λ::Float64=1.0)

Returns the function `g(x) = λ||x||_1`, for a real parameter `λ ⩾ 0`.
"""

normL1(lambda::Float64) = normL1{Float64}(lambda)

"""
  normL1(λ::Array{Float64})

Returns the function `g(x) = sum(λ_i|x_i|, i = 1,...,n)`, for a vector of real
parameters `λ_i ⩾ 0`.
"""

normL1(lambda::Array{Float64}) = normL1{Array{Float64}}(lambda)

function call(f::normL1{Float64}, x::RealOrComplexArray)
  return f.lambda*vecnorm(x,1)
end

function call(f::normL1, x::RealOrComplexArray)
  return vecnorm(f.lambda.*x,1)
end

function prox(f::normL1{Float64}, gamma::Float64, x::RealOrComplexArray)
  y = sign(x).*max(0.0, abs(x)-gamma*f.lambda)
  return y, f.lambda*vecnorm(y,1)
end

function prox(f::normL1, gamma::Float64, x::RealOrComplexArray)
  y = sign(x).*max(0.0, abs(x)-gamma*f.lambda)
  return y, vecnorm(f.lambda.*y,1)
end
