using BenchmarkTools

function lorenz(u,p)
    α,σ,ρ,β = p
    du1 = u[1] + α*(σ*(u[2]-u[1]))
    du2 = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
    du3 = u[3] + α*(u[1]*u[2] - β*u[3])
    [du1,du2,du3]  # returns a vector
  end
  p = (0.02,10.0,28.0,8/3)


# first try
function solve_system_save(f,u0,p,n)
    u = Vector{typeof(u0)}(undef,n)
    u[1] = u0
    for i in 1:n-1
      u[i+1] = f(u[i],p)
    end
    u
  end
 @btime  solve_system_save(lorenz,[1.0,0.0,0.0],p,1000);

 # second try (shows that pushing doesnt hurt or help)
 # you might think that not allocating the memory would slow you down, but...
 # julia doubles memory each time
 function solve_system_save_push(f,u0,p,n)
     u = Vector{typeof(u0)}(undef,1) # note the 1
    u[1] = u0
    for i in 1:n-1
      push!(u,f(u[i],p))
    end
    u
  end
  @btime solve_system_save_push(lorenz,[1.0,0.0,0.0],p,1000);

  # matlab users might prefer matrices
# third try
function solve_system_save_matrix(f,u0,p,n)
    u = Matrix{eltype(u0)}(undef,length(u0),n)
    u[:,1] = u0
    for i in 1:n-1
      u[:,i+1] = f(u[:,i],p)
    end
    u
  end
  @btime solve_system_save_matrix(lorenz,[1.0,0.0,0.0],p,1000);
# slicing into the matrix is expensive

#fourth try -- fix with a view

function solve_system_save_matrix_view(f,u0,p,n)
    u = Matrix{eltype(u0)}(undef,length(u0),n)
    u[:,1] = u0
    for i in 1:n-1
      u[:,i+1] = f(@view(u[:,i]),p)
    end
    u
  end
  @btime solve_system_save_matrix_view(lorenz,[1.0,0.0,0.0],p,1000);
#okay that's more like it

# Note that growing matrices adaptively is a really bad idea
function solve_system_save_matrix_resize(f,u0,p,n)
    u = Matrix{eltype(u0)}(undef,length(u0),1)
    u[:,1] = u0
    for i in 1:n-1
      u = hcat(u,f(@view(u[:,i]),p))
    end
    u
  end
  @btime solve_system_save_matrix_resize(lorenz,[1.0,0.0,0.0],p,1000);

  # so let's go back to matrices of vectors
  function lorenz(u,p)
    α,σ,ρ,β = p
    du1 = u[1] + α*(σ*(u[2]-u[1]))
    du2 = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
    du3 = u[3] + α*(u[1]*u[2] - β*u[3])
    [du1,du2,du3]  # returns a vector
  end
  function solve_system_save(f,u0,p,n)
    u = Vector{typeof(u0)}(undef,n)
    u[1] = u0
    for i in 1:n-1
      u[i+1] = f(u[i],p)
    end
    u
  end

  function lorenz2(du,u,p)  # du is now an argument so it can mutate
    α,σ,ρ,β = p
    du[1] = u[1] + α*(σ*(u[2]-u[1]))
    du[2] = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
    du[3] = u[3] + α*(u[1]*u[2] - β*u[3])
  end
  p = (0.02,10.0,28.0,8/3)
  function solve_system_save2(f,u0,p,n)
    u = Vector{typeof(u0)}(undef,n)
    du = similar(u0)  # new line
    u[1] = u0  
    for i in 1:n-1
      f(du,u[i],p) # now called with du [no allocations!]
      u[i+1] = du  
    end
    u
  end
 @btime  solve_system_save2(lorenz2,[1.0,0.0,0.0],p,1000);

 #but
 # solve_system_save2(lorenz2,[1.0,0.0,0.0],p,1000)
 # we are changign the data every time, can't get around that

 function solve_system_save_copy(f,u0,p,n)
    u = Vector{typeof(u0)}(undef,n)
    du = similar(u0)
    u[1] = u0
    for i in 1:n-1
      f(du,u[i],p)
      u[i+1] = copy(du)
    end
    u
  end
  @btime solve_system_save_copy(lorenz2,[1.0,0.0,0.0],p,1000);

  # static array approach
  using StaticArrays
function lorenz3(u,p)
  α,σ,ρ,β = p
  du1 = u[1] + α*(σ*(u[2]-u[1]))
  du2 = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
  du3 = u[3] + α*(u[1]*u[2] - β*u[3])
  @SVector [du1,du2,du3]
end
p = (0.02,10.0,28.0,8/3)
function solve_system_save(f,u0,p,n)
  u = Vector{typeof(u0)}(undef,n)
  u[1] = u0
  for i in 1:n-1
    u[i+1] = f(u[i],p)
  end
  u
end
@btime solve_system_save(lorenz3,@SVector[1.0,0.0,0.0],p,1000);

# people like inbounds, i don't find it saves that much that often, but sometimes.
function lorenz4(u,p)
    α,σ,ρ,β = p
    @inbounds begin
      du1 = u[1] + α*(σ*(u[2]-u[1]))
      du2 = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
      du3 = u[3] + α*(u[1]*u[2] - β*u[3])
    end
    @SVector [du1,du2,du3]
  end

  function solve_system_save(f,u0,p,n)
    u = Vector{typeof(u0)}(undef,n)
    @inbounds u[1] = u0
    @inbounds for i in 1:n-1
      u[i+1] = f(u[i],p)
    end
    u
  end
 @btime  solve_system_save(lorenz4,@SVector[1.0,0.0,0.0],p,1000);

# the single allocation is the output , that can be removed 
function solve_system_save!(u,f,u0,p,n) # add an output u to be mutated as well
    @inbounds u[1] = u0
    @inbounds for i in 1:length(u)-1
      u[i+1] = f(u[i],p)
    end
    u
  end
  u = Vector{typeof(@SVector([1.0,0.0,0.0]))}(undef,1000)
  @btime solve_system_save!(u,lorenz4,@SVector([1.0,0.0,0.0]),p,1000);