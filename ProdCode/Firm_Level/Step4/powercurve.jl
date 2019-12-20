"""
[PC, AR] = powercurve(PD, firmlist, horizon)
Input:
       1. "PD": the PD for each firm in one country in each horizon
          (3-dim matrix, firmTimeperiod * one * firmNumber)
       2. "firmlist": the firm matrix in each country or group
       3. "horizon": horizon from 1 to GC.MAX_HORIZON

Output:
       1. "PC": PC matrix [2 * GC.MAX_HORIZON]
       2. "AR": Accurate ratio matrix [10000 * GC.MAX_HORIZON].

Description:
       This function is a subfunction of ar_calculate_fig[]. It
       calculates the AR.
"""
function powercurve(PD::Array{Float64,2}, firmlist::Array{Float64,2}, horizon::Int64)

    nFirms = size(firmlist,1)
    T = Int(maximum(firmlist[:,2]))
    numDef = 0
    k = 1
    prob = zeros(nFirms*T, 2)

    for t = 1 : T - horizon + 1
        for iFirms = 1 : nFirms
            # if firmlist[iFirms, 1] <= t && firmlist[iFirms, 2] >= t && isfinite(PD[t, 1, iFirms])
            # prob[k, 1] = PD[t, 1, iFirms]
            if firmlist[iFirms, 1] <= t && firmlist[iFirms, 2] >= t && isfinite(PD[t, iFirms])
                prob[k, 1] = PD[t, iFirms]
                if firmlist[iFirms, 2] <= t + horizon - 1 && firmlist[iFirms, 3] == 1
                    prob[k, 2] = 1
                    if firmlist[iFirms, 2] == t + horizon - 1
                        numDef = numDef + 1
                    end
                end
                k = k + 1
            end
        end
    end

    k = k - 1
    if k==0
        return NaN,NaN
    end
    prob = prob[1 : k, :]
    IX = sortperm(prob[:, 1], rev=true)

    defOrderPD = prob[IX, 2]

    y = cumsum(defOrderPD)

    normalisedY = y / y[end]


    tmpIdx = convert(Array{Int,2},round.(k * (1 : min(2 * k - 1, 10000))' / min(2 * k - 1, 10000)))'

    PC = normalisedY[tmpIdx]

    AR = fill!(Array{Float64}(undef, 2,1),NaN)

    perf = cumsum(sort(prob[:, 2], rev=true))
    normalisedPerf = perf / perf[end]
    AR[1] = (sum(normalisedY) / k - 0.5) / (sum(normalisedPerf)/ k - 0.5)
    AR[2] = sum(normalisedY) / sum(normalisedPerf)

    return PC, AR, length(y), y[end]
end
