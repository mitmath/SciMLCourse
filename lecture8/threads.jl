using Base.Threads, BenchmarkTools, Statistics, StaticArrays
const N = 1_000


## Review from the end of last lecture
## best serial code was lorenz4 with solve_system_save!
## @SVector puts the length 3 vector on the stack
## @inbounds doesn't hurt, may not help much
## there were NO allocations as it used mutation
## specifically we preallocate a vector u that will contain N Svectors
## 


  function lorenz4(u,p)
    α,σ,ρ,β = p
    @inbounds begin
      du1 = u[1] + α*(σ*(u[2]-u[1]))
      du2 = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
      du3 = u[3] + α*(u[1]*u[2] - β*u[3])
    end
    @SVector [du1,du2,du3]
  end

  function solve_system_save!(u,f,u0,p,n)
    @inbounds u[1] = u0
    @inbounds for i in 1:length(u)-1
      u[i+1] = f(u[i],p)
    end
    u
  end

u = Vector{typeof(@SVector([1.0,0.0,0.0]))}(undef,N);  # preallocate space for 3N floats
p = (0.02,10.0,28.0,8/3)

println("Time for length N=$N Iteration")
@btime solve_system_save!(u,lorenz4,@SVector([1.0,0.0,0.0]),p,N);




println("Now for some means")

function compute_trajectory_mean(u0,p)
    u = Vector{typeof(@SVector([1.0,0.0,0.0]))}(undef,N)
    solve_system_save!(u,lorenz4,u0,p,N);
    mean(u)
  end
  @btime compute_trajectory_mean(@SVector([1.0,0.0,0.0]),p);


# There is a tiny benefit for preallocating the global u 

function compute_trajectory_mean2(u0,p)
    # u is automatically captured
    solve_system_save!(u,lorenz4,u0,p,1000);
    mean(u)
  end
  @btime compute_trajectory_mean2(@SVector([1.0,0.0,0.0]),p);


  # slight  benefit for making this a const vector (maybe/maybe not)
  const _u_cache = Vector{typeof(@SVector([1.0,0.0,0.0]))}(undef,N);
  
  function compute_trajectory_mean3(u0,p)
    # u is automatically captured
    solve_system_save!(_u_cache,lorenz4,u0,p,1000);
    mean(_u_cache)
  end
  @btime compute_trajectory_mean3(@SVector([1.0,0.0,0.0]),p);

# a closure is a nice style, and maybe a little benefit
function _compute_trajectory_mean4(u,u0,p)
    solve_system_save!(u,lorenz4,u0,p,N);
    mean(u)
end
compute_trajectory_mean4(u0,p) = _compute_trajectory_mean4(_u_cache,u0,p)  # called a closure
@btime compute_trajectory_mean4(@SVector([1.0,0.0,0.0]),p);


const M = 2000
# let's do a multi-parameter search
ps = [(0.02,10.0,28.0,8/3) .* (1.0,rand(3)...) for i in 1:M];

serial_out = map(p -> compute_trajectory_mean4(@SVector([1.0,0.0,0.0]),p),ps);

# now with multithreading
function tmap(f,ps)
    out = Vector{typeof(@SVector([1.0,0.0,0.0]))}(undef,M)
    Threads.@threads for i in 1:M
      # each loop part is using a different part of the data
      out[i] = f(ps[i])
    end
    out
  end
  threaded_out = tmap(p -> compute_trajectory_mean4(@SVector([1.0,0.0,0.0]),p),ps)

serial_out .- threaded_out

  ## We need a different "heap location" for each thread
const _u_cache_threads = [Vector{typeof(@SVector([1.0,0.0,0.0]))}(undef,N) for i in 1:Threads.nthreads()];

function compute_trajectory_mean5(u0,p)
    # u is automatically captured
    solve_system_save!(_u_cache_threads[Threads.threadid()],lorenz4,u0,p,N);
    mean(_u_cache_threads[Threads.threadid()])
end


  
serial_out = map(p -> compute_trajectory_mean5(@SVector([1.0,0.0,0.0]),p),ps)
threaded_out = tmap(p -> compute_trajectory_mean5(@SVector([1.0,0.0,0.0]),p),ps)
serial_out - threaded_out



  

@btime serial_out = map(p -> compute_trajectory_mean5(@SVector([1.0,0.0,0.0]),p),ps);
@btime threaded_out = tmap(p -> compute_trajectory_mean5(@SVector([1.0,0.0,0.0]),p),ps);


 