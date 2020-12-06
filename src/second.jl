function load_dataset(path::String)
    dataset = path |> read |> String |> JSON.parse
    dataset["inside"] = hcat(dataset["inside"]...) .|> Float32
    dataset["outside"] = hcat(dataset["outside"]...) .|> Float32
    dataset
end

function separate()
    res_dir = raw"C:\Users\tonys\projects\julia\PatRec\res\supervised"
    dataset1 = joinpath(res_dir, "train_01.json") |> load_dataset
    dataset2 = joinpath(res_dir, "train_02.json") |> load_dataset
end
