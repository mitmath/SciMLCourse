using Plots, Random, SpecialFunctions, FastGaussQuadrature, LinearAlgebra, ForwardDiff

airy_kernel(x, y) = x==y ? (airyaiprime(x))^2 - x * (airyai(x))^2 :
           (airyai(x) * airyaiprime(y) - airyai(y) * airyaiprime(x)) / (x - y)
ϕ(ξ, s) =  s + 10*tan(π*(ξ+1)/4) # Transformation from [-1,1] to (s,∞)
ϕ′(ξ) = (5π/2)*(sec(π*(ξ+1)/4))^2
K(ξ,η,s) = sqrt(ϕ′(ξ) * ϕ′(η)) * airy_kernel(ϕ(ξ,s), ϕ(η,s))

function K(s , n=100) 
    nodes,weights = gausslegendre(n)
    Symmetric( K.(nodes',nodes,s) .* (√).(weights) .* (√).(weights'))
end

TracyWidomPDF_via_Fredholm_Det(s) = ForwardDiff.derivative( t->det(I-K(t)),s)

t = 300 # change to 10_000 slowly when ready

n = 6^6
dx = 1/6
v = zeros(t)


## Experiment
v = zeros(t)
Threads.@threads for i ∈ 1:t
    v[i] = patiencesort1(randperm(n)) # use your fastest function here
end
w = (v .- 2sqrt(n+.5)) ./ (n^(1/6))
histogram(w, normalized=true, bins=-4.5:dx:2)

plot!(TracyWidomPDF_via_Fredholm_Det, -5.0, 2, label="Theory", lw=3)