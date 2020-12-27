function preprocess(n1::Integer, n2::Integer)
    train_x, train_y = MNIST.traindata()
    test_x, test_y = MNIST.testdata()

    train_idx = findall(x -> x == n1 || x == n2, train_y)
    test_idx = findall(x -> x == n1 || x == n2, test_y)

    train_x = reshape(train_x[:, :, train_idx] .≥ 0.5f0, :, train_idx |> length)
    test_x = reshape(test_x[:, :, test_idx] .≥ 0.5f0, :, test_idx |> length)
    test_y = test_y[test_idx]

    train_x, test_x, test_y
end

"""
P (1, K)
C (I, K)
"""
function init(data)
    n = size(data)[2]
    C = Matrix{Float64}(undef, size(data)[1], 2)

    P = rand(2)
    P ./= P |> sum

    c = rand(n, 2)
    c ./= sum(c, dims=2)
    C .= sum(c, dims=1) ./ n

    reshape(P, 1, 2), C
end

"""
Expectation step.
E (N, K)
"""
function e(data, P, C)
    @inbounds E = [
        prod(C[:, k] .^ data[:, i] .* (1 .- C[:, k]) .^ (1 .- data[:, i]))
        for i in 1:size(data)[2], k in 1:2
    ] .* P
    E ./= sum(E, dims=2)
end

"""
Maximization step.
data (I, N)
Ce (N, K)

P (1, K)
C (I, K)
"""
function m(data, Ce)
    M, C = sum(Ce, dims=1), Matrix{Float64}(undef, size(data)[1], 2)
    @inbounds @simd for k in 1:2
        C[:, k] .= sum(data .* reshape(Ce[:, k], 1, :), dims=2)[:, 1] / M[k]
    end
    reshape(M ./ size(data)[2], 1, 2), C
end

function eval(P, C, x, y, n1, n2)
    y_pred = map(i -> i[2], argmax(e(x, P, C), dims=2))
    n1_ids = y_pred .== 1
    y_pred[n1_ids] .= n1
    y_pred[.!n1_ids] .= n2
    sum(y_pred .== y) / length(y)
end

function em(n1::Integer, n2::Integer, steps::Integer)
    train_x, test_x, test_y = preprocess(n1, n2)
    P, C = train_x |> init
    for i in 1:steps
        Ce = e(train_x, P, C)
        P, C = m(train_x, Ce)
        accuracy = eval(P, C, test_x, test_y, n1, n2)
        println("$i / $steps | Accuracy: $accuracy")
    end
end
