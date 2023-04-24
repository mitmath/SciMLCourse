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
u = Vector{typeof(@SVector([1.0,0.0,0.0]))}(undef,N)
p = (0.02,10.0,28.0,8/3)

@btime solve_system_save!(u,lorenz4,@SVector([1.0,0.0,0.0]),p,N);


const _u_cache_threads = [Vector{typeof(@SVector([1.0,0.0,0.0]))}(undef,N) for i in 1:Threads.nthreads()]
const _u_cache = Vector{typeof(@SVector([1.0,0.0,0.0]))}(undef,N)


function compute_trajectory_mean(u0,p)
    u = Vector{typeof(@SVector([1.0,0.0,0.0]))}(undef,N)
    solve_system_save!(u,lorenz4,u0,p,N);
    mean(u)
  end


function _compute_trajectory_mean4(u,u0,p)
    solve_system_save!(u,lorenz4,u0,p,N);
    mean(u)
end
  
function compute_trajectory_mean5(u0,p)
    # u is automatically captured
    solve_system_save!(_u_cache_threads[Threads.threadid()],lorenz4,u0,p,N);
    mean(_u_cache_threads[Threads.threadid()])
end


  compute_trajectory_mean4(u0,p) = _compute_trajectory_mean4(_u_cache,u0,p)
  #@btime compute_trajectory_mean4(@SVector([1.0,0.0,0.0]),p)

  ps = [(0.02,10.0,28.0,8/3) .* (1.0,rand(3)...) for i in 1:N]

function tmap(f,ps)
    out = Vector{typeof(@SVector([1.0,0.0,0.0]))}(undef,N)
    Threads.@threads :static for i in 1:N
      # each loop part is using a different part of the data
      out[i] = f(ps[i])
    end
    out
  end
  threaded_out = tmap(p -> compute_trajectory_mean4(@SVector([1.0,0.0,0.0]),p),ps)

  #@btime compute_trajectory_mean(@SVector([1.0,0.0,0.0]),p);
  @btime map(p->compute_trajectory_mean5(@SVector([1.0,0.0,0.0]),p),ps);
  @btime threaded_out = tmap(p -> compute_trajectory_mean5(@SVector([1.0,0.0,0.0]),p),ps);