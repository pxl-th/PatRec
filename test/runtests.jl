using Test
using PatRec

@testset "Binary recognition" begin
    labels = Dict{String, BitMatrix}(
        "0" => Bool[0 0; 0 0],
        "1" => Bool[1 0; 1 0],
        "2" => Bool[1 1; 1 1],
    )
    for (k, image) in labels
        @test PatRec.recognize(image, labels, 0f0) == k
    end
end
