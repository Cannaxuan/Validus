function split_data(v,n)
    ## v: the vector you want to separate.
    ## n: the number of elements in each segment.

    num = length(v)
    x, y = fldmod(num, n)
    
    res = Vector{Vector{eltype(v)}}(undef, x+1)
    for i in 1:x
        res[i] = v[(i-1)*n+1:i*n]
    end
    res[end] = v[x*n+1:x*n+y]

    return res
end
