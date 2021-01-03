module PatRec

using Random
using LinearAlgebra
using HTTP
import JSON
using MLDatasets
using ConstraintSolver
using JuMP
using Plots
gr()

Random.seed!(0)

include("first.jl")
include("second.jl")
include("third.jl")
include("fourth.jl")

# First practicum.
# henlo()
# binary(;steps=10, ϵ=0.0f0, scale=2)
# l1(;width=10, steps=10, repeats=5)

# Second practicum.
# separate()

# Third practicum.
# em(4, 2, 5)

# Fourth practicum.
initial_solution = [
    5 3 0 0 7 0 0 0 0;
    6 0 0 1 9 5 0 0 0;
    0 9 8 0 0 0 0 6 0;
    8 0 0 0 6 0 0 0 3;
    4 0 0 8 0 3 0 0 1;
    7 0 0 0 2 0 0 0 6;
    0 6 0 0 0 0 2 8 0;
    0 0 0 4 1 9 0 0 5;
    0 0 0 0 8 0 0 7 9;
]
solution = sudoku(initial_solution)
display(initial_solution)
display(solution)

end
