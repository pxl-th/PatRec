module PatRec

using HTTP
import JSON

@inline read_parse(ws) = ws |> readavailable |> String |> JSON.parse
@inline preprocess(i)::BitMatrix = hcat(i...) .|> Bool |> transpose

include("first.jl")
include("second.jl")

# First practicum.
# henlo()
# binary(;steps=10, ϵ=0.0f0, scale=2)
# l1(;width=10, steps=10, repeats=5)

# Second practicum.
separate()

end
