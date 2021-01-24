@inline function loss(y, γ, ϵ)
    yγ = y .⊻ γ
    sum(log.(ϵ .^ yγ) .+ log.((1 - ϵ) .^ (1 .⊻ yγ)))
end

function text_recognition(dir::String)
    Σ = "abcdefghijklmnopqrtsuvwxyz "
    Ε = Dict(i => joinpath(
        dir, "alphabet", "$(i == ' ' ? "space" : i).png"
    ) |> load |> channelview for i in Σ) # Etalon images.

    jp = JSON.parsefile(joinpath(dir, "frequencies.json"))
    den = jp |> values |> sum
    map!(i -> i / den, jp |> values) # Joint probability.
    cp = Dict{String, Float64}() # Conditional probability p(b|a).
    for a in Σ
        pa = mapreduce(b -> "$a$b" in keys(jp) ? jp["$a$b"] : 0, +, Σ)
        for b in Σ cp["$b$a"] = "$a$b" in keys(jp) ? jp["$a$b"] / pa : 0 end
    end

    image = joinpath(dir, "input", "very simple text_0.3.png") |> load |> channelview
    image_letters = [image[:, i + 1:i + 28] for i in 0:28:size(image)[2] - 28]
    noise = 0.3

    f = fill(-Inf64, length(image_letters), length(Σ))
    for (i, c) in enumerate(Σ)
        f[1, i] = log(cp["$c "]) + loss(image_letters[1], Ε[c], noise)
    end
    for (i, nl) in enumerate(image_letters), (s1, σ1) in enumerate(Σ)
        isinf(f[i, s1]) && continue
        i == length(image_letters) && break
        for (s2, σ2) in enumerate(Σ)
            p = log(cp["$σ2$σ1"]) + loss(image_letters[i + 1], Ε[σ2], noise) + f[i, s1]
            p > f[i + 1, s2] && (f[i + 1, s2] = p;)
        end
    end
    for i in 1:length(image_letters) print(Σ[f[i, :] |> argmax]) end
end
