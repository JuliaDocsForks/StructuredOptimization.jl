# RegLS

Convex and nonconvex regularized least squares in Julia.

## Installation

From the Julia command line hit:

```
Pkg.clone("https://github.com/nantonel/RegLS.jl.git")
```

Once the package is installed you can update it along with the others issuing `Pkg.update()` in the command line.

## Usage

After importing the package with `using RegLS`, you can fit regularized linear models using `AbstractMatrix` or `LinearOperator` objects
(see [LinearOperators.jl](https://github.com/JuliaSmoothOptimizers/LinearOperators.jl)),
or providing the direct and adjoint mappings in the form of `Function` objects:

```julia
x = solve(A, b, g) # A is a Matrix or LinearOperator
x = solve(Op, OpAdj, b, g, x0) # Op and OpAdj are of type Function
```

Here `b` is an `Array` whose dimensions match those of `A` or `Op` and `OpAdj`,
and `g` is the regularization functions in the cost (see below). When the mappings `Op` and `OpAdj`
are provided, argument `x0` is mandatory (the initial iterate for the algorithm).

## Regularizers

The regularization functions included in `RegLS` are listed here.

Function        | Description                                          | Properties
----------------|------------------------------------------------------|----------------
`indBallInf`    | Indicator of an infinity-norm ball                   | convex
`indBallL0`     | Indicator of an L0 pseudo-norm ball                  | nonconvex
`indBallRank`   | Indicator of the set of matrices with given rank     | nonconvex
`indBox`        | Indicator of a box                                   | convex
`normL0`        | L0 pseudo-norm                                       | nonconvex
`normL1`        | L1 norm                                              | convex
`normL2`        | Euclidean norm                                       | convex
`normL2sqr`     | Squared Euclidean norm                               | convex
`normL21`       | Sum-of-L2 norms                                      | convex

Each function can be customized with parameters. You can access the full documentation of each of these functions from the command line of Julia directly:

```
julia> ?normL1

	normL1(λ::Array{Float64})

	Returns the function g(x) = sum(λ_i|x_i|, i = 1,...,n), for a vector of real
	parameters λ_i ⩾ 0.

	normL1(λ::Float64=1.0)

	Returns the function g(x) = λ||x||_1, for a real parameter λ ⩾ 0.
```

## Example - Some nice example #1

## Example - Some nice example #2

## References

The algorithms implemented in RegLS are described in the following papers.

1. L. Stella, A. Themelis, P. Patrinos, “Forward-backward quasi-Newton methods for nonsmooth optimization problems,” [arXiv:1604.08096](http://arxiv.org/abs/1604.08096) (2016).

2. A. Themelis, L. Stella, P. Patrinos, “Forward-backward envelope for the sum of two nonconvex functions: Further properties and nonmonotone line-search algorithms,” [arXiv:1606.06256](http://arxiv.org/abs/1606.06256) (2016).

## Credits

RegLS is developed by [Lorenzo Stella](https://lostella.github.io) and [Niccolò Antonello](http://homes.esat.kuleuven.be/~nantonel/) at [KU Leuven, ESAT/Stadius](https://www.esat.kuleuven.be/stadius/).
