function load_dataset(path::String)
    dataset = path |> read |> String |> JSON.parse
    inside = hcat(dataset["inside"]...) .|> Float32
    outside = hcat(dataset["outside"]...) .|> Float32
    x = hcat(inside, outside)
    y = BitVector(undef, size(x)[2])
    y[1:size(inside)[2]] .= true
    y[size(inside)[2] + 1:end] .= false
    x, y
end

# Polynomial kernel function.
@inbounds function ∻(x::Matrix{Float32})::Matrix{Float32}
    μ = ones(Float32, 6, size(x)[2])
    μ[1, :] .= x[1, :] .^ 2
    μ[2, :] .= x[2, :] .^ 2
    μ[3, :] .= x[1, :] .* x[2, :]
    μ[4, :] .= x[1, :]
    μ[5, :] .= x[2, :]
    μ
end

struct Perceptron
    θ::Vector{Float32}
    Perceptron() = new(zeros(Float32, 6))
end

function train!(p::Perceptron, x::Matrix{Float32}, y::BitVector)
    Ω = x |> ∻
    @inbounds @simd for i in 1:length(y) # Reduce to one class.
        y[i] && (Ω[:, i] .= -Ω[:, i])
    end
    done = false
    while !done
        done = true
        @inbounds for i in 1:length(y)
            ω = p.θ ⋅ Ω[:, i]
            ω ≤ 0f0 && (p.θ .+= Ω[:, i]; done = false)
        end
    end
end

function test(p::Perceptron, x::Matrix{Float32})
    Ω, y = x |> ∻, BitVector(undef, size(x)[2])
    @inbounds @simd for i in 1:length(y)
        y[i] = (p.θ ⋅ Ω[:, i]) ≤ 0f0
    end
    y
end

function separate(x::Matrix{Float32}, y::BitVector)
    p = Perceptron()
    train!(p, x, y)
    y_test = test(p, x)
    @info y_test

    c = scatter(x[1, y_test], x[2, y_test], color=:red)
    scatter!(c, x[1, .!y_test], x[2, .!y_test], color=:green)
    display(c)
    readline()
end

function separate()
    res_dir = raw"C:\Users\tonys\projects\julia\PatRec\res\supervised"
    x, y = joinpath(res_dir, "train_01.json") |> load_dataset
    separate(x, y)
    x, y = joinpath(res_dir, "train_02.json") |> load_dataset
    separate(x, y)
end
