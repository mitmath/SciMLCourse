using Flux, Statistics, Plots

# n = 3
# n = 10
# n = 20
#  n = 25
# the below don't work with Flux.Descent(0.005)
#n = 26
n = 28
#n = 30
#n = 32

NNODE = Chain(x -> [Float32(x)], 
           Dense(1 => n,tanh),
           Dense(n => 1),
           first) 

ϵ = sqrt(eps(Float32))
g(t) = t*NNODE(t) + 1f0
loss() = mean(abs2(((g(t+ϵ)-g(t))/ϵ) - sin(2π*t)) for t in 0:1f-2:1f0)

#opt = Flux.Descent(0.005)
opt = Flux.Adam(0.01) ## for now this is a faster gradient descent
data = Iterators.repeated((), 1000)
iter = 0
cb = function () #callback function to observe training
  global iter += 1
  if iter % 500 == 0
    display(loss())
  end
end
display(loss())
Flux.train!(loss, Flux.params(NNODE), data, opt; cb=cb)

t = 0:0.001:1.0
plot(t,g.(t),label="NN")
plot!(t,1.0 +1/(2π) .- cos.(2π.*t)/2π, label = "True Solution")