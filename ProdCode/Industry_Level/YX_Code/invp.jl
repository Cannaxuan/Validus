function invp(x, q)
    invprctile = ecdf(x)
    p = invprctile(q)
    return p
end
