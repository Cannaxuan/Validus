function split_data(Arr,n)
    ## Arr: the data you want to separate.
    ## n: the number of elements/rows in each segment.

    num = size(Arr, 1)
    if num <= n
        res = Vector{Array{eltype(Arr)}}(undef, 1)
        res[1] = Arr
    else

        x, y = fldmod(num, n)
        res = Vector{Array{eltype(Arr)}}(undef, x+1)

        if ndims(Arr) == 1
            for i in 1:x
                res[i] = Arr[(i-1)*n+1:i*n]
            end
            res[end] = Arr[x*n+1:x*n+y]

        elseif ndims(Arr) == 2
            for i in 1:x
                res[i] = Arr[((i-1)*n+1:i*n), :]
            end
            res[end] = Arr[(x*n+1:x*n+y), :]

        elseif ndims(Arr) == 3
            for i in 1:x
                res[i] = Arr[((i-1)*n+1:i*n), :, :]
            end
            res[end] = Arr[(x*n+1:x*n+y), :, :]
        end
    end

    return res
end
