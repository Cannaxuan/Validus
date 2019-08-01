function compute_Var_quantile(pdAllForwardtemp, dateVctr, firmInfo, smeEcon)

    Varresult = Dict()

    oriarray = Array{Float64, 2}(undef, size(pdAllForwardtemp, 1), 2)
    oriarray[:, 1] = dateVctr
    oridict = Dict("V95" => deepcopy(oriarray), "V05" => deepcopy(oriarray))

    Varresult["global"] = deepcopy(oridict)
    Varresult["econs"] = deepcopy(oridict)
    Varresult["medium"] = deepcopy(oridict)
    Varresult["small"] = deepcopy(oridict)
    Varresult["micro"] = deepcopy(oridict)


    Varresult["global"]["V95"][:, 2] = quantiledims(pdAllForwardtemp[:, 1, :], 0.95, 2)*10000
    Varresult["global"]["V05"][:, 2] = quantiledims(pdAllForwardtemp[:, 1, :], 0.05, 2)*10000

    idx = in.(firmInfo[:, 4], [smeEcon])
    Varresult["econs"]["V95"][:, 2] = quantiledims(pdAllForwardtemp[:, 1, idx], 0.95, 2)*10000
    Varresult["econs"]["V05"][:, 2] = quantiledims(pdAllForwardtemp[:, 1, idx], 0.05, 2)*10000

    for i = 1:size(pdAllForwardtemp, 1)
        me = pdAllForwardtemp[i, 1, pdAllForwardtemp[i,2,:] .== 1]
        sm = pdAllForwardtemp[i, 1, pdAllForwardtemp[i,2,:] .== 2]
        mi = pdAllForwardtemp[i, 1, pdAllForwardtemp[i,2,:] .== 3]

        Varresult["medium"]["V95"][i, 2] = isempty(me) ? NaN : quantile(me[.!isnan.(me)], 0.95)*10000
        Varresult["medium"]["V05"][i, 2] = isempty(me) ? NaN : quantile(me[.!isnan.(me)], 0.05)*10000

        Varresult["small"]["V95"][i, 2] = isempty(sm) ? NaN : quantile(sm[.!isnan.(sm)], 0.95)*10000
        Varresult["small"]["V05"][i, 2] = isempty(sm) ? NaN : quantile(sm[.!isnan.(sm)], 0.05)*10000

        Varresult["micro"]["V95"][i, 2] = isempty(mi) ? NaN : quantile(mi[.!isnan.(mi)], 0.95)*10000
        Varresult["micro"]["V05"][i, 2] = isempty(mi) ? NaN : quantile(mi[.!isnan.(mi)], 0.05)*10000
    end

    industryArray = [10008, 10002, 10003, 10004, 10005, 10006, 10007, 10011, 10013, 10014]
    Varresult["ind"] = [deepcopy(oridict), deepcopy(oridict), deepcopy(oridict), deepcopy(oridict), deepcopy(oridict),
                        deepcopy(oridict), deepcopy(oridict), deepcopy(oridict), deepcopy(oridict), deepcopy(oridict)]
    Varresult["indecon"] = [deepcopy(oridict), deepcopy(oridict), deepcopy(oridict), deepcopy(oridict), deepcopy(oridict),
                           deepcopy(oridict), deepcopy(oridict), deepcopy(oridict), deepcopy(oridict), deepcopy(oridict)]
    idxecon = in.(firmInfo[:, 4], [smeEcon])

    for j = 1:length(industryArray)
        idx = in.(firmInfo[:, 5], [industryArray[j]])
        Varresult["ind"][j]["V95"][:, 2] = quantiledims(pdAllForwardtemp[:, 1, idx], 0.95, 2)*10000
        Varresult["ind"][j]["V05"][:, 2] = quantiledims(pdAllForwardtemp[:, 1, idx], 0.05, 2)*10000
        Varresult["indecon"][j]["V95"][:, 2] = quantiledims(pdAllForwardtemp[:, 1, idx.&idxecon], 0.95, 2)*10000
        Varresult["indecon"][j]["V05"][:, 2] = quantiledims(pdAllForwardtemp[:, 1, idx.&idxecon], 0.05, 2)*10000
    end
    return Varresult
end
