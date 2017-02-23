import Base: hcat

type HCAT{D3} <: LinearOp{D3}
	x::Array{OptVar}
	A::AbstractArray{LinearOp}
	mid::AbstractArray
	isTranspose::Bool
	sign::Array{Bool,1}
end

function size(A::HCAT)
	dim1, dim2 = tuple(size.(A.A)[2]...), size(A.A[1],2)   
	A.isTranspose ? (dim2,dim1) : (dim1,dim2)
end

fun_name(S::HCAT) = "Horizontally Concatenated Operators"

function hcat{D1,D2,D3}(A::LinearOp{D1,D3}, B::LinearOp{D2,D3}, sign::Array{Bool} )
	if size(A,2) != size(B,2) DimensionMismatch("operators must go to same space!") end
	mid = Array{D3}(size(B,2))
	HCAT{D3}([A.x,B.x], [A,B], mid, false, sign)
end

hcat{D1,D2,D3}(A::LinearOp{D1,D3}, B::LinearOp{D2,D3} ) = hcat(A,B,[true; true])

transpose{D3}(A::HCAT{D3}) = HCAT{D3}(A.x, A.A.', A.mid, A.isTranspose == false, A.sign)

function *{D3,T1<:AbstractArray}(A::HCAT{D3},b::Array{T1,1}) 
	y = Array{D3}(size(A,2))
	A_mul_B!(y,A,b)
	return y
end

function *{D2}(A::HCAT{D2},b::AbstractArray) 
	y = Array{AbstractArray,1}(length(A.A))
	for i = 1:length(A.A)
		y[i] = create_out(A.A[i]) 
	end
	A_mul_B!(y,A,b)
	return y
end

#forward
function A_mul_B!{T1<:AbstractArray}(y::AbstractArray,S::HCAT,b::Array{T1,1}) 
	S.sign[1] ? A_mul_B!(y,S.A[1],b[1]) : A_mul_B!(y,S.A[1],-b[1])
	for i = 2:length(S.A)
		A_mul_B!(S.mid,S.A[i],b[i])
		S.sign[i] ? y .= (+).(y,S.mid) : y .= (-).(y,S.mid)
	end
end

create_out{D1,D2}(A::LinearOp{D1,D2}) = Array{D2}(size(A,2))

#adjoint
function A_mul_B!{T1<:AbstractArray}(y::Array{T1,1},S::HCAT,b::AbstractArray) 
	for i = 1:length(S.A)
		S.sign[i] ? A_mul_B!(y[i],S.A[i],b) : A_mul_B!(y[i],S.A[i],-b)
	end
end

#printing stuff
function fun_dom{D3<:Real}(A::HCAT{D3}) 
	str = ""
	for a in A.A str *= fun_D1(a) end
	str *= "→  ℝ^$(size(A,2))"
end

function fun_dom{D3<:Complex}(A::HCAT{D3}) 
	str = ""
	for a in A.A str *= fun_D1(a) end
	str *= "→  ℂ^$(size(A,2))"
end

fun_D1{D1<:Real, D2}(A::LinearOp{D1,D2})    =  " ℝ^$(size(A,1)) "
fun_D1{D1<:Complex, D2}(A::LinearOp{D1,D2}) =  " ℂ^$(size(A,1)) "
