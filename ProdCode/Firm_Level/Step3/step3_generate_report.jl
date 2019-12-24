using Pkg, Printf, Statistics, MAT, JLD, DataFrames, StatsBase,
    LinearAlgebra, XLSX, CSV, Dates, Missings, ToolCK#, ZipFile

prePath = raw"\\unicorn6\TeamData\VT_DT\Validus\ProdCode"
Ycom = raw"\\unicorn6\TeamData\VT_DT\Validus\ProdCode\Industry_Level\YX_Code"

include(Ycom*"\\connectDB.jl")
include(Ycom*"\\get_data_from_DMTdatabase.jl")
include(Ycom*"\\highest_indexin.jl")
include(Ycom*"\\readConfig.jl")
include(Ycom*"\\RetrieveFieldEnum_v011.jl")
include(Ycom*"\\RetrieveDwnAccStdrd_v011.jl")
include(Ycom*"\\global_numer_definition_current.jl")
include(Ycom*"\\global_constants_extra.jl")
include(Ycom*"\\pivot.jl")
include(Ycom*"\\convert_currency_financial_statement.jl")
include(Ycom*"\\get_specific_day_value.jl")
include(Ycom*"\\get_individual_first_use_time.jl")
include(Ycom*"\\filter_financial_statement.jl")
include(Ycom*"\\convert_currencyID_to_FXID.jl")
include(Ycom*"\\GCdef.jl")
include("$prePath/validus_path_define.jl")
include("$prePath/Industry_Level/Adaptive lasso/nanSum.jl")
include("$prePath/Industry_Level/Adaptive lasso/nanMean.jl")
include("$prePath/Industry_Level/Adaptive lasso/nanMedian.jl")
include("$prePath/Industry_Level/YX_Code/missing2NaN.jl")
include("$prePath/Industry_Level/YX_Code/missing2real.jl")
include("$prePath/Industry_Level/YX_Code/quantiledims.jl")
include("$prePath/Industry_Level/YX_Code/searchdir.jl")
include("$prePath/Industry_Level/YX_Code/read_jld.jl")
include(prePath*"\\Firm_Level\\Step3\\read_fs_xls_V2.jl")
include(prePath*"\\Firm_Level\\Step3\\fs2DTDinput_v3.jl")
include(prePath*"\\Firm_Level\\Step3\\fs2DTDinput_v4.jl")
include(prePath*"\\Firm_Level\\Step3\\fs2PDinput_v2.jl")
include(prePath*"\\Firm_Level\\Step3\\compute_level_trend.jl")
include(prePath*"\\Firm_Level\\Step3\\computePD_Validus.jl")
include(prePath*"\\Firm_Level\\Step3\\Cal_CountryPD_v011.jl")
include(prePath*"\\Firm_Level\\Step3\\global_quantile_to_cell.jl")
include(prePath*"\\Firm_Level\\Step3\\compute_firm_quantile.jl")
include(prePath*"\\Firm_Level\\Step3\\firm_quantile_to_cell.jl")

function step3_generate_report(path_to_input_file, DataMonth, smeEcon = [1 3 9 10], countrycode = 9)
    # path_to_input_file = raw"\\unicorn6\TeamData\VT_DT\Validus\template_for_Validus.xlsx"
    # DataMonth = 201906
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
    ## Beta need to use new one by Deepselect
    Beta = load(PathStruct["Firm_DTD_Regression_Parameter"]*"beta.jld")

    ## medianInfo keys are "DTDmedianMi", "DTDmedianMe", "DTDmedianSm"
    medianInfo = load(PathStruct["Firm_DTD_Regression_CriRiskFactor"]*"medianInfo.jld")

    println("Start to retrieve data from user input file...")
    num, sheetname, VfirmInfo = read_fs_xls_V2(fxrate, path_to_input_file, countrycode)

    firmpreDTD = Vector{Array{Float64, 2}}(undef, length(num))
    # error "invalid redefinition of constant DTD", for DTD is a defined function.
    # therefore, change variable name from DTD to DTDres
    DTDres = Vector{Vector}(undef, length(num))
    # DTDAll = Vector{Vector}(undef, 0)
    # firmpreDTDAll = Vector{Array}(undef, 0)
    firmspecificAll = Vector{Array}(undef, 0)
    firmlistAll = Array{Float64, 2}[]
    firmspecific = Vector{Array}(undef, length(num))

    for i = 1:length(num)
        # global firmpreDTD, DTDres, DTDAll, firmpreDTDAll, firmlistAll, firmspecific, firmspecificAll
        println("Start to prepare DTD input for firm $(-Int(VfirmInfo[i, 1])) ...")
        firmpreDTD[i], BE = fs2DTDinput_v3(num[i], dateVctr[end], VfirmInfo[i, 1])
        #= firmpreDTD with 18 cols, for current stage, left the last 5 cols unfilled.
            3:  NI/TA     4:  sales/TA         5:  TL/TA        6:  CASH/TA CA=CAS    7:  CASH/CL
            8:  CL/TL     9:  LB/TL            10: BE/TL        11: BE/CL       12: TA in million
            13: TA/TL
            14: risk free rate     15: stock index return       16: forex rate
            17: median DTD                     18: median 1/sigma
        =#
        if VfirmInfo[i, 4] == 1
            DTDmedian = medianInfo["DTDmedianMe"]
            beta      = Beta["betaMe"]
            SampleM   = sampleMatrices["finalMeX"]
            FirmIndex = sampleMatrices["FirmIndexMe"]
            lb        = sampleMatrices["lbMe"]
            ub        = sampleMatrices["ubMe"]
        elseif VfirmInfo[i, 4] == 2
            DTDmedian = medianInfo["DTDmedianSm"]
            beta      = Beta["betaSm"]
            SampleM   = sampleMatrices["finalSmX"]
            FirmIndex = sampleMatrices["FirmIndexSm"]
            lb        = sampleMatrices["lbSm"]
            ub        = sampleMatrices["ubSm"]
        elseif VfirmInfo[i, 4] == 3
            DTDmedian = medianInfo["DTDmedianMi"]
            beta      = Beta["betaMi"]
            SampleM   = sampleMatrices["finalMiX"]
            FirmIndex = sampleMatrices["FirmIndexMi"]
            lb        = sampleMatrices["lbMi"]
            ub        = sampleMatrices["ubMi"]
        end
        ##  DTDmedian:
        ##      1. yyyymm      2. econ   3. DTD   4. 1/sigma    5. number of companies in this month and econ
        ##      6. median M/B  7. median sigma    8. median TA (all firms)  9. median BE (all firms)

        idf, idmedian =
            ismember_CK(hcat(firmpreDTD[i][:, 2], countrycode*ones(size(firmpreDTD[i], 1))), DTDmedian[:, 1:2], "rows")
        idf = Bool.(idf)
        temp = fill(NaN, size(firmpreDTD[i],1))
        temp[idf] = DTDmedian[idmedian[idf], 8]
        firmpreDTD[i][:, 12] = firmpreDTD[i][:, 12] ./ temp   ## TA/median TA
        firmpreDTD[i][firmpreDTD[i][:, 12] .< eps(Float64), 12] .= eps(Float64)
        firmpreDTD[i][firmpreDTD[i][:, 13] .< eps(Float64), 13] .= eps(Float64)

        firmpreDTD[i][:, 12] = log.(firmpreDTD[i][:, 12])   ## col 12: log(TA/median TA)
        firmpreDTD[i][:, 13] = log.(firmpreDTD[i][:, 13])   ## col 13: log(TA/TL)

        idf, idmacro =
            ismember_CK(hcat(firmpreDTD[i][:, 2], countrycode*ones(size(firmpreDTD[i], 1))), FirmIndex[:, 2:3], "rows")
        idf = Bool.(idf)
        firmpreDTD[i][idf, 14:16] = SampleM[idmacro[idf], 12:14] ## col 14: rfr; col 15: stock index return; col 16: forex rate

        idf, idmedian =
            ismember_CK(hcat(firmpreDTD[i][:, 2], countrycode*ones(size(firmpreDTD[i], 1))), DTDmedian[:, 1:2], "rows")
        idf = Bool.(idf)
        firmpreDTD[i][idf, 17:18] = DTDmedian[idmedian[idf], 3:4]  ##   col 17: median DTD;   col 18: 1/sigma

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
        println("Start to prepare PD input for firm $(-Int64(VfirmInfo[i, 1])) ...")
        firmpreDTD[i], BE = fs2DTDinput_v4(num[i], dateVctr[end], VfirmInfo[i, 1], VfirmInfo[i, 5])
        #= firmspecific cols
            1: Company code   2: yyyy    3: mm     4: rfr   5:  index return   6: median DTD
            7: NI/TA          8: M/B     9: Cash/TA         10: SIZE           11: Sigma
        =#
        ## for current stage, col8, 10, 11 are all NaN
        firmspecific[i], monthNumbers = fs2PDinput_v2(PathStruct, firmpreDTD[i], DTDres[i], countrycode)

        l = length(DTDres[i])
        idf, idmedian = ismember_CK(hcat((firmspecific[i][(end-l+1):end, 2]*100 + firmspecific[i][(end-l+1):end, 3]),
                                          countrycode*ones(size(firmspecific[i][(end-l+1):end, 1], 1))), DTDmedian[:,1:2], "rows")
        firmspecific[i][(end-l+1):end, [8, 10, 11]] = DTDmedian[idmedian, [6, 9, 7]]
        ##  DTDmedian:  6. median M/B   9. median BE (all firms)  7. median sigma
        temp = BE ./ firmspecific[i][(end-l+1):end, 10]
        temp[temp .< eps(Float64)] .= eps(Float64)
        firmspecific[i][(end-l+1):end, 10] = log.(temp)       ## log(BE/median BE)  Size proxy

        VfirmInfo[i, 3] = monthNumbers
        VfirmInfo[i, 2] = findfirst(.!isnan.(firmspecific[i][:, 1]))

        # ## still not figure out what DTDAll and firmpreDTDAll are used for later...
        # DTDAll          = i == 1 ? [DTDres[i]]     : vcat(DTDAll, [DTDres[i]])
        # firmpreDTDAll   = i == 1 ? [firmpreDTD[i]] : vcat(firmpreDTDAll, [firmpreDTD[i]])

        firmspecificAll = i == 1 ? firmspecific[i] : cat(firmspecificAll, firmspecific[i], dims = 3)
        firmlistAll     = i == 1 ? VfirmInfo[i,:]' : vcat(firmlistAll, VfirmInfo[i,:]')
    end
    println("Start to compute PD for all firms...")
    PD_all, firmspecificleveltrend = computePD_Validus(PathStruct, countrycode, firmspecificAll, firmlistAll)

    println("Start to write global quantile data to output file.")
    Varresult      = load(PathStruct["SMEPD_Input"]*"Varresult.jld")["Varresult"]
    global_title   = matread(PathStruct["SME_Titles"]*"global_title.mat")["global_title"]
    selEcons_title = matread(PathStruct["SME_Titles"]*"selEcons_title.mat")["selEcons_title"]
    category_title = matread(PathStruct["SME_Titles"]*"category_title.mat")["category_title"]
    firm_title     = matread(PathStruct["SME_Titles"]*"firm_title.mat")["firm_title"]

    monthVctr = nanMean(PD_all[:,2:3,:], 3)
    monthVctr = monthVctr[.!isnan.(monthVctr[:, 1]), :]
    monthVctr = monthVctr[:, 1]*100 + monthVctr[:, 2]

    global_quantile_to_cell(Varresult, monthVctr, global_title, selEcons_title, category_title, PathStruct, filename)
    println("Start to write firm PD data to output file.")
    pdAllForwardtemp = load(PathStruct["FullPeriodPD"]*"pdAllForwardtemp.jld")["pdAllForwardtemp"]
    firmInfo         = load(PathStruct["FullPeriodPD"]*"firmInfo.jld")["firmInfo"]
    firm_title       = matread(PathStruct["SME_Titles"]*"firm_title.mat")["firm_title"]

    for i = 1:length(num)
        PD_target = PD_all[:, :, i]
        result = compute_firm_quantile(PD_target, pdAllForwardtemp, dateVctr, firmInfo, VfirmInfo[i,:])
        firm_quantile_to_cell(result, PD_all[:,:,i], sheetname[i], VfirmInfo[i,:], monthVctr, firm_title, PathStruct, filename)
    end

end
