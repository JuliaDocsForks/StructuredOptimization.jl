immutable Transpose{T<:LinearOperator} <: LinearOperator
	A::T
end

size(L::Transpose) = size(L.A,2), size(L.A,1)

# Constructors
transpose(L::LinearOperator) = Transpose(L)

# Transformations
Transpose(L::Transpose) = L.A

# Operators
A_mul_B!{T<:LinearOperator}(y, L::Transpose{T}, x) = Ac_mul_B!(y, L.A, x)
Ac_mul_B!{T<:LinearOperator}(y, L::Transpose{T}, x) = A_mul_B!(y, L.A, x)

# Properties

  domainType(L::Transpose) = codomainType(L.A)
codomainType(L::Transpose) =   domainType(L.A)

fun_name(L::Transpose)  = "$(fun_name(L.A)) (adjoint)"

