function compute_firm_quantile(PD_target, pdAllForwardtemp, dateVctr, firmInfo, CfirmInfo)
    # CfirmInfo = VfirmInfo[i,:]
    FirmInfo = [CfirmInfo'; firmInfo]
    idxnnan = .!isnan.(PD_target[:, 2])
    firmmonth = PD_target[idxnnan, 2]*100 + PD_target[idxnnan, 3]
    PD_value = PD_target[:, 15]
    PD_value = hcat(PD_value, fill(CfirmInfo[4], length(PD_value)))

    concat = cat(PD_value, pdAllForwardtemp, dims = 3)
    category = CfirmInfo[4]
    idx1, idx2 = ismember_CK(firmmonth, dateVctr)
    idx = Int.(idx2[idx1])

    PDsamplevalue = concat[idx, 1, :]
    PDsample = concat[idx, end, :]
    idx3 = PDsample .== category
    PDsamplevalueCat = fill(NaN, size(PDsamplevalue))
    PDsamplevalueCat[idx3] = PDsamplevalue[idx3]

    result = Dict{String, Any}("global" => Vector{Float64}(undef, length(PD_value[idx])),
                  "category" => Vector{Float64}(undef, length(PD_value[idx])),
                  "selectedEcons" => Vector{Float64}(undef, length(PD_value[idx])),
                  "industry" => Vector{Float64}(undef, length(PD_value[idx])),
                  "selectedEconsPlusindustry" => Vector{Float64}(undef, length(PD_value[idx])))
    idxecon = in.(FirmInfo[:, 4], [smeEcon])
    idxind = in.(FirmInfo[:, 5], [CfirmInfo[5]])

    for i = 1:length(PD_value[idx])
        # global result
        result["global"][i] = invprctile(PDsamplevalue[i, :], PD_value[idx][i])
        result["category"][i] = invprctile(PDsamplevalueCat[i, :], PD_value[idx][i])
        result["selectedEcons"][i] = invprctile(PDsamplevalue[i, idxecon], PD_value[idx][i])
        result["industry"][i] = invprctile(PDsamplevalue[i, idxind], PD_value[idx][i])
        result["selectedEconsPlusindustry"][i] = invprctile(PDsamplevalue[i, idxind .& idxecon], PD_value[idx][i])
    end
    idxnnan = idxnnan[end-288:end]
    PD_value = PD_value[end-288:end, 1]
    PD_value = PD_value[idxnnan]

    ratingInfo = [0.245853923394787,    0.203616617275811,    0.134897937679463,    0.0778971777030607,
                  0.0651299373754783,   0.0403539617005870,   0.0258017531755370,   0.0173956492215458,
                  0.0102996250234016,   0.00716071000166653,  0.00388485396068186,  0.00323634856450953,
                  0.00192376960708118,  0.00121947256433667,  0.000689363350530429, 0.000557634533024014,
                  0.000280450073188865, 0.000251008207546459, 0.000131855822973180, 8.51440735156198e-05, 0]
    NamesCell = ["C", "CC", "CCC-", "CCC", "CCC+", "B-", "B", "B+", "BB-", "BB", "BB+", "BBB-", "BBB", "BBB+",
                 "A-", "A", "A+", "AA-", "AA", "AA+", "AAA"]

    result["PDiR"] = Vector{Any}(undef, length(PD_value))
    for i = 1:length(PD_value)
        if !isnan(PD_value[i])
            ix = findfirst(PD_value[i] .>= ratingInfo)
            result["PDiR"][i] = NamesCell[ix]
        else
            result["PDiR"][i] = NaN
        end
    end
    return result
end
