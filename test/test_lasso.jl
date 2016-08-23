using RegLS
using Base.Test

A = [1.0  2.0 -1.0 -1.0; -2.0 -1.0  0.0 -1.0; 3.0  0.0  4.0 -1.0; -4.0 -1.0 -3.0  1.0; 5.0  3.0  2.0  3.0]'
b = [1.0, 2.0, 3.0, 4.0]
m, n = size(A)
lambda = 0.1*norm(A'*b, Inf)
g = NormL1(lambda)
x0 = zeros(n)
x_star = [-3.877278911564627e-01, 0, 0, 2.174149659863943e-02, 6.168435374149660e-01]
tol = 1e-8
maxit = 10000
verb = 0
tol_test = 1e-4

@printf("Solving a small lasso instance (m = %d, n = %d)\n", m, n)

x_star, ~ = solve(A, b, g, x0, FPG(verbose = verb))

@time x_ista,  info =  solve(A, b, g, x0, PG(verbose = verb, tol = tol))
@test info.iterations < maxit
@test norm(x_ista-x_star, Inf)/norm(x_star, Inf) <= tol_test

@time x_fista, info = solve(A, b, g, x0, FPG(verbose = verb, tol = tol))
@test info.iterations < maxit
@test norm(x_fista-x_star, Inf)/norm(x_star, Inf) <= tol_test

@time x_zerofpr, info = solve(A, b, g, x0, ZeroFPR(verbose = verb, tol = tol))
@test info.iterations < maxit
@test norm(x_zerofpr-x_star, Inf)/norm(x_star, Inf) <= tol_test
