export MatrixOp

immutable MatrixOp{T<:AbstractMatrix,N} <: LinearOperator
	domainType::Type
	dim_in::NTuple{N,Int}
	A::T
end

# Constructors

MatrixOp(domainType,dim_in,A) =
MatrixOp(domainType, dim_in, domainType <: Complex ? complex(A) : A)

MatrixOp(A::AbstractMatrix) = MatrixOp{typeof(A),1}(eltype(A), (size(A, 2),), A)

MatrixOp(A::AbstractMatrix, dim_in::Tuple) = MatrixOp{typeof(A),length(dim_in)}(eltype(A), dim_in, A)

MatrixOp(A::AbstractMatrix, dim_in::Vararg{Int} ) = MatrixOp(A,dim_in)

MatrixOp{T<:AbstractMatrix,N}(domainType::Type, A::T, dim_in::Vararg{Int,N} ) =
MatrixOp{T,N}(domainType,dim_in,A)

MatrixOp(x::AbstractArray, A::AbstractMatrix) = MatrixOp{typeof(A),ndims(x)}(eltype(x),size(x),A)

# Mappings

A_mul_B!{T1,T,N}(y::AbstractArray{T,N},  A::MatrixOp{T1,N}, b::AbstractArray{T,N}) = A_mul_B!(y, A.A, b)
Ac_mul_B!{T1,T,N}(y::AbstractArray{T,N}, A::MatrixOp{T1,N}, b::AbstractArray{T,N}) = Ac_mul_B!(y, A.A, b)

# Properties

size(L::MatrixOp) = length(L.dim_in) == 1 ? ((size(L.A,1),), L.dim_in) :
((size(L.A,1), L.dim_in[2]), L.dim_in)

fun_name(A::MatrixOp)  = "Matrix operator"

is_diagonal(L::MatrixOp)       = isdiag(L.A)
is_full_row_rank(L::MatrixOp)    = rank(L.A) == size(L.A,1)
is_full_column_rank(L::MatrixOp) = rank(L.A) == size(L.A,2)
# the following is O(n^3): I would assume for now no matrix is Gram diagonal
# is_gram_diagonal(L::MatrixOp)   = isdiag(L.A'*L.A)
