## TODO list

* Document regularizers.
* Implement tests on regularizers (also for matrix- and complex-variables).
* Test algorithms on matrix- and complex-variable problems.
* Give some structure to algorithms output, such as

		x, output = solve(A, b, g, x0)
where `x` containts the solution Array, `output` contains other details about the solution process. (Just as an example, another idea is to do like other well established Julia solvers do).
* Link [Travis](https://travis-ci.org/) to repo (once public)
* Link [Coveralls](https://coveralls.io/) to repo (once public)

## Code optimization

* See if static typing helps and is used in the best way.
* See if we can speed up LBFGS two-loop-recursion implementing it in C.

## Regularizers to add

* Indicator of an affine subspace.
* Nuclear norm.
* Elastic net.
