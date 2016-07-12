include("utils.jl")

function ista(A::Array{Float64,2}, args...)

	L(y::Array{Float64}) = A*y
	Ladj(y::Array{Float64}) = A'*y
	ista(L, Ladj, args...)

end

function ista(L::Function, Ladj::Function, b::Array{Float64}, proxg::Function, x::Array{Float64}, maxit=10000, tol=1e-5, verbose=1)

	gamma = 100.0
	z = xprev = x
	normfpr = Inf
	k = 0

	for k = 1:maxit

		# compute least squares residual and gradient
		resx = L(x) - b
		fx = 0.5*norm(resx)^2
		gradx = Ladj(resx)

		# line search on gamma
		for j = 1:32
			gradstep = x - gamma*gradx
			z, ~ = proxg(gradstep, gamma)
			fpr = x-z
			normfpr = norm(fpr)
			resz = L(z) - b
			fz = 0.5*norm(resz)^2
			uppbnd = fx - dot(gradx[:],fpr[:]) + 1/(2*gamma)*normfpr^2
			if fz <= uppbnd; break; end
			gamma = 0.5*gamma
		end

		# stopping criterion
		if normfpr <= tol break end

		# print out stuff
		print_status(k, gamma, normfpr, verbose)

		# update iterates
		x = z

	end

	print_status(k, gamma, normfpr, 2*(verbose>0))
	return z, k

end
