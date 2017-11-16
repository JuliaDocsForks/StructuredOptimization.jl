using RegLS

srand(123)
Na,Nb = 200,1500
a = [0+randn(Na)  6+ 4+1*randn(Na)]    
b = [8+randn(Nb)  4+randn(Nb)]

x = Variable(zeros(2))
z = Variable(zeros(1))
A = [[a[:,1];b[:,1]] [a[:,2];b[:,2]]]

bi = [ones(Na);-ones(Nb)]
d = 1e-8*ones(2)  # regularization

slv = @minimize ls(d.*x)+sqrhingeloss(A*x.+z,bi) with ZeroFPR(tol = 1e-8, verbose = 0)
println(slv)
~x .= 0.
slv = @minimize ls(d.*x)+sqrhingeloss(A*x.+z,bi) with FPG(tol = 1e-8, verbose = 0)
println(slv)
xx = linspace(-30,30,10)

theta = atan((~x)[2]/(~x)[1])
marginy = cos(theta)/norm((~x)[1:2])
marginx = sin(theta)/norm((~x)[1:2])

using PyPlot
figure()
plot(a[:,1],a[:,2], "r*")
plot(b[:,1],b[:,2], "ko")
plot(xx,-((~x)[1]*xx+(~z)[1])./(~x)[2])
plot(xx+marginy,-((~x)[1]*xx+(~z)[1])./(~x)[2]+marginx)
plot(xx-marginy,-((~x)[1]*xx+(~z)[1])./(~x)[2]-marginx )
xlim([-30;30])
ylim([-30;30])


