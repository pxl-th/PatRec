module PatRec

using Random
using LinearAlgebra
using HTTP
import JSON
using MLDatasets
# using Plots
# gr()

Random.seed!(0)

include("first.jl")
include("second.jl")
include("third.jl")

# First practicum.
# henlo()
# binary(;steps=10, ϵ=0.0f0, scale=2)
# l1(;width=10, steps=10, repeats=5)

# Second practicum.
# separate()

# Third practicum.
em(4, 2, 20)

end
