using PyCall, Pkg, Printf, Statistics, MAT, JLD, DataFrames, StatsBase,
        LinearAlgebra, XLSX, CSV, Dates, Missings, ZipFile, ToolCK, CriConsts
prePath = raw"\\unicorn6\TeamData\VT_DT\Validus\ProdCode"
Ycom = raw"\\unicorn6\TeamData\VT_DT\Validus\ProdCode\Industry_Level\YX_Code\\"
include(Ycom*"\\connectDB.jl")
include(Ycom*"\\searchdir.jl")
include(Ycom*"\\get_data_from_DMTdatabase.jl")
include(Ycom*"\\highest_indexin.jl")
include(Ycom*"\\readConfig.jl")
include(Ycom*"\\RetrieveFieldEnum_v011.jl")
include(Ycom*"\\RetrieveDwnAccStdrd_v011.jl")
include(Ycom*"\\global_numer_definition_current.jl")
include(Ycom*"\\global_constants_extra.jl")
include(Ycom*"\\pivot.jl")
include(Ycom*"\\GCdef.jl")
include(Ycom*"\\missing2NaN.jl")

include(prePath*"\\Industry_Level\\YX_Code\\read_jld.jl")
include(prePath*"\\Industry_Level\\Adaptive lasso\\nanMean.jl")
include(prePath*"\\Industry_Level\\Adaptive lasso\\nanMedian.jl")
include(prePath*"\\Firm_Level\\Step3\\compute_level_trend.jl")
include(prePath*"\\Firm_Level\\Step4\\validus_path_define_forAR.jl")
include(prePath*"\\Firm_Level\\Step4\\firmspecific_final.jl")
include(prePath*"\\Firm_Level\\Step4\\generate_firmSpecific_final.jl")




function firmspecific_final_main(DataMonth, countrycode, smeEcon = [1 3 9 10])

    # DataMonth = 201909
    PathStruct = validus_path_define_forAR(DataMonth, smeEcon, countrycode)

    ## single variable
    # fxrate = load(PathStruct["SMEPD_Input"]*"fxrate.jld")["fxrate"]
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

######################################
    # for VfirmInfo[i, 4] == 1

        DTDmedian = medianInfo["DTDmedianMe"]
        beta      = Beta["betaMe"]
        SampleM   = sampleMatrices["finalMeX"]
        FirmIndex = sampleMatrices["FirmIndexMe"]
        lb        = sampleMatrices["lbMe"]
        ub        = sampleMatrices["ubMe"]
        firmSpecific_final_1, VfirmInfo_1 = generate_firmSpecific_final(PathStruct, DTDmedian, beta, SampleM, FirmIndex, lb, ub, countrycode, 1)

    # for VfirmInfo[i, 4] == 2

        DTDmedian = medianInfo["DTDmedianSm"]
        beta      = Beta["betaSm"]
        SampleM   = sampleMatrices["finalSmX"]
        FirmIndex = sampleMatrices["FirmIndexSm"]
        lb        = sampleMatrices["lbSm"]
        ub        = sampleMatrices["ubSm"]
        firmSpecific_final_2, VfirmInfo_2 = generate_firmSpecific_final(PathStruct, DTDmedian, beta, SampleM, FirmIndex, lb, ub, countrycode, 2)

    # for VfirmInfo[i, 4] == 3

        DTDmedian = medianInfo["DTDmedianMi"]
        beta      = Beta["betaMi"]
        SampleM   = sampleMatrices["finalMiX"]
        FirmIndex = sampleMatrices["FirmIndexMi"]
        lb        = sampleMatrices["lbMi"]
        ub        = sampleMatrices["ubMi"]
        firmSpecific_final_3, VfirmInfo_3 = generate_firmSpecific_final(PathStruct, DTDmedian, beta, SampleM, FirmIndex, lb, ub, countrycode, 3)
    # end

    firmSpecific_final = cat(firmSpecific_final_1, firmSpecific_final_2, firmSpecific_final_3, dims = 3)
    VfirmInfo = vcat(VfirmInfo_1, VfirmInfo_2, VfirmInfo_3)

    comp = unique(VfirmInfo[:, 1])
    firmspecificAll = fill(NaN, (length(dateVctr), 11, length(comp)))
    firmlistAll = fill(NaN, length(comp), 6)

    for i = 1:length(comp)
        # println(i)
        # println("Company $(comp[i])")
        icomp = comp[i]
        idx = findall(VfirmInfo[:, 1] .== icomp)
        if length(idx) == 1
            firmspecificAll[:, :, i] = firmSpecific_final[:, :, idx]
            firmlistAll[i, :] = VfirmInfo[idx, :]
        else
            for mthidx = 1:length(idx)
                firmspecific = mthidx == 1 ? firmSpecific_final[:, :, idx][:, :, mthidx] :
                            vcat(firmspecific, firmSpecific_final[:, :, idx][:, :, mthidx])
            end
            firmspecific = firmspecific[isfinite.(nanMean(firmspecific, 2)), :]
            firmspecific[:, 2] = firmspecific[:, 2]*100 + firmspecific[:, 3]
            firmspecific = convert(DataFrame, firmspecific)
            colnames = ["CompNo", "yyyymm", "mm", "rfr", "stock_idx", "DTD", "NI2TA", "M/B", "Cash2TA", "Size", "Sigma"]
            names!(firmspecific, Symbol.(colnames))
            sort!(firmspecific, (:yyyymm))
            startT = indexin(firmspecific[1, 2], dateVctr)[1]
            endT = indexin(firmspecific[end, 2], dateVctr)[1]
            monthVctr = DataFrame(CompNo = fill(icomp, endT-startT+1) , yyyymm = dateVctr[startT:endT], mm = mod.(dateVctr[startT:endT], 100))
            firmspecific = join(monthVctr, firmspecific, on = [:CompNo, :yyyymm, :mm], kind = :left)
            missing2NaN!(firmspecific)
            firmlistAll[i, :] =  VfirmInfo[idx, :][1, :]
            firmlistAll[i, 2:3] = [startT, endT]
            firmspecific[:, 2] = fld.(firmspecific[:, 2], 100)
            firmspecificAll[startT:endT, :, i] = Matrix(firmspecific)
        end
    end

    firmSpecific_final = firmspecific_final(PathStruct, countrycode, firmspecificAll, firmlistAll)

#######################################
    save(PathStruct["SMEPD_Output"]*"firmSpecific_final_"*string(countrycode)*".jld", "firmSpecific_final", firmSpecific_final, compress = true)
    save(PathStruct["SMEPD_Output"]*"firmInfo_"*string(countrycode)*".jld", "firmlistAll", firmlistAll, compress = true)

    println("Done! Output is under $(PathStruct["SMEPD_Output"])")
end
