export Zeros

immutable Zeros{O,I} <: LinearOperator
	codomainType::Type
	domainType::Type
	dim_out::NTuple{O,Int}
	dim_in::NTuple{I,Int}
end

# Constructors

Zeros(dim::Vararg{Int64}) = Zeros(dim)
Zeros(domainType,dim::Vararg{Int64}) = Zeros(domainType,dim)

Zeros(                              x::AbstractArray) =
Zeros(eltype(x), eltype(x),  size(x), size(x))
Zeros(                                 dim_in::Tuple) = Zeros(Float64, Float64,  dim_in, dim_in)
Zeros(        D::Type,                 dim_in::Tuple) = Zeros(      D,       D,  dim_in, dim_in)
Zeros(                 dim_out::Tuple, dim_in::Tuple) = Zeros(Float64, Float64, dim_out, dim_in)
Zeros(        D::Type, dim_out::Tuple, dim_in::Tuple) = Zeros(      D,       D, dim_out, dim_in)

Zeros(L::LinearOperator) = Zeros(codomainType(L), domainType(L), size(L,1), size(L,2))

# Mappings

function A_mul_B!(y::AbstractArray,A::Zeros,b::AbstractArray)
	y .= 0.
end

function Ac_mul_B!(y::AbstractArray,A::Zeros,b::AbstractArray)
	y .= 0.
end

# Properties

size(L::Zeros) = (L.dim_out,L.dim_in)

fun_name(A::Zeros)  = "Zero Operator"
