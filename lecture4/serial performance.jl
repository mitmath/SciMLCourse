using LinearAlgebra, BenchmarkTools

# 1. Caches - how they impact performance
BLAS.set_num_threads(1)
n = 1000
A = randn(n,n)
B = randn(n,n)

# Rate of computation = (ops)/(time) in gigaflops
(2n^3)/(@elapsed A*A)/1e9
(n^2)/(@elapsed A.+A)/1e9

# 2. row vs column major
A = rand(100,100)
B = rand(100,100)
C = rand(100,100)

# compute row by row
function inner_rows!(C,A,B)
  for i in 1:100, j in 1:100  #
    C[i,j] = A[i,j] + B[i,j]
  end
end
@btime inner_rows!(C,A,B)

# compute column by column
function inner_cols!(C,A,B)
  for j in 1:100, i in 1:100
    C[i,j] = A[i,j] + B[i,j]
  end
end
@btime inner_cols!(C,A,B)

# 3. The stack vs the heap

# 3a.  Arrays go on the heap but have few allocations
@btime a = 100;  # This goes on the stack (0 allocations)
# All arrays live on the heap
@btime a = rand(10,10); # This creates one pointer (1 allocation)
@btime a = rand(100,10);  
@btime a = rand(100,100); # why 2 allocations? (wrapper and buffer)
@btime a = rand(1000,100); # why 2 allocations? (wrapper and buffer)
# One KiB = 1024 Bytes

#3b. An example where every element of an array needs an allocation
function lots_of_allocations(a)
    for i=1:size(a,1), j=1:size(a,2)
        val = [a[i,j]]  # <-- every step this is placed on the heap 
    end
end 

a = rand(1000,100)
@btime lots_of_allocations(a)

#4. "Mutation" to avoid heap allocations

a = rand(100,100)
b = rand(100,100)
c = similar(a)  # this is preallocated


function add_and_store(a,b)
  c = similar(a)
  for i=1:100, j=1:100
    c[i,j] = a[i,j]+b[i,j]
  end
end
@btime add_and_store(a,b);

function add_and_store!(c,a,b)  # function changes it's first argument
    for i=1:100, j=1:100
        c[i,j] = a[i,j]+b[i,j]
    end
end
@btime 

#5. Broadcasting (pointwise operations = "."wise operations)

#5a Devectorized vs. Vectorized



function applyf(x,fx)
  f(a) = a^3 + 4a^2 + 3a + 2
   for i=1:length(x)
     fx[i] = f(x[i])
   end
end

x = rand(100_000); fx=similar(x)
applyf(x,fx)
@benchmark applyf(x,fx)

f(a) = a^3 + 4a^2 + 3a + 2
@benchmark fx .= f.(x)
@benchmark @. fx= f(x)

#5b broadcasting functionality -- Julia is very consistent about this
# single argument is elementwise
exp.( rand(5,5) ) # exp of every element
exp(  rand(5,5) ) # Matrix exponential  I + A + A^2/ 2+ A^3/6+...

# two arguments with the same shape is also elementwise
A = rand(4,3)
B = rand(4,3)
A .* B  # elementwise (A*B = matmul )

# 1's are "wild carded"
A = rand(1,4)
B = rand(3,4)
A .* B

A = rand(3, 1)
B = rand(1, 4)
A .* B # outer product
A .+ B # outer sum 

A = rand(2)  # one dimensional Vector (acts like size=2,1,1 here)
B = rand(2,3,4)
size(A .+ B) 

# works with any function
f(a,b,c) = a*b+sin(c)
size( f.( rand(2) , rand(2,3,4),  rand(1,3) ) )

#6 Views, Copies, Slices, etc
A = [1 2 3;4 5 6;7 8 9]
B = A # points to A
B[1,1] = 18337
A
#MATLAB users get tripped by this one but valuable for performance

A = [1 2 3;4 5 6;7 8 9]
B = copy(A) # new allocation
B[1,1] = 18337
A

B = A[1:2,1:2] # new allocation
B[1,1] = 18337 
A

A = [1 2 3;4 5 6;7 8 9]
B = @view A[1:2,1:2] # points into A
B[1,1] = 18337
A

# Moral, slices produce new allocations, @view gives a pointer into the original array
# saving allocations is great for performance

#7 Types, Type Inference, Multiple dispatch

#7a Numbers are stored as bits
bitstring(0)
bitstring(1)
bitstring(1023)

bitstring(1.0)
bitstring('a')
parse(Int, bitstring(1))
parse(Int, bitstring(1.0)) # tries to read as decimal, too large
n = parse(Int, bitstring(1.0), base=2) # as binary it's okay
parse(Float64, bitstring(1.0)) # read the string as a julia float, not the bits
reinterpret(Float64,  n )  # recover the Float64 from the integer representation

# Moral of the story: bits are just bits, types tell you how to interepret the bits
# one more example
bitstring('a')
n = parse(Int32,bitstring('a'),base=2)
reinterpret(Char,n)

# types are critical to knowing what to do
a = 1
b = 3
a+b  # you knew how to do this in kindergarten

a = 1.0
b = 3.0
a+b  # you may not know how to do this with the bits

#7b type inference
# statically typed languages -- user specifies the type of everything
# python,matlab determines types at run time
# not knowing how much space to allocate slows things down
# could be int, float, a matrix, etc
# leads to runtime overhead in function calls and memory overhead too
# as values are allocated on the heap

# What does julia do?
# julia knows types of a and b and infers the type of c = a+b
# julia is constructed to propagate type information even if the user doesn't specify types

@code_llvm 2+5
@code_llvm 2.0+5.0
@code_llvm 2 + 5.0 # sitofp = llvm speak for "signed integer to floating point" conversion

#7c type stability
# if you know the type of the input arguments, you know the type of the output

# sqrt an interesting case study
sqrt(3)
# output is real
# type stability requires then
sqrt(-3)
sqrt(Complex(3))
sqrt(Complex(-3))
# slightly inconvenient, even annoying maybe, but important for performance

# breaking type stability
mysqrt(x) = x ≥ 0 ? sqrt(x) : sqrt(Complex(x))
mysqrt(1)
mysqrt(-1)
@code_warntype mysqrt(1) # the redoutput is to be worried about

#no type stability
plainold_sqrt(x) = x ≥ 0 ? sqrt(x) :  sqrt(x)
@code_warntype plainold_sqrt(1)

# FizzBuzz is not type stable
function fizzbuzz(i)
  if i % 15 == 0
      return("FizzBuzz")
  elseif i % 3 == 0
      return("Fizz")
  elseif i % 5 == 0
      return("Buzz")
  else
      return(i)
  end
end

fizzbuzz(100)
@code_warntype(fizzbuzz(100))

# Multiple dispatch

# 7b Example with fake roman numerals
struct Roman 
    n::Int
end

# Cool roman numeral printing magic (0:9 for demo only)
import Base: promote_rule, convert, show
Base.show(io::IO, r::Roman) = print(io,r.n%10==0 ? '0' : 'ⅰ'+r.n%10-1)

[Roman(1) Roman(2) Roman(5) Roman(9) ]  #Exercise: make work past single digits

import Base.*
*(i::Roman,j::Roman)  = Roman(i.n*j.n)                     # Multiply like a Roman
*(i::Number,j::Roman) = Matrix(I,i,i)*j.n                  # Multiply like a matrix constructor
*(i::Roman,j::Number) = join(['😸' for k=1:(i.n)*j])       # Multiply with 😸's

Roman(2)*Roman(3)                      
2 * Roman(3)
Roman(2) * 3

# 7c code specialization
# the code below is not type instable
# the compiler can infer the output types from the input types
function f(x)
  if x isa Int
    y = 2
  else
    y = 4.0
  end
  x + y
end

@code_warntype f(3)