function nanSum(data::Array)
    # compute sum of data while ignoring NAN values
    # by Caesar

    data = data[.!isnan.(data)][:]
    su = sum(data)

    return su
end


function nanSum(data::Matrix, dim::Int)
    # compute sum of data while ignoring NAN values
    # by Caesar

    if dim == 1
        su = map(i -> try sum(data[.!isnan.(data[:, i]), i]) catch; NaN end, 1:size(data, 2))
    else
        su = map(i -> try sum(data[i, .!isnan.(data[i, :])]) catch; NaN end, 1:size(data, 1))
    end

    return su

end



function nanSum(data::Array{T, 3} where T, dim::Int)
    # compute sum of a matrix along certain dimension while ignoring NAN values
    # by Caesar

    if dim == 1
        su = map(i -> try nanSum(data[:, :, i], 1) catch; NaN end, 1:size(data, 3))
        su = hcat(su...)
    elseif dim == 2
        data = permutedims(data, [2, 1, 3])
        su = map(i -> try nanSum(data[:, :, i], 1) catch; NaN end, 1:size(data, 3))
        su = hcat(su...)
    else
        data = permutedims(data, [3, 1, 2])
        su = map(i -> try nanSum(data[:, :, i], 1) catch; NaN end, 1:size(data, 3))
        su = hcat(su...)
    end

    return su
end
