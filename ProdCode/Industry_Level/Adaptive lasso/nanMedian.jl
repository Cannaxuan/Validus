function nanMedian(data::Array)
    # compute median of data while ignoring NAN values
    # by Caesar

    data = data[.!isnan.(data)][:]
    mid = NaN
    try
        mid = median(data)
    catch
        mid
    end

    return mid
end


function nanMedian(data::Matrix, dim::Int)
    # compute median of data while ignoring NAN values
    # by Caesar

    if dim == 1
        mid = map(i -> try median(data[.!isnan.(data[:,i]), i]) catch; NaN end, 1:size(data, 2))
    else
        mid = map(i -> try median(data[i, .!isnan.(data[i, :])]) catch; NaN end, 1:size(data, 1))
    end

    return mid

end



function nanMedian(data::Array{T, 3} where T, dim::Int)
    # compute median of a matrix along certain dimension while ignoring NAN values
    # by Caesar

    if dim == 1
        mid = map(i -> try nanMedian(data[:, :, i], 1) catch; NaN end, 1:size(data, 3))
        mid = hcat(mid...)
    elseif dim == 2
        data = permutedims(data, [2, 1, 3])
        mid = map(i -> try nanMedian(data[:, :, i], 1) catch; NaN end, 1:size(data, 3))
        mid = hcat(mid...)
    else
        data = permutedims(data, [3, 1, 2])
        mid = map(i -> try nanMedian(data[:, :, i], 1) catch; NaN end, 1:size(data, 3))
        mid = hcat(mid...)
    end

    return mid
end
#
# nanMedian([NaN, NaN])
# data = [NaN, NaN]
# data = data[.~isnan.(data)][:]
