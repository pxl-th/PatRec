function henlo()
    op_mapping = Dict{String, Function}("-" => -, "+" => +, "*" => *)
    start_json = Dict("data" => Dict("message" => "Let's start")) |> JSON.json
    answer_json = Dict("data" => Dict("answer" => 0))

    HTTP.WebSockets.open("wss://sprs.herokuapp.com/zeroth/pxl-th") do ws
        write(ws, start_json)
        response = ws |> read_parse

        operands = response["data"]["operands"]
        op = op_mapping[response["data"]["operator"]]
        answer_json["data"]["answer"] = op(operands[1], operands[2])

        write(ws, answer_json |> JSON.json)
        response = ws |> read_parse
        @show response
    end
end

function recognize(
    image::BitMatrix, labels::Dict{String, BitMatrix}, ϵ::Float32,
)::String
    max_loss, class = 0f0, 0b0
    for (l, target) in labels
        s = image .⊻ target
        cl = sum(s) * ϵ + sum(0b1 .⊻ s) * (1f0 - ϵ)
        max_loss < cl && (max_loss = cl; class = l)
    end
    class
end

function binary(;
    scale::Integer = 1, steps::Integer = 1, ϵ::Real = 0f0,
    shuffle::Bool = false,
)
    start_json = Dict("data" => Dict("message" => "Let's start")) |> JSON.json
    ready_json = Dict("data" => Dict("message" => "Ready")) |> JSON.json
    bye_json = Dict("data" => Dict("message" => "Bye")) |> JSON.json
    config_json = Dict("data" => Dict(
        "height" => scale, "width" => scale,
        "totalSteps" => steps, "noise" => ϵ, "shuffle" => shuffle,
    )) |> JSON.json
    answer_json = Dict("data" => Dict("step" => 0, "answer" => "0"))

    HTTP.WebSockets.open("wss://sprs.herokuapp.com/first/pxl-th") do ws
        write(ws, start_json)
        response = ws |> read_parse

        width = scale * response["data"]["width"]
        height = scale * response["data"]["height"]
        total_images = response["data"]["number"]

        write(ws, config_json)
        response = ws |> read_parse
        labels = Dict{String, BitMatrix}(
            n => preprocess(i) for (n, i) in response["data"]
        )

        for step in 1:steps
            write(ws, ready_json)
            response = ws |> read_parse
            image = response["data"]["matrix"] |> preprocess
            class = recognize(image, labels, ϵ)

            answer_json["data"]["step"] = response["data"]["currentStep"]
            answer_json["data"]["answer"] = class
            write(ws, answer_json |> JSON.json)

            ws |> readavailable
        end

        write(ws, bye_json)
        response = ws |> read_parse
        successes = response["data"]["successes"]
        println("Total steps: $steps, Successes: $successes")
    end
end

function place_aid!(guesses::Vector{UInt32}, heatmap::Vector{Float32})
    heatmap ./= heatmap |> sum
    fill!(guesses, ((heatmap |> cumsum) .≥ 0.5f0) |> findfirst)
end

function l1(;width::Integer = 2, steps::Integer = 1, repeats::Integer = 1)
    guesses = Vector{UInt32}(undef, repeats)

    start_json = Dict("data" => Dict(
        "width" => width, "loss" => "L1",
        "totalSteps" => steps, "repeats" => repeats,
    )) |> JSON.json
    ready_json = Dict("data" => Dict("message" => "Ready")) |> JSON.json
    answer_json = Dict("data" => Dict("step" => 0, "guesses" => guesses))
    bye_json = Dict("data" => Dict("message" => "Bye")) |> JSON.json

    HTTP.WebSockets.open("wss://sprs.herokuapp.com/second/pxl-th") do ws
        write(ws, start_json)
        ws |> readavailable

        for step in 1:steps
            write(ws, ready_json)
            response = ws |> read_parse

            heatmap = response["data"]["heatmap"] .|> Float32
            place_aid!(guesses, heatmap)

            answer_json["data"]["step"] = step
            answer_json["data"]["guesses"] = guesses
            write(ws, answer_json |> JSON.json)

            ws |> readavailable
        end

        write(ws, bye_json)
        response = ws |> read_parse
        total_loss = response["data"]["loss"]
        println("Total loss: $total_loss")
    end
end
