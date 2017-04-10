export DCT, IDCT
abstract CosineTransform <: LinearOperator

immutable DCT <: CosineTransform
	dim_in::Tuple
	domainType::Type
	A::Base.DFT.Plan
end

immutable IDCT <: CosineTransform
	dim_in::Tuple
	domainType::Type
	A::Base.DFT.Plan
end

size(L::CosineTransform) = (L.dim_in,L.dim_in)

DCT(dim_in::Tuple) = DCT(zeros(dim_in))
DCT(T::Type,dim_in::Tuple) = DCT(zeros(T,dim_in))
DCT(x::AbstractArray)  =  DCT(size(x),eltype(x), plan_dct(x)) 

IDCT(dim_in::Tuple) = IDCT(zeros(dim_in))
IDCT(T::Type,dim_in::Tuple) = IDCT(zeros(T,dim_in))
IDCT(x::AbstractArray) = IDCT(size(x),eltype(x), plan_idct(x)) 

transpose( L::DCT) = IDCT(L.domainType, L.dim_in )
transpose(L::IDCT) =  DCT(L.domainType, L.dim_in )

function A_mul_B!(y::AbstractArray,A::DCT,b::AbstractArray)
	A_mul_B!(y,A.A,b)
end

function A_mul_B!(y::AbstractArray,A::IDCT,b::AbstractArray)
	#A_mul_B!(y,A.A,b) #not working??! possible bug?
	y .= A.A*b
end

fun_name(A::DCT)  = "Discrete Cosine Transform"
fun_name(A::IDCT) = "Inverse Discrete Cosine Transform"
