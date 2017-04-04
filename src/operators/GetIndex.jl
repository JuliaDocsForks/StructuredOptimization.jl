import Base: getindex

immutable GetIndex{D1,D2} <: LinearOperator{D1,D2}
	sign::Bool
	idx::Tuple 
	isTranspose::Bool
	dim::Tuple

	GetIndex(idx,isTranspose,dim) = new(true,idx,isTranspose,dim)
	GetIndex(sign,idx,isTranspose,dim) = new(sign,idx,isTranspose,dim)
end
size(A::GetIndex) = A.dim
-{D1,D2}(A::GetIndex{D1,D2}) = GetIndex{D1,D2}(false == sign(A),A.idx,A.isTranspose,A.dim) 

function getindex{D1}(x::Variable{D1}, args...)   
	A = GetIndex{D1,D1}(args, false, get_size(size(x),args...))
	Affine([x], A, A', Nullable{AbstractArray}() )
end

function getindex(B::AffineOperator, args...) 
	A = GetIndex{domainType(B),codomainType(B)}(args, false, 
					     get_size(size(operator(B),2),args...)) 
	N = NestedLinearOperator(A,operator(B))
	b = Nullable{AbstractArray}()
	isnull(B.b) ? nothing : b = adjoint(A)*get(B.b) 
	Affine(variable(B),N,N',b)
end
fun_name(A::GetIndex) = "Get Index"

transpose{D1}(A::GetIndex{D1,D1}) = GetIndex{D1,D1}(sign(A),A.idx,!(A.isTranspose),(A.dim[2],A.dim[1])) 

function uA_mul_B!(y::AbstractArray,A::GetIndex,b::AbstractArray) 
	if A.isTranspose
		y .= 0.
		setindex!(y,b,A.idx...) 
	else
		copy!(y,view(b,A.idx...))
	end
end

function get_size(dim,args...) 
	if length(args) != 1
		dim2 = [dim...] 
		for i = 1:length(args)
			if args[i] != Colon() dim2[i] = length(args[i]) end 
		end
		return (dim,tuple(dim2...))
	else
		return (dim, tuple(length(args[1])))
	end
end

get_idx(A::GetIndex) = A.idx
isAbsorbable(A::GetIndex) = true 








