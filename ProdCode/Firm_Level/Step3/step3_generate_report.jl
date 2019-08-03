function step3_generate_report(path_to_input_file, DataMonth, smeEcon = [1 3 9 10], countrycode = 9)
     # path_to_input_file = raw"C:\Users\e0375379\Downloads\DT\Validus\Validus\template_for_Validus.xlsx"
    # DataMonth = 201905
    PathStruct = validus_path_define(DataMonth)
    filename = basename(path_to_input_file)

    ## single variable
    fxrate = load(PathStruct["SMEPD_Input"]*"fxrate.jld")["fxrate"]
    dateVctr = load(PathStruct["FullPeriodPD"]*"dateVctr.jld")["dateVctr"]

    ## multiple varibles
    #= sampleMatrices keys are:
        "DTDMi", "lbMe", "lbSm", "ubMe", "lbMi", "finalMeX", "FirmIndexMe", "finalSmX", "DTDSm",
        "FirmIndexSm", "DTDMe", "finalMiX", "ubMi", "ubSm", "FirmIndexMi"
    =#
    sampleMatrices = load(PathStruct["SMEPD_Input"]*"sampleMatrices.jld")

    ## Beta keys are "betaMe", "betaMi", "betaSm", "RsSm", "RsMi", "RsMe"
    Beta = load(PathStruct["Firm_DTD_Regression_Parameter"]*"beta.jld")

    ## medianInfo keys are "DTDmedianMi", "DTDmedianMe", "DTDmedianSm"
    medianInfo = load(PathStruct["Firm_DTD_Regression_CriRiskFactor"]*"medianInfo.jld")

    println("Start to retrieve data from user input file...")
    num, sheetname, VfirmInfo = read_fs_xls_V2(fxrate, path_to_input_file, countrycode)

    firmpreDTD = Vector{Array{Float64, 2}}(undef, length(num))
    # error "invalid redefinition of constant DTD", therefore, change variable name from DTD to DTDres
    DTDres = Vector{Vector}(undef, length(num))
    DTDAll = Vector{Vector}(undef, 0)
    firmpreDTDAll = Vector{Array}(undef, 0)
    firmspecificAll = Vector{Array}(undef, 0)
    firmlistAll = Array{Float64, 2}[]
    firmspecific = Vector{Array}(undef, length(num))

    for i = 1:length(num)
        global firmpreDTD, DTDres, DTDAll, firmpreDTDAll, firmlistAll, firmspecific, firmspecificAll
        println("Start to prepare DTD input for firm $(-Int(VfirmInfo[i, 1])) ...")
        firmpreDTD[i], BE = fs2DTDinput_v3(num[i], dateVctr[end, 1], VfirmInfo[i, 1])
        if VfirmInfo[i, 4] == 1
            DTDmedian = medianInfo["DTDmedianMe"]
            beta = Beta["betaMe"]
            SampleM = sampleMatrices["finalMeX"]
            FirmIndex = sampleMatrices["FirmIndexMe"]
            lb = sampleMatrices["lbMe"]
            ub = sampleMatrices["ubMe"]
        elseif VfirmInfo[i, 4] == 2
            DTDmedian = medianInfo["DTDmedianSm"]
            beta = Beta["betaSm"]
            SampleM = sampleMatrices["finalSmX"]
            FirmIndex = sampleMatrices["FirmIndexSm"]
            lb = sampleMatrices["lbSm"]
            ub = sampleMatrices["ubSm"]
        elseif VfirmInfo[i, 4] == 3
            DTDmedian = medianInfo["DTDmedianMi"]
            beta = Beta["betaMi"]
            SampleM = sampleMatrices["finalMiX"]
            FirmIndex = sampleMatrices["FirmIndexMi"]
            lb = sampleMatrices["lbMi"]
            ub = sampleMatrices["ubMi"]
        end
        ##  monthDTDmedian:
        ##      1. yyyymm;  2. econ;  3. DTD;  4. 1/sigma;  5. number of companies of this month and econ
        ##      6. median M/B;  7. median sigma;  8. median TA (all firms);  9. median BE (all firms)

        idf, idmedian =
            ismember_CK(hcat(firmpreDTD[i][:, 2], countrycode*ones(size(firmpreDTD[i], 1))), DTDmedian[:, 1:2], "rows")
        firmpreDTD[i][:, 12] = firmpreDTD[i][:, 12] ./ DTDmedian[idmedian, 8]
        firmpreDTD[i][firmpreDTD[i][:, 12] .< eps(Float64), 12] .= eps(Float64)
        firmpreDTD[i][firmpreDTD[i][:, 13] .< eps(Float64), 13] .= eps(Float64)

        firmpreDTD[i][:, 12] = log.(firmpreDTD[i][:, 12])
        firmpreDTD[i][:, 13] = log.(firmpreDTD[i][:, 13])

        idf, idmacro =
            ismember_CK(hcat(firmpreDTD[i][:, 2], countrycode*ones(size(firmpreDTD[i], 1))), FirmIndex[:, 2:3], "rows")
        firmpreDTD[i][BitArray(idf), 14:16] = SampleM[idmacro, 12:14] # rfr, stock index return, forex rate

        idf, idmedian =
            ismember_CK(hcat(firmpreDTD[i][:, 2], countrycode*ones(size(firmpreDTD[i], 1))), DTDmedian[:, 1:2], "rows")
        firmpreDTD[i][BitArray(idf), 17:18] = DTDmedian[idmedian, 3:4]

        tempdata = @view firmpreDTD[i][:, [3, 6, 8, 11, 13]]
        lowerB = repeat(lb, outer = size(tempdata, 1))
        upperB = repeat(ub, outer = size(tempdata, 1))

        idxl = tempdata .< lowerB
        idxu = tempdata .> upperB
        tempdata[idxl] .= lowerB[idxl]
        tempdata[idxu] .= upperB[idxu]

        println("Start to compute DTD for firm $(-Int64(VfirmInfo[i, 1])) ...")
        DTDres[i] = beta[1] .+ firmpreDTD[i][:, 3:end] * beta[2:end]

        println("Start to prepare PD input for firm $(-Int64(VfirmInfo[i, 1])) ...")
        firmpreDTD[i], BE = fs2DTDinput_v4(num[i], dateVctr[end], VfirmInfo[i, 1], VfirmInfo[i, 5])

        firmspecific[i], monthNumbers = fs2PDinput_v2(PathStruct, firmpreDTD[i], DTDres[i], countrycode)

        l = length(DTDres[i])
        idf, idmedian = ismember_CK(hcat((firmspecific[i][(end-l+1):end, 2]*100 + firmspecific[i][(end-l+1):end, 3]),
                                          countrycode*ones(size(firmspecific[i][(end-l+1):end, 1], 1))), DTDmedian[:,1:2], "rows")
        firmspecific[i][(end-l+1):end, [8, 10, 11]] = DTDmedian[idmedian, [6, 9, 7]]
        temp = BE ./ firmspecific[i][(end-l+1):end, 10]
        temp[temp .<eps(Float64)] .= eps(Float64)
        firmspecific[i][(end-l+1):end, 10] = log.(temp)

        VfirmInfo[i, 3] = monthNumbers
        VfirmInfo[i, 2] = findfirst(.!isnan.(firmspecific[i][:, 1]))

        DTDAll = i == 1 ? [DTDres[i]] : vcat(DTDAll, [DTDres[i]])
        firmpreDTDAll = i == 1 ? [firmpreDTD[i]] : vcat(firmpreDTDAll, [firmpreDTD[i]])
        firmspecificAll = i == 1 ? firmspecific[i] : cat(firmspecificAll, firmspecific[i], dims = 3)
        firmlistAll = i == 1 ? VfirmInfo[i,:]' : vcat(firmlistAll, VfirmInfo[i,:]')
    end
    println("Start to compute PD for all firms...")
    PD_all, firmspecificleveltrend = computePD_Validus(PathStruct, countrycode, firmspecificAll, firmlistAll)

    println("Start to write global quantile data to output file.")
    Varresult = load(PathStruct["SMEPD_Input"]*"Varresult.jld")["Varresult"]
    global_title = matread(PathStruct["SME_Titles"]*"global_title.mat")["global_title"]
    selEcons_title = matread(PathStruct["SME_Titles"]*"selEcons_title.mat")["selEcons_title"]
    category_title = matread(PathStruct["SME_Titles"]*"category_title.mat")["category_title"]
    firm_title = matread(PathStruct["SME_Titles"]*"firm_title.mat")["firm_title"]

    monthVctr = nanMean(PD_all[:,2:3,:], 3)
    monthVctr = monthVctr[(.!isnan.(monthVctr[:, 1]) .& .!isnan.(monthVctr[:, 2])), :]
    monthVctr = monthVctr[:, 1]*100 + monthVctr[:, 2]

    global_quantile_to_cell(Varresult, monthVctr, global_title, selEcons_title, category_title, PathStruct, filename)
    println("Start to write firm PD data to output file.")
    pdAllForwardtemp = load(PathStruct["FullPeriodPD"]*"pdAllForwardtemp.jld")["pdAllForwardtemp"]
    firmInfo = load(PathStruct["FullPeriodPD"]*"firmInfo.jld")["firmInfo"]
    firm_title = matread(PathStruct["SME_Titles"]*"firm_title.mat")["firm_title"]

    for i = 1:length(num)
        PD_target = PD_all[:, :, i]
        result = compute_firm_quantile(PD_target, pdAllForwardtemp, dateVctr, firmInfo, VfirmInfo[i,:])
        firm_quantile_to_cell(result, PD_all[:,:,i], sheetname[i], VfirmInfo[i,:], monthVctr, firm_title, PathStruct, filename)
    end

end
