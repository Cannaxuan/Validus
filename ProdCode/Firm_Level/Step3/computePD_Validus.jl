function computePD_Validus(PathStruct, countrycode, firmspecific, firmlist, nhorizon = 60)
    # firmspecific, firmlist = firmspecificAll, firmlistAll
    firmspecificleveltrend = compute_level_trend(firmspecific, firmlist, countrycode)
    nrows = size(firmspecificleveltrend, 1)
    nfirm = size(firmspecificleveltrend, 3)
    ## Add AggDTDmedian
    fSpecific =
        matread(PathStruct["Firm_Specific"]*"firmSpecific_afterNormalize_beforeAverDiff_"*
                string(countrycode)*".mat")["firmSpecific_afterNormalize_beforeAverDiff"]

    firmspecific_date = nanMedian(fSpecific[:, 2:3, :], 3)
    firmspecific_date = firmspecific_date[:, 1]*100 + firmspecific_date[:, 2]
    addDTDmedian = hcat(firmspecific_date, nanMedian(fSpecific[:, 13:14, :], 3))

    firmspecific = hcat(firmspecific, fill(NaN, (nrows, 2, nfirm)))
    firmspecificleveltrend = hcat(firmspecificleveltrend, fill(NaN, (nrows, 2, nfirm)))

    UpLw = CSV.read(PathStruct["CRI_Calibration_Parameter"]*"UpLwBounds_"*string(countrycode)*".csv")
    Lw = Float64.(Matrix(UpLw)[1, :])
    Up = Float64.(Matrix(UpLw)[2, :])
    lowerB = repeat(Lw', nrows)
    upperB = repeat(Up', nrows)

    for iFirm = 1:nfirm
        # global firmspecific, firmspecificleveltrend, lowerB, upperB
        f_date = firmspecific[:, 2, iFirm]*100 + firmspecific[:, 3, iFirm]
        commondate = intersect(f_date, addDTDmedian[:, 1])
        x = Int.(indexin(commondate, f_date))
        y = Int.(indexin(commondate, addDTDmedian[:, 1]))
        firmspecific[x, 12:13, iFirm] = addDTDmedian[y, 2:3]
        firmspecificleveltrend[x, 16:17, iFirm] = addDTDmedian[y, 2:3]

        if firmlist[iFirm, 5] == 10008
            temp = @view firmspecificleveltrend[:, 4:15, iFirm]
            idxl = temp .< lowerB[:, vcat(1:4, 13:14, 7:12)]
            idxu = temp .> upperB[:, vcat(1:4, 13:14, 7:12)]
            temp[idxl] = lowerB[:, 1:12][idxl]
            temp[idxu] = upperB[:, 1:12][idxu]
        else
            temp = @view firmspecificleveltrend[:, 4:15, iFirm]
            idxl = temp .< lowerB[:, 1:12]
            idxu = temp .> upperB[:, 1:12]
            temp[idxl] = lowerB[:, 1:12][idxl]
            temp[idxu] = upperB[:, 1:12][idxu]
        end
    end

    ## Get parameter for the Econ
    # files = searchdir(PathStruct["CRI_Calibration_Parameter"], "C"*string(countrycode)*"_")
    # CALIBRATION_DATE = Vector{Int64}(undef, length(files))
    # for i = 1:length(files)
    #     # global CALIBRATION_DATE
    #     idx0 = findfirst(isequal('_'), files[i])
    #     idx1 = findlast(isequal('.'), files[i])
    #     CALIBRATION_DATE[i] = parse(Int, files[i][(idx0+1):(idx1-1)])
    # end

    file = searchdir(PathStruct["CRI_Calibration_Parameter"], "C"*string(countrycode)*"_")[1]
    idx0 = findfirst(isequal('_'), file)
    idx1 = findlast(isequal('.'), file)
    CALIBRATION_DATE = parse(Int, file[(idx0+1):(idx1-1)])

    PDfile = CSV.read(PathStruct["CRI_Calibration_Parameter"]*file, header = false, skipto = 3)

    para_def = Matrix(PDfile[1:60, 1:end-1])
    para_def[:, 1] = map(x -> parse(Float64, x), para_def[:, 1])
    para_def = Float64.(para_def')
    para_other = Matrix(PDfile[62:end, 1:end-1])
    para_other[:, 1] = map(x -> parse(Float64, x), para_other[:, 1])
    para_other = Float64.(para_other')

    PDfile = nothing

    ##  Compute PD
    PD_all = fill(NaN, (nrows, 3+nhorizon, nfirm))
    for iFirm = 1:nfirm
        # global PD_all
        if round(iFirm/500) == iFirm/500
            println(string(iFirm)*" companies computed.")
        end
        data = firmspecificleveltrend[:, :, iFirm]
        ## adjust interest rate units
        data[:, 5] = data[:, 5] / 100
        PD_all[:, 1:3, iFirm] = data[:, 1:3]
        if firmlist[iFirm, 5] == 10008
            para_def_finance = para_def[vcat(1:5, 14:15, 8:13, 16:17), :]
            para_def_finance[15, :] .= 0
            para_other_finance = para_other[vcat(1:5, 14:15, 8:13, 16:17), :]
            para_other_finance[15, :] .= 0
            PD_all[:, 4:end, iFirm] =
                Cal_CountryPD_v011(para_def_finance, para_other_finance, data[:,4:end], nhorizon)
        else
            para_def_finance = para_def[vcat(1:13, 16:17), :]
            para_def_finance[14, :] .= 0
            para_other_finance = para_other[vcat(1:13, 16:17), :]
            para_other_finance[14, :] .= 0
            PD_all[:, 4:end, iFirm] =
                Cal_CountryPD_v011(para_def_finance, para_other_finance, data[:,4:end], nhorizon)
        end
    end

    return PD_all, firmspecificleveltrend
end
