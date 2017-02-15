import Base: reshape

immutable Reshape{D1,D2} <: LinearOp{D1,D2}
	dim::Tuple
end

reshape{D1}(x::OptVar{D1}, dim::Vararg{Int64}) = Reshape{D1,D1}((size(x.x),dim))

*(A::Reshape,b::AbstractArray)  = reshape(b,A.dim[2])

function A_mul_B!(y::AbstractArray,A::Reshape,b::AbstractArray) 
	copy!(y, reshape(b, A.dim[2]))
end

transpose{D1}(A::Reshape{D1,D1}) = Reshape{D1,D1}((A.dim[2],A.dim[1]))

fun_name(A::Reshape) = "Reshape Operator"

#nested Operations
reshape(B::LinearOp,args...) = NestedLinearOp(reshape,B, args...)
