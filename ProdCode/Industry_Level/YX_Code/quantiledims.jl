function quantiledims(pdarray, quant, dims)
    if isempty(pdarray)
        qpd = NaN
    else
        if dims == 1
            qpd = Vector{Float64}(undef, size(pdarray, 2))
            for i = 1:length(qpd)
                qpd[i] = isempty(pdarray[.!isnan.(pdarray[:,i], :)]) ? NaN : quantile(pdarray[.!isnan.(pdarray[:, i]), i], quant)
            end

        elseif dims == 2
            qpd = Vector{Float64}(undef, size(pdarray, 1))
            for i = 1:length(qpd)
                qpd[i] = isempty(pdarray[i, .!isnan.(pdarray[i,:])]) ? NaN : quantile(pdarray[i, .!isnan.(pdarray[i, :])], quant)
            end
        end
    end
    return qpd
end
