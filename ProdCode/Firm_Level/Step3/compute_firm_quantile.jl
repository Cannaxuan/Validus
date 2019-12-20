function compute_firm_quantile(PD_target, pdAllForwardtemp, dateVctr, firmInfo, CfirmInfo)
    # CfirmInfo = VfirmInfo[i,:]
    FirmInfo  = [CfirmInfo'; firmInfo]
    idxnnan   = .!isnan.(PD_target[:, 2])
    firmmonth = PD_target[idxnnan, 2]*100 + PD_target[idxnnan, 3]
    PD_value  = PD_target[:, 15]         ## one year pd for specific firm
    PD_value  = hcat(PD_value, fill(CfirmInfo[4], length(PD_value)))    ## pd and category for specific firm

    concat = cat(PD_value, pdAllForwardtemp, dims = 3)  ## pd and category for specific firm and all firms
    category = CfirmInfo[4]
    idx1, idx2 = ismember_CK(firmmonth, dateVctr)
    idx = Int.(idx2[idx1])

    PDsamplevalue = concat[idx, 1, :]   ## pd calue for specific firm and all firms
    PDsample = concat[idx, end, :]      ## category for specific firm and all firms
    idx3 = PDsample .== category
    PDsamplevalueCat = fill(NaN, size(PDsamplevalue))
    PDsamplevalueCat[idx3] = PDsamplevalue[idx3]    ## pd in specific category

    result = Dict{String, Any}("global" => Vector{Float64}(undef, length(PD_value[idx])),
                             "category" => Vector{Float64}(undef, length(PD_value[idx])),
                        "selectedEcons" => Vector{Float64}(undef, length(PD_value[idx])),
                            "industry"  => Vector{Float64}(undef, length(PD_value[idx])),
            "selectedEconsPlusindustry" => Vector{Float64}(undef, length(PD_value[idx])))
    idxecon = in.(FirmInfo[:, 4], [smeEcon])
    idxind = in.(FirmInfo[:, 5], [CfirmInfo[5]])

    # for i = 1:length(PD_value[idx])
    #     # global result
    #     result["global"][i]        = invprctile(PDsamplevalue[i, :], PD_value[idx][i])
    #     result["category"][i]      = invprctile(PDsamplevalueCat[i, :], PD_value[idx][i])
    #     result["selectedEcons"][i] = invprctile(PDsamplevalue[i, idxecon], PD_value[idx][i])
    #     result["industry"][i]      = invprctile(PDsamplevalue[i, idxind], PD_value[idx][i])
    #     result["selectedEconsPlusindustry"][i] = invprctile(PDsamplevalue[i, idxind .& idxecon], PD_value[idx][i])
    # end


    for i = 1:length(PD_value[idx])
        # global result
        result["global"][i]       = ecdf(PDsamplevalue[i, .!isnan.(PDsamplevalue[i, :])])(PD_value[idx][i])
        result["category"][i]     = ecdf(PDsamplevalueCat[i,.!isnan.(PDsamplevalueCat[i, :])])(PD_value[idx][i])
        temp = PDsamplevalue[i, idxecon]
        result["selectedEcons"][i] = ecdf(temp[.!isnan.(temp)])(PD_value[idx][i])
        temp = PDsamplevalue[i, idxind]
        result["industry"][i]      = ecdf(temp[.!isnan.(temp)])(PD_value[idx][i])
        temp = PDsamplevalue[i, idxind .& idxecon]
        result["selectedEconsPlusindustry"][i] = ecdf(temp[.!isnan.(temp)])(PD_value[idx][i])
    end

    idxnnan  = idxnnan[end-288:end]
    PD_value = PD_value[end-288:end, 1]
    PD_value = PD_value[idxnnan]

    # ratingInfo = [0.245853923394787,    0.203616617275811,    0.134897937679463,    0.0778971777030607,
    #               0.0651299373754783,   0.0403539617005870,   0.0258017531755370,   0.0173956492215458,
    #               0.0102996250234016,   0.00716071000166653,  0.00388485396068186,  0.00323634856450953,
    #               0.00192376960708118,  0.00121947256433667,  0.000689363350530429, 0.000557634533024014,
    #               0.000280450073188865, 0.000251008207546459, 0.000131855822973180, 8.51440735156198e-05, 0]
    ratingInfo = [0.241846595625212,    0.216913689282206,      0.142755407352768,      0.0906071846877179,
                  0.0601311477593212,   0.0427536630685202,     0.0242207667575655,     0.0194007161382579,
                  0.00969030341428040,  0.00817223023188932,    0.00474772847109520,    0.00275439987056690,
                  0.00193970547936108,  0.00143346206370537,    0.000677048341161129,   0.000504182888438589,
                  0.000259536764631294, 0.000221850864402803,   0.000124989931870574,   9.02111295248055e-05, 0]
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
