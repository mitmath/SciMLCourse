using Flux, Plots, DifferentialEquations

# Let's set up a modified Hook's law u" = kx + 0.1sinx
k = 1.0
force(dx,x,k,t) = -k*x + 0.1sin(x)

# solve and plot the solution
prob = SecondOrderODEProblem(force,1.0,0.0,(0.0,10.0),k)
sol = solve(prob)
plot(sol,label=["Velocity" "Position"])

# get forces at all points
plot_t = 0:0.01:10
data_plot = sol(plot_t)
positions_plot = [state[2] for state in data_plot]
force_plot = [force(state[1],state[2],k,t) for state in data_plot]

# dataset at four points
t = 0:3.3:10
dataset = sol(t)
position_data  = [state[2] for state in sol(t)]
force_data   = [force(state[1],state[2],k,t) for state in sol(t)]

# see the four positions_plot
plot(plot_t,force_plot,xlabel="t",label="True Force")
scatter!(t,force_data,label="Force Measurements")

NNForce = Chain(x -> [Float32(x)],
           Dense(1 => 32,tanh),
           Dense(32 => 1),
           first)


random_positions = [2rand()-1 for i in 1:100] # random values in [-1,1]
loss_ode() = sum(abs2,NNForce(x) - (-k*x) for x in random_positions)
loss() = sum(abs2,NNForce(position_data[i]) - force_data[i] for i in 1:length(position_data))

λ = 0.1
composed_loss() = loss() + λ*loss_ode()



opt = Flux.Descent(0.01)
data = Iterators.repeated((), 10000)
iter = 0
cb = function () #callback function to observe training
  global iter += 1
  if iter % 500 == 0
    display(composed_loss())
  end
end
display(composed_loss())
Flux.train!(composed_loss, Flux.params(NNForce), data, opt; cb=cb)

learned_force_plot = NNForce.(positions_plot)

plot(plot_t,force_plot,xlabel="t",label="True Force")
plot!(plot_t,learned_force_plot,label="Predicted Force")
scatter!(t,force_data,label="Force Measurements")