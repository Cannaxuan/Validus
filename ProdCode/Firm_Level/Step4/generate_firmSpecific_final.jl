function generate_firmSpecific_final(PathStruct, DTDmedian, beta, SampleM, FirmIndex, lb, ub, countrycode, smeindicator)
    SampleM = [FirmIndex SampleM]
    SampleM = convert(DataFrame, SampleM)
    colnames = ["CompNo", "monthDate", "econID", "NI2TA", "Sales2TA", "TL2TA", "Cash2TA", "Cash2CL", "CL2TL", "LTB2TL", "BE2TL", "BE2CL",
    "LogTA2median", "LogTA2TL", "rfr", "stkrtn", "fxrate", "medianDTD", "medianOverSigma"]  ## 19 columns
    names!(SampleM, Symbol.(colnames))

    if smeindicator == 1
        DTDInput = load(PathStruct["Firm_DTD_Regression_FS"]*"Me_DTDInput.jld")["Me_DTDInput"]
        println("Start to generate firmSpecific_final for Median companies...")
    elseif smeindicator == 2
        DTDInput = load(PathStruct["Firm_DTD_Regression_FS"]*"Sm_DTDInput.jld")["Sm_DTDInput"]
        println("Start to generate firmSpecific_final for Small companies...")
    elseif smeindicator == 3
        DTDInput = load(PathStruct["Firm_DTD_Regression_FS"]*"Mi_DTDInput.jld")["Mi_DTDInput"]
        println("Start to generate firmSpecific_final for Micro companies...")
    end

    DTDInput = DTDInput[:, [:CompNo, :monthDate, :industryID, :BE]]
    # new_df = join(DTDInput, SampleM, on = [:CompNo, :monthDate], kind = :left)
    # missing2NaN!(new_df)
    # for iFirm in unique(new_df.CompNo)
    #     new_df[new_df.CompNo .== iFirm, :econID] .= nanMean(new_df[new_df.CompNo .== iFirm, :econID])
    # end
    # new_df = new_df[in.(new_df.CompNo, [unique(SampleM.CompNo)]), :]    ## delete companies not in SampleM
    # new_df = new_df[new_df.econID .== countrycode, :]
    # Count = length(unique(new_df.CompNo))

    sub_df = join(SampleM, DTDInput, on = [:CompNo, :monthDate], kind = :left)
    sub_df = sub_df[sub_df.econID .== countrycode, :]
    Count = length(unique(sub_df.CompNo))

    fSpecific = read_jld(PathStruct["Firm_Specific"]*"firmSpecific_afterNormalize_beforeAverDiff_"*
                string(countrycode)*".jld")["firmSpecific_afterNormalize_beforeAverDiff"]
    dateVctr = load(PathStruct["FullPeriodPD"]*"dateVctr.jld")["dateVctr"]
    #= Comp_Mapped_Number', 1,
                  'YYYY', 2,
                  'MM', 3,
                  'Three_Month_Rate_After_Demean', 4, ...
                  'Stock_Index_Return', 5, ...
                  'DTD', 6, ...
                  'NI_Over_TA', 7, ...
                  'M_Over_B', 8, ...
                  'CA_Over_CL', 9, ... %% Current asset / Current liability. liquidity for non-Fin.
                  'Size', 10, ...
                  'SIGMA', 11, ...
                  'Cash_Over_TA', 12, ... %% liquidity for Fin
                  'Aggregate_DTD_Fin', 13, ...
                  'Aggregate_DTD_nonFin', 14
    =#
    #= 7 DTD regressors in firmpreDTD cols
        3:  NI/TA         6:  CASH/TA         8:  CL/TL     11: BE/CL
        13: log(TA/TL)    17: median DTD      18: median 1/sigma
    =#

    firmlist = read_jld(PathStruct["Firm_Specific"]*"firmList_withCompNum_"*string(countrycode)*".jld")["firmList_withCompNum"]
    compidx = indexin(unique(sub_df.CompNo), fld.(firmlist[:, 1], 1000))

    liqdata = fSpecific[:, vcat(1:3, 9), compidx]
    liqdata[:, 2, :] = liqdata[:, 2, :] .*100 .+ liqdata[:, 3, :]
    liqdata = liqdata[:, vcat(1, 2, 4), :]   ## Column 3 for Non-fin liquidity

    VfirmInfo = firmlist[compidx, :]
    VfirmInfo[:, 1] ./= 1000
    VfirmInfo[:, 2:3] .= 0

    firmpreDTD = Vector{Array{Float64, 2}}(undef, length(VfirmInfo[:, 1]))
    DTDres = Vector{Vector}(undef, length(VfirmInfo[:, 1]))
    firmspecific = Vector{Array}(undef, length(VfirmInfo[:, 1]))
    firmspecificAll = Vector{Array}(undef, 0)
    firmlistAll = Array{Float64, 2}[]
    # firmSpecific_final = Array{Float64, 3}(undef, (size(fSpecific, 1), 19, Count))

    for i = 1:length(VfirmInfo[:, 1])
        println("i = $i")
        # global firmpreDTD, DTDres, firmspecific, firmspecificAll, firmlistAll, firmSpecific_final
        icomp = VfirmInfo[i, 1]
        idx = findfirst(fld.(firmlist[:, 1], 1000) .== icomp)
        VfirmInfo[i, 4] = firmlist[idx, 4]

        firmpreDTD[i] = sub_df[sub_df.CompNo .== icomp, [:CompNo, :monthDate, :NI2TA, :Sales2TA, :TL2TA, :Cash2TA, :Cash2CL,
        :CL2TL, :LTB2TL, :BE2TL, :BE2CL, :LogTA2median, :LogTA2TL, :rfr, :stkrtn, :fxrate, :medianDTD, :medianOverSigma]]

        tempdata = @view firmpreDTD[i][:, [3, 6, 8, 11, 13]]    ## NI/TA, CASH/TA, CL/TL, BE/CL, log(TA/TL)
        lowerB   = repeat(lb, outer = size(tempdata, 1))
        upperB   = repeat(ub, outer = size(tempdata, 1))

        idxl = tempdata .< lowerB
        idxu = tempdata .> upperB
        tempdata[idxl]  .= lowerB[idxl]
        tempdata[idxu]  .= upperB[idxu]

        println("Start to compute DTD for firm $(-Int64(VfirmInfo[i, 1])) ...")
        DTDres[i] = beta[1] .+ firmpreDTD[i][:, 3:end] * beta[2:end]   ## beta[1] for constant para
        #= 7 DTD regressors in firmpreDTD cols
            3:  NI/TA         6:  CASH/TA         8:  CL/TL     11: BE/CL
            13: log(TA/TL)    17: median DTD      18: median 1/sigma
        =#
        l = length(DTDres[i])
        if icomp == 10008  # Fin                ### fs2PDinput_v2
            firmpreDTD[i][:, 6] = log.(firmpreDTD[i][:, 6])   ## log(CASH/TA)
        else   # non-Fin
            firmpreDTD[i][:, 6] = liqdata[(end+1-l):end, end, i] ## log(CASH/CL)
        end

        ## for current stage, col8, 10, 11 are all NaN
        monthNumbers = size(liqdata, 1)
        firmspecific[i] = fill(NaN, (monthNumbers, 11))

        ####  firmspecific:
            ## Col1:    Company code
            ## Col2:    yyyy
            ## col3:    mm
            ## col4:    rfr
            ## col5:    stock index return
            ## col6:    DTDres[i]
            ## col7:    NI/TA
            ## col8:    M/B
            ## col9:    log(Cash/TA)
            ## col10:   SIZE
            ## col11:   Sigma
        dateidx = indexin(firmpreDTD[i][:, 2], dateVctr)
        firmspecific[i][dateidx, 1:3] = [firmpreDTD[i][:, 1] fld.(firmpreDTD[i][:, 2], 100) mod.(firmpreDTD[i][:, 2], 100)]
        firmspecific[i][dateidx, 4:6] = [firmpreDTD[i][:, 14:15] DTDres[i]]
        firmspecific[i][dateidx, [7, 9]] = firmpreDTD[i][:, [3, 6]]

        idf, idmedian = ismember_CK(hcat((firmspecific[i][dateidx, 2]*100 + firmspecific[i][dateidx, 3]),
                                          countrycode*ones(size(firmspecific[i][dateidx, 1], 1))), DTDmedian[:,1:2], "rows")
        firmspecific[i][dateidx, [8, 10, 11]] = DTDmedian[idmedian, [6, 9, 7]]
        ##  DTDmedian:  6. median M/B   9. median BE (all firms)  7. median sigma
        idx, idnum = ismember_CK(DTDInput[DTDInput.CompNo .== icomp, 2], DTDmedian[idmedian,1], "rows")
        BE = DTDInput[DTDInput.CompNo .== icomp, 4]
        BE = BE[findall(idx)]
        temp = BE ./ firmspecific[i][dateidx, 10]
        temp[temp .< eps(Float64)] .= eps(Float64)
        firmspecific[i][dateidx, 10] = log.(temp)       ## log(BE/median BE)  Size proxy

        VfirmInfo[i, 2] = findfirst(.!isnan.(firmspecific[i][:, 1]))
        # VfirmInfo[i, 3] = VfirmInfo[i, 2] + size(firmpreDTD[i], 1) - 1
        VfirmInfo[i, 3] = findlast(.!isnan.(firmspecific[i][:, 1]))

        firmspecificAll = i == 1 ? firmspecific[i] : cat(firmspecificAll, firmspecific[i], dims = 3)
        firmlistAll     = i == 1 ? VfirmInfo[i,:]' : vcat(firmlistAll, VfirmInfo[i,:]')
    end

    # end
    return firmspecificAll, firmlistAll
end
