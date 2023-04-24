
using Distributions, Base.Threads, BenchmarkTools


"""
function estimatepi(n)

Runs a simple Monte Carlo method
to estimate pi with n samples.
"""
function estimate_pi(n)
	count = 0
	for i=1:n		
		x = rand(Uniform(-1.0, 1.0))
		y = rand(Uniform(-1.0, 1.0))
		count += (x^2 + y^2) <= 1
	end
	
	return 4*count/n
end

function estimate_pi_inner_threads(n)
	counts = zeros(Int,Threads.nthreads())
	@threads for i=1:n		
		x = rand(Uniform(-1.0, 1.0))
		y = rand(Uniform(-1.0, 1.0))
		counts[Threads.threadid()] += (x^2 + y^2) <= 1
	end
	
	return 4*sum(counts)/n
end



"""
Compute pi in parallel, over ncores cores, with a Monte Carlo simulation throwing N total darts
"""
# number 1
function estimate_pi_tasks_vector(N::Int)
	ntasks = Base.Threads.nthreads()
	slices_of_pi = Vector{Float64}(undef, ntasks)
	n = N ÷ ntasks

	@sync for tid in 1:ntasks
		Threads.@spawn slices_of_pi[tid] = estimate_pi(n)
	end
    return sum(slices_of_pi) / ntasks
end

# number 6
function estimate_pi_6(N::Int)
	ntasks = Base.Threads.nthreads()
	slices_of_pi = Vector{Float64}(undef, ntasks)
	n = N ÷ ntasks

	Threads.@threads for tid in 1:ntasks
		 slices_of_pi[tid] = estimate_pi(n)
	end
    return sum(slices_of_pi) / ntasks
end

import ThreadsX

function throw_dart() 
	x = rand(Uniform(-1.0, 1.0))
	y = rand(Uniform(-1.0, 1.0))
	return (x^2 + y^2) <= 1
end

estimate_pi_ThreadX(N) =ThreadsX.sum( _->throw_dart() , 1:N )*4/N
#ThreadsX(_->throw_dart(),1:N)

"""
Compute pi in parallel, over ncores cores, with a Monte Carlo simulation throwing N total darts with channels
"""
# number 2
function estimate_pi_tasks_channel(N::Int)
	ntasks = Base.Threads.nthreads()
	ch = Channel{Float64}(ntasks)
	n = N ÷ ntasks

	@sync for _ in 1:ntasks
		Threads.@spawn put!(ch, estimate_pi(n))
	end
	sum_of_pis = sum(take!(ch) for _ in 1:ntasks)
    return sum_of_pis / ntasks
	#slices_of_pi = collect(take!(ch) for _ in 1:ntasks)
	#return slices_of_pi
end


mutable struct Counter{T}
	@atomic val::T
end

"""
function estimatepi(n)

Runs a simple Monte Carlo method
to estimate pi with n samples.
"""
# number 3
function estimate_pi_atomic(n)
	count = Counter(0)
	Threads.@threads for i=1:n
		x = rand(Uniform(-1.0, 1.0))
		y = rand(Uniform(-1.0, 1.0))
		@atomic count.val += (x^2 + y^2) <= 1
	end
	return 4*count.val/n
end

# number 4
function estimate_pi_tasks_atomic(N::Int)
	ntasks = Base.Threads.nthreads()
	#slices_of_pi = Vector{Float64}(undef, ntasks)
	n = N ÷ ntasks
	sum = Counter(0.0)
	@sync for tid in 1:ntasks
		Threads.@spawn begin
			@atomic sum.val += estimate_pi(n)
		end
	end
    return sum.val / ntasks
end

# number 5
function estimate_pi_5(N::Int)
	v = zeros(N)
	Threads.@threads for i ∈ 1:N
		v[i] = estimate_pi(1)
	end	
	return sum(v)/N
end



N = 2_000_000


serial = @belapsed estimate_pi(N) seconds=1
pchannel = @belapsed estimate_pi_tasks_channel(N)  seconds=1
pvector = @belapsed estimate_pi_tasks_vector(N)  seconds=1
patomic = @belapsed estimate_pi_atomic(N)  seconds=1
ptasksatomic = @belapsed estimate_pi_tasks_atomic(N) seconds=1
p5 = @belapsed estimate_pi_5(N) seconds=1
p6 = @belapsed estimate_pi_6(N) seconds=1
p7 = @belapsed estimate_pi_inner_threads(N) seconds=1
p8 = @belapsed estimate_pi_ThreadX(N) seconds=1


pvector/serial, pchannel/serial, patomic/serial, ptasksatomic/serial, p5/serial, p6/serial, p7/serial, p8/serial
