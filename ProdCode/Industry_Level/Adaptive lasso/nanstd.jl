function nanstd(data::Array)
    # compute std of data while ignoring NAN values
    # by Caesar

    data = data[.!isnan.(data)][:]
    stdv = std(data)

    return stdv
end


function nanstd(data::Matrix, dim::Int)
    # compute std of a matrix along certain dimension while ignoring NAN values
    # by Caesar

    if dim == 1
        stdv = map(i -> try std(data[.!isnan.(data[:, i]), i]) catch; NaN end, 1:size(data, 2))
    else
        stdv = map(i -> try std(data[i, .!isnan.(data[i, :])]) catch; NaN end, 1:size(data, 1))
    end

    return stdv
end


function nanstd(data::Array{T, 3} where T, dim::Int)
    # compute std of a matrix along certain dimension while ignoring NAN values
    # by Caesar

    if dim == 1
        stdv = map(i -> try nanstd(data[:, :, i], 1) catch; NaN end, 1:size(data, 3))
        stdv = hcat(stdv...)
    elseif dim == 2
        data = permutedims(data, [2, 1, 3])
        stdv = map(i -> try nanstd(data[:, :, i], 1) catch; NaN end, 1:size(data, 3))
        stdv = hcat(stdv...)
    else
        data = permutedims(data, [3, 1, 2])
        stdv = map(i -> try nanstd(data[:, :, i], 1) catch; NaN end, 1:size(data, 3))
        stdv = hcat(stdv...)
    end
    return stdv
end
