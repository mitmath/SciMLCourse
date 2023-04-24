### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 01ab2b8f-cb97-425b-9c43-e7f2889dfb7d
begin 
	using PlutoUI
	using StatsBase
	using LinearAlgebra
	using Gadfly
	using Compose
end

# ╔═╡ b5fb46e8-ff75-4eb1-ba63-92e3b4a764fe
n = @bind n Slider(1:10; default=8, show_value=true)

# ╔═╡ 2670e66e-bc2a-11ed-2f25-c554deffd3bf
reduce(+, 1:n), sum(1:n)  # triangular numbers

# ╔═╡ ee52bbc2-1e4a-47e4-8b43-8cb0e730069d
reduce(*, 1:n), prod(1:n) # factorials

# ╔═╡ d3e62a10-69ef-47c3-8ab3-4d1299bbfc82
begin	
	boring(a,b)=a
	reduce(boring, Vector('a':'z')[1:n])
end

# ╔═╡ 82b5c025-9ae1-461e-bf88-c6be0ed093f7
begin
	boring2(a,b)=b
	reduce(boring2, Vector('a':'z')[1:n])
end

# ╔═╡ ab0a8204-65ee-459d-98be-6087187b4096
M=[1 1; 1 0]

# ╔═╡ 6a673be9-c6c0-4dce-b970-74f3e68fc990
N = @bind N Slider(1:100; default=8, show_value=true)

# ╔═╡ a2642146-a331-48a2-9a6c-850b3debe241
prod(fill(big.(M),N))

# ╔═╡ 0e1005c7-47b7-493f-99e6-be069e944c8b
begin
	fib(j)=reduce(*, fill(M,j))
	fib.([4,7])
end

# ╔═╡ 8839cc30-2d1d-4c43-bccf-82944ee2a166
begin
	A=[1 2;3 4]
	B=[10 100; 1 -10]
	⊗(A,B)=kron(A,B)
	
	let M=[ 1 1;1 -1]
		H=⊗(⊗(⊗(M,M),M),M)
		H*H'
	end
end

# ╔═╡ e5e40188-08df-4b82-a776-86e645f925ff
begin
	Hadamard(n)=reduce(⊗, fill([1 1;1 -1],n))
	H = Hadamard(3)
end

# ╔═╡ 56d09724-e48f-4003-a168-0ef2e000e2ec
H'H

# ╔═╡ 5c285f77-31e6-4636-8702-7e99ed173491
H*H' #This is a legitimate Hadamard matrix

# ╔═╡ b07ded7a-21fb-4bcf-a4a7-96d6c73a0ee8
begin 
	rolldice() = rand(1:6)+rand(1:6)
	rolls(n)=fit(Histogram,[rolldice() for i=1:n ],2:12,closed=:left)
end

# ╔═╡ 3a93cb87-6e17-4fe4-a87c-db3ceb1a9fb8
rolls(1000)

# ╔═╡ 7d3b7168-ceea-484a-831b-dbf53dd3ac10
reduce(merge,[rolls(100) for i=1:10])

# ╔═╡ 61e583f4-b9f9-4727-bd0c-07360382cbf6
let 
M=[rand(-3:3,2,2) for i=1:4]


(M[4]*M[3]*M[2]*M[1], 
 reduce((A,B)->B*A, M), #backward multiply
 reduce(*, M)
)
end

# ╔═╡ 861d9a43-24c9-4cec-b82f-94a1b547c5b8
(sin ∘ cos)(1), sin(cos(1))

# ╔═╡ 7ba55f3d-509f-41a8-af58-95f3293ebe96
((-) ∘ sin)(1), -sin(1)

# ╔═╡ e7a16f12-4d98-4caf-9161-31035d971ec3
begin
	h=reduce(∘, [sin cos tan])
	[h(π) sin(cos(tan(π)))]
end

# ╔═╡ e6fffc89-420d-40af-b9ab-d23a56a72bf3
begin
	cumsum(1:8)  # It is useful to know that cumsum is a linear operator
	# You can use power method! Below is the underlying matrix
	Ac=tril(ones(Int,8,8)) 
end

# ╔═╡ 3738164e-73d3-4b13-8386-26d1dfca3983
(Ac*(1:8),cumsum(1:8))

# ╔═╡ a9aa8aec-c265-4bf9-9b15-1c810cbb0b7e
mutable struct DummyArray
    length :: Int
    read :: Vector
    history :: Vector{Any}
    DummyArray(length, read=[], history=[])=new(length, read, history)
end

# ╔═╡ 087e4786-a933-47df-8526-60d20df63271
begin
	Base.length(A::DummyArray)=A.length

	function Base.getindex(A::DummyArray, i)
	    push!(A.read, i)
	    missing
	end
	
	function Base.setindex!(A::DummyArray, x, i)
	    push!(A.history, (A.read, [i]))
	    A.read = []
	end

	
end

# ╔═╡ 531b3af5-07e1-4823-818d-ab540865494b
md"### Reduce"

# ╔═╡ 5e3f0741-fe66-4ccb-822f-63cda1b2c89b
md"""
Sum Reduce\
Example: Triangular Numbers
"""

# ╔═╡ 4a77c84d-6a7b-4dd3-8701-ab405adb364b
md"Example: Factorials"

# ╔═╡ 206df737-3eb2-4275-861a-a0ba958c23d1
md"Examples: Boring"

# ╔═╡ 36a0f36a-1d3f-40c8-8514-7a94ad7ea5c9
md"""
Example:Fibonacci

``\begin{pmatrix} f_2 \\ f_1 \end{pmatrix} = \begin{pmatrix} f_1 + f_0 \\ f_1 \end{pmatrix}``

``\begin{pmatrix} 1 & 1 \\ 1 & 0 \end{pmatrix}^n = \begin{pmatrix} f_{n+1} & f_n\\  f_n & f_{n-1} \\  \end{pmatrix}``


"""

# ╔═╡ 829b05e4-df24-46ed-981a-2bee358ae0aa
md"""
You can solve recurrences of any complexity using `reduce`. For example, `reduce` can compute a Hadamard matrix from its definition in terms of its submatrices:

`` H_2 = \begin{pmatrix} H_1 & H_1 \\ H_1 & -H_1 \end{pmatrix} = \begin{pmatrix} 1 & 1 \\ 1 & -1 \end{pmatrix} \otimes H_1 ``

and so on. 

(Note: this is just using reduce to compute a matrix power.\n",
    "One can think of alternative ways for sure.
"""

# ╔═╡ d0ba43bc-18e4-4ccc-aa9d-d83285ea59b2
md"""
```
# [A B]
# If A is m x n
# If B is p x q
# then kron(A,B) is mp x nq and has all the elements of A 
```
"""

# ╔═╡ 47c9d5a3-274b-4612-a835-db3fadd3373e
md"""
In the following example we apply `reduce` to function composition:
"""

# ╔═╡ bd0267c5-2047-43e4-851e-dadfc25d1ed9
md"""
## `prefix`

Having discussed `reduce`, we are now ready for the idea behind prefix sum. Prefix or scan is long considered an important parallel primitive as well.

Suppose you wanted to compute the partial sums of a vector, i.e. given `y[1:n]`, we want to overwrite the vector y with the vector of partial sums.

```julia
new_y[1] = y[1]
new_y[2] = y[1] + y[2]
new_y[3] = y[1] + y[2] + y[3]
...
```

At first blush, it seems impossible to parallelize this, since

```julia
new_y[1] = y[1]
new_y[2] = new_y[1] + y[2]
new_y[3] = new_y[2] + y[3]
...
```

which appears to be an intrinsically serial process.
"""

# ╔═╡ 8322a1cf-0236-49b3-a169-f8ae7b4eedb7
function prefix_serial!(y, ⊕)
    for i=2:length(y)
        y[i] = y[i-1] ⊕ y[i]
        end
    y
end

# ╔═╡ 434211b7-1055-47d2-aa44-b4b2d9f97203
prefix_serial!([1:8;],*)

# ╔═╡ be349102-60fc-4d27-aa5a-f1f74a96109b
prefix_serial!([rand(1:5,2,2) for i=1:4],*)

# ╔═╡ 05d88bce-6bf7-415c-bee1-a45f8eeb0b34
md"""
However, it turns out that because addition `(+)` is associative, we can regroup the order of how these sums are carried out. (This of course extends to other associative operations such as multiplication.) Another ordering of 8 associative operations is provided by `prefix8!`:
"""

# ╔═╡ 96b1616b-9ea6-4a11-b4b2-9a4464c36ab9
# Eight only for pedagogy
function prefix8!(y, ⋅)
    length(y)==8 || error("length 8 only")
    for i in [2,4,6,8]; y[i] = y[i-1] ⋅ y[i]; end
    for i in [  4,  8]; y[i] = y[i-2] ⋅ y[i]; end
    for i in [      8]; y[i] = y[i-4] ⋅ y[i]; end
    for i in [    6  ]; y[i] = y[i-2] ⋅ y[i]; end
    for i in [ 3,5,7 ]; y[i] = y[i-1] ⋅ y[i]; end
    y
end

# ╔═╡ f2d04cda-df53-4867-ac56-f597267cc807
# Generalization to any n
function prefix!(y, ⋅)
    l=length(y)
    k=ceil(Int, log2(l))
    @inbounds for j=1:k, i=2^j:2^j:min(l, 2^k)              #"reduce"
        y[i] = y[i-2^(j-1)] ⋅ y[i]
    end
    @inbounds for j=(k-1):-1:1, i=3*2^(j-1):2^j:min(l, 2^k) #"broadcast"
        y[i] = y[i-2^(j-1)] ⋅ y[i]
    end
    y
end

# ╔═╡ be1208cb-1621-469a-b41a-d7411f66e91d
prefix!([1:12;],*)

# ╔═╡ 947d4c14-dd06-41ba-9edf-e09b9c55aacb
md"""
## Polymorphism for visualization

We can visualize the operations with a little bit of trickery. In Julia, arrays are simply types that expose the array protocol. In particular, they need to implement methods for the generic functions `length`, `getindex` and `setindex!`. The last two are used in indexing operations, since statements

```julia
y = A[1]
A[3] = y
```

get desugared to

```julia
y = getindex(A, 1)
setindex!(A, y, 3)
```

respectively.

We can trace through the iterable by introduce a dummy array type, `DummyArray`, which stores no useful information but records every access to `getindex` and `setindex!`.

Specifically:

- `length(A::DummyArray)` returns an integer that is stored internally in the `A.length `field
- `getindex(A::DummyArray, i)` records read access to the index `i` in the `A.read` field and always returns `missing`.
- `setindex!(A::DummyArray, x, i)` records write access to the index `i`. The `A.history` field is appended with a new tuple consisting of the current `A.read` field and the index `i`.

The way `DummyArray` works, it assumes an association between a single `setindex!` call and and all the preceding `getindex` calls since the previous `setindex!` call, which is sufficient for the purposes of tracing through prefix calls.
"""

# ╔═╡ 54f9bed6-37f0-4b9e-901c-f4c5fb9ca2ba
let
	M = DummyArray(4)
	M[7] = M[3] + M[2]
	M
end

# ╔═╡ bdf9341c-ec26-423e-985d-834903c2eac0
DummyA = prefix8!(DummyArray(8),+)

# ╔═╡ af31d1d7-ae8e-4400-aeb4-cb42ce0c4ec7
DummyA.history

# ╔═╡ 8eec5baf-02a8-4414-a761-37612bbccae9
md"""
Now let's visualize this! Each entry in A.history is rendered by a gate object:
"""

# ╔═╡ 104438b2-1ad4-4ec8-89eb-e5c0b3225525
struct Gate
	ins :: Vector
    outs:: Vector
end

# ╔═╡ ec968447-7496-42c4-b5b7-5fda3e899e29
function Gadfly.render(G::Gate, x₁, y₁, y₀; rᵢ=0.1, rₒ=0.25)
    ipoints = [(i, y₀+rᵢ) for i in G.ins]
    opoints = [(i, y₀+0.5) for i in G.outs]
    igates  = [Compose.circle(i..., rᵢ) for i in ipoints]
    ogates  = [Compose.circle(i..., rₒ) for i in opoints]
    lines = [line([i, j]) for i in ipoints, j in opoints]
    compose(context(units=UnitBox(0.5,0,x₁,y₁+1)),
    compose(context(), stroke(colorant"black"), fill(colorant"white"),
            igates..., ogates...),
    compose(context(), linewidth(0.3mm), stroke(colorant"black"),
            lines...))
end

# ╔═╡ 4bf453fe-97a2-4f28-ad46-f10eb253cc8b
function Gadfly.render(A::DummyArray)
    #Scan to find maximum depth
    olast = depth = 0
    for y in A.history
        (any(y[1] .≤ olast)) && (depth += 1)
        olast = maximum(y[2])
    end
    maxdepth = depth
    
    olast = depth = 0
    C = []
    for y in A.history
        (any(y[1] .≤ olast)) && (depth += 1)
        push!(C, render(Gate(y...), A.length, maxdepth, depth))
        olast = maximum(y[2])
    end
    
    push!(C, compose(context(units=UnitBox(0.5,0,A.length,1)),
      [line([(i,0), (i,1)]) for i=1:A.length]...,
    linewidth(0.1mm), stroke(colorant"grey")))
    compose(context(), C...)
end

# ╔═╡ 8c9cfbd2-96e1-4d76-9b09-a5c35e5a5e17
render(Gate([1,2],[2]),2,0,0)

# ╔═╡ d9b1b5b9-3415-4fcf-96c7-e22628e51e4c
render(prefix!(DummyArray(8), +))

# ╔═╡ 0e4afe65-a002-48b0-9206-8f9e36954dff
md"""
Now we can see that prefix! rearranges the operations to form two spanning trees:
"""

# ╔═╡ 56dfc572-3a75-4846-bb41-811c4ddb42f8
render(prefix!(DummyArray(120),+))

# ╔═╡ fdb173ff-2aea-443d-a99b-ed5f95279edb
render(prefix!(DummyArray(9),+))

# ╔═╡ 9f7e6763-e2ef-424e-8dee-0aebf3f74816
render(prefix_serial!(DummyArray(8),+))

# ╔═╡ d40c697d-89d2-4194-974e-ef778baa5d7b
npp = @bind npp Slider(1:180; default=20, show_value=true)

# ╔═╡ 7b48451a-028c-48a4-ba9e-5975cbd656d4
render(prefix!(DummyArray(npp),+))

# ╔═╡ cf94afa3-779d-4c4e-bd24-2e86d923d337
render(prefix_serial!(DummyArray(npp),+))

# ╔═╡ c5ccea9d-1a5f-4a9c-8424-5904532b35af


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Compose = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
Gadfly = "c91e804a-d5a3-530f-b6f0-dfbca275c004"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StatsBase = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"

[compat]
Compose = "~0.9.5"
Gadfly = "~1.3.4"
PlutoUI = "~0.7.50"
StatsBase = "~0.33.21"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.0-beta4"
manifest_format = "2.0"
project_hash = "3e60f8dcaee4de8869f3f9ad572cc1ea45f809de"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cc37d689f599e8df4f464b2fa3870ff7db7492ef"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.6.1"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "5084cc1a28976dd1642c9f337b28a3cb03e0f7d2"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.7"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c6d890a52d2c4d55d326439580c3b8d0875a77d9"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.7"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "7a60c856b9fa189eb34f5f8a6f6b5529b7942957"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.2+0"

[[deps.Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "bf6570a34c850f99407b494757f5d7ad233a7257"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.5"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.CoupledFields]]
deps = ["LinearAlgebra", "Statistics", "StatsBase"]
git-tree-sha1 = "6c9671364c68c1158ac2524ac881536195b7e7bc"
uuid = "7ad07ef1-bdf2-5661-9d2b-286fd4296dac"
version = "0.2.0"

[[deps.DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "da9e1a9058f8d3eec3a8c9fe4faacfb89180066b"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.86"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "f9818144ce7c8c41edf5c4c179c684d92aa4d9fe"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.6.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "d3ba08ab64bdfd27234d3f61956c966266757fe6"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.7"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.Gadfly]]
deps = ["Base64", "CategoricalArrays", "Colors", "Compose", "Contour", "CoupledFields", "DataAPI", "DataStructures", "Dates", "Distributions", "DocStringExtensions", "Hexagons", "IndirectArrays", "IterTools", "JSON", "Juno", "KernelDensity", "LinearAlgebra", "Loess", "Measures", "Printf", "REPL", "Random", "Requires", "Showoff", "Statistics"]
git-tree-sha1 = "13b402ae74c0558a83c02daa2f3314ddb2d515d3"
uuid = "c91e804a-d5a3-530f-b6f0-dfbca275c004"
version = "1.3.4"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.Hexagons]]
deps = ["Test"]
git-tree-sha1 = "de4a6f9e7c4710ced6838ca906f81905f7385fd6"
uuid = "a1b4810d-1bce-5fbd-ac56-80944d57a21f"
version = "0.2.0"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "721ec2cf720536ad005cb38f50dbba7b02419a15"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.7"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.Juno]]
deps = ["Base64", "Logging", "Media", "Profile"]
git-tree-sha1 = "07cb43290a840908a771552911a6274bc6c072c7"
uuid = "e5e0dc1b-0480-54bc-9374-aad01c23163d"
version = "0.8.4"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "9816b296736292a80b9a3200eb7fbb57aaa3917a"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.5"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Loess]]
deps = ["Distances", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "46efcea75c890e5d820e670516dc156689851722"
uuid = "4345ca2d-374a-55d4-8d30-97f9976e7612"
version = "0.5.4"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "0a1b7c2863e44523180fdb3146534e265a91870b"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.23"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "2ce8695e1e699b68702c03402672a69f54b8aca9"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.2.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.Media]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "75a54abd10709c01f1b86b84ec225d26e840ed58"
uuid = "e89f7d12-3494-54d1-8411-f7d8b9ae1f27"
version = "0.5.0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "82d7c9e310fe55aa54996e6f7f94674e2a38fcb4"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.9"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "67eae2738d63117a196f497d7db789821bce61d1"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.17"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "478ac6c952fddd4399e71d4779797c538d0ff2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.8"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "5bb5129fdd62a2bbbe17c2756932259acf467386"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.50"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "786efa36b7eff813723c4849c90456609cf06661"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.8.1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "f65dcb5fa46aee0cf9ed6274ccbd597adc49aa7b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.1"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6ed52fdd3382cf21947b15e8870ac0ddbff736da"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.4.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "ef28127915f4229c971eb43f3fc075dd3fe91880"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.2.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "2d7d9e1ddadc8407ffd460e24218e37ef52dd9a3"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.16"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "f625d686d5a88bcd2b15cd81f18f98186fdc0c9a"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.0"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.4.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═01ab2b8f-cb97-425b-9c43-e7f2889dfb7d
# ╟─531b3af5-07e1-4823-818d-ab540865494b
# ╟─5e3f0741-fe66-4ccb-822f-63cda1b2c89b
# ╟─b5fb46e8-ff75-4eb1-ba63-92e3b4a764fe
# ╠═2670e66e-bc2a-11ed-2f25-c554deffd3bf
# ╟─4a77c84d-6a7b-4dd3-8701-ab405adb364b
# ╠═ee52bbc2-1e4a-47e4-8b43-8cb0e730069d
# ╟─206df737-3eb2-4275-861a-a0ba958c23d1
# ╠═d3e62a10-69ef-47c3-8ab3-4d1299bbfc82
# ╠═82b5c025-9ae1-461e-bf88-c6be0ed093f7
# ╟─36a0f36a-1d3f-40c8-8514-7a94ad7ea5c9
# ╠═ab0a8204-65ee-459d-98be-6087187b4096
# ╟─6a673be9-c6c0-4dce-b970-74f3e68fc990
# ╠═a2642146-a331-48a2-9a6c-850b3debe241
# ╠═0e1005c7-47b7-493f-99e6-be069e944c8b
# ╟─829b05e4-df24-46ed-981a-2bee358ae0aa
# ╟─d0ba43bc-18e4-4ccc-aa9d-d83285ea59b2
# ╠═8839cc30-2d1d-4c43-bccf-82944ee2a166
# ╠═e5e40188-08df-4b82-a776-86e645f925ff
# ╠═56d09724-e48f-4003-a168-0ef2e000e2ec
# ╠═5c285f77-31e6-4636-8702-7e99ed173491
# ╠═b07ded7a-21fb-4bcf-a4a7-96d6c73a0ee8
# ╠═3a93cb87-6e17-4fe4-a87c-db3ceb1a9fb8
# ╠═7d3b7168-ceea-484a-831b-dbf53dd3ac10
# ╠═61e583f4-b9f9-4727-bd0c-07360382cbf6
# ╟─47c9d5a3-274b-4612-a835-db3fadd3373e
# ╠═861d9a43-24c9-4cec-b82f-94a1b547c5b8
# ╠═7ba55f3d-509f-41a8-af58-95f3293ebe96
# ╠═e7a16f12-4d98-4caf-9161-31035d971ec3
# ╠═e6fffc89-420d-40af-b9ab-d23a56a72bf3
# ╠═3738164e-73d3-4b13-8386-26d1dfca3983
# ╟─bd0267c5-2047-43e4-851e-dadfc25d1ed9
# ╠═8322a1cf-0236-49b3-a169-f8ae7b4eedb7
# ╠═434211b7-1055-47d2-aa44-b4b2d9f97203
# ╠═be349102-60fc-4d27-aa5a-f1f74a96109b
# ╟─05d88bce-6bf7-415c-bee1-a45f8eeb0b34
# ╠═96b1616b-9ea6-4a11-b4b2-9a4464c36ab9
# ╠═f2d04cda-df53-4867-ac56-f597267cc807
# ╠═be1208cb-1621-469a-b41a-d7411f66e91d
# ╟─947d4c14-dd06-41ba-9edf-e09b9c55aacb
# ╠═a9aa8aec-c265-4bf9-9b15-1c810cbb0b7e
# ╠═087e4786-a933-47df-8526-60d20df63271
# ╠═54f9bed6-37f0-4b9e-901c-f4c5fb9ca2ba
# ╠═bdf9341c-ec26-423e-985d-834903c2eac0
# ╠═af31d1d7-ae8e-4400-aeb4-cb42ce0c4ec7
# ╟─8eec5baf-02a8-4414-a761-37612bbccae9
# ╠═104438b2-1ad4-4ec8-89eb-e5c0b3225525
# ╠═ec968447-7496-42c4-b5b7-5fda3e899e29
# ╠═8c9cfbd2-96e1-4d76-9b09-a5c35e5a5e17
# ╠═4bf453fe-97a2-4f28-ad46-f10eb253cc8b
# ╠═d9b1b5b9-3415-4fcf-96c7-e22628e51e4c
# ╟─0e4afe65-a002-48b0-9206-8f9e36954dff
# ╠═56dfc572-3a75-4846-bb41-811c4ddb42f8
# ╠═fdb173ff-2aea-443d-a99b-ed5f95279edb
# ╠═9f7e6763-e2ef-424e-8dee-0aebf3f74816
# ╠═d40c697d-89d2-4194-974e-ef778baa5d7b
# ╠═7b48451a-028c-48a4-ba9e-5975cbd656d4
# ╠═cf94afa3-779d-4c4e-bd24-2e86d923d337
# ╠═c5ccea9d-1a5f-4a9c-8424-5904532b35af
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
