immutable Primal
	s::CostFunction          #smooth cost function
	p::ProximableFunction
end

solve(P::Primal, slv::Solver = default_slv()) = solve(P.s, P.p, slv)

function Base.show(io::IO, P::Primal)
	println("Primal Problem")
	println()
	println("Smooth Cost Function:")
	println()
	show(P.s)
	println()
	println("Proximable operators:")
	println()
	show(P.p)
	println()
end

