export DFT, IDFT
abstract FourierTransform <: LinearOperator

immutable DFT <: FourierTransform
	dim_in::Tuple
	domainType::Type
	codomainType::Type
	A::Base.DFT.Plan
	At::Base.DFT.Plan
end

immutable IDFT <: FourierTransform
	dim_in::Tuple
	domainType::Type
	codomainType::Type
	A::Base.DFT.Plan
	At::Base.DFT.Plan
end

size(L::FourierTransform) = (L.dim_in,L.dim_in)

  domainType(L::FourierTransform) = L.domainType
codomainType(L::FourierTransform) = L.codomainType

DFT(dim_in::Tuple) = DFT(zeros(dim_in))
DFT(T::Type,dim_in::Tuple) = DFT(zeros(T,dim_in))
DFT(x::AbstractArray)  =  DFT(size(x),eltype(x),Complex{Float64}, plan_fft(x),  plan_bfft(fft(x))) 
IDFT(dim_in::Tuple) = IDFT(zeros(dim_in))
IDFT(T::Type,dim_in::Tuple) = IDFT(zeros(T,dim_in))
IDFT(x::AbstractArray) = IDFT(size(x),eltype(x),Complex{Float64}, plan_ifft(x), plan_fft(ifft(x))) 

function A_mul_B!(y::AbstractArray,L::DFT,b::AbstractArray)
	if domainType(L) == codomainType(L)
		A_mul_B!(y,L.A,b)
	else # domainType(L) <: Real && codomainType(L) <: Complex
		A_mul_B!(y,L.A,complex(b))
	end
end

function Ac_mul_B!(y::AbstractArray,L::DFT,b::AbstractArray)
	if domainType(L) == codomainType(L)
		A_mul_B!(y,L.At,b)
	else # domainType(L) <: Complex && codomainType(L) <: Real
		y2 = complex(y)
		A_mul_B!(y2,L.At,b)
		y .= real.(y2)
	end
end

function A_mul_B!(y::AbstractArray,L::IDFT,b::AbstractArray)
	if domainType(L) == codomainType(L)
		A_mul_B!(y,L.A,b)
	else # domainType(L) <: Real && codomainType(L) <: Complex
		A_mul_B!(y,L.A,complex(b))
	end
end

function Ac_mul_B!(y::AbstractArray,L::IDFT,b::AbstractArray)
	if domainType(L) == codomainType(L)
		A_mul_B!(y,L.At,b)
		y ./= length(b)
	else # domainType(L) <: Complex && codomainType(L) <: Real
		y2 = complex(y)
		A_mul_B!(y2,L.At,b)
		y .= (/).(real.(y2), length(b))
	end
end

fun_name(A::DFT) = "Discrete Fourier Transform"
fun_name(A::IDFT) = "Inverse Discrete Fourier Transform"

