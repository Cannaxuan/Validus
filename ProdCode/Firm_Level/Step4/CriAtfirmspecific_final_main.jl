using PyCall, Pkg, Printf, Statistics, MAT, JLD, DataFrames, StatsBase,
        LinearAlgebra, XLSX, CSV, Dates, Missings, ToolCK, CriConsts, JldTools
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
include(prePath*"\\Firm_Level\\Step4\\CriAtgenerate_firmSpecific_final.jl")




function CriAtfirmspecific_final_main(DataMonth, groupNum)

    # DataMonth = 201909
    # groupNum = 297
    PathStruct, Econs = validus_path_define_forAR(DataMonth, groupNum)

    ## single variable
    # fxrate = load(PathStruct["SMEPD_Input"]*"fxrate.jld")["fxrate"]
    # dateVctr = load(PathStruct["FullPeriodPD"]*"dateVctr.jld")["dateVctr"]

    ## multiple varibles
    #= sampleMatrices keys are:
        "DTDMi", "lbMe", "lbSm", "ubMe", "lbMi", "finalMeX", "FirmIndexMe", "finalSmX", "DTDSm",
        "FirmIndexSm", "DTDMe", "finalMiX", "ubMi", "ubSm", "FirmIndexMi"
    =#
    sampleMatrices = JldTools.cri_read_jld(PathStruct["SMEPD_Input"]*"sampleMatrices.jld")
    medianInfo = JldTools.cri_read_jld(PathStruct["Firm_DTD_Regression_CriRiskFactor"]*"medianInfo.jld")
    DTDmedian = medianInfo["DTDmedian"]
    lb        = sampleMatrices["lb"]
    ub        = sampleMatrices["ub"]

    Finbetafile = PathStruct["Firm_DTD_Regression_Parameter"]*"beta_"*string(groupNum)*"_Fin.csv"
    nonFinbetafile = PathStruct["Firm_DTD_Regression_Parameter"]*"beta_"*string(groupNum)*"_nonFin.csv"

    beta_Fin = Matrix(CSV.read(Finbetafile))[:]
    beta_nonFin = Matrix(CSV.read(nonFinbetafile))[:]

    println("Start to retrieve data from user input file...")

######################################
    for countrycode in Econs
        # for Fin
        beta      = beta_Fin
        SampleM   = sampleMatrices["finalXFin"]
        FirmIndex = sampleMatrices["FirmIndexFin"]
        firmSpecific_final_1, VfirmInfo_1, dateVctr = CriAtgenerate_firmSpecific_final(PathStruct, DTDmedian, beta, SampleM, FirmIndex, lb, ub, countrycode)

        # for nonFin

        beta      = beta_nonFin
        SampleM   = sampleMatrices["finalXNonFin"]
        FirmIndex = sampleMatrices["FirmIndexNonFin"]

        firmSpecific_final_2, VfirmInfo_2, dateVctr = CriAtgenerate_firmSpecific_final(PathStruct, DTDmedian, beta, SampleM, FirmIndex, lb, ub, countrycode)


        firmSpecific_final = cat(firmSpecific_final_1, firmSpecific_final_2, dims = 3)
        VfirmInfo = vcat(VfirmInfo_1, VfirmInfo_2)

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

        firmSpecific_final, CALIBRATION_DATE = firmspecific_final(PathStruct, countrycode, firmspecificAll, firmlistAll)

        save(PathStruct["SMEPD_Output"]*"firmSpecific_final_"*string(countrycode)*".jld", "firmSpecific_final", firmSpecific_final, compress = true)
        save(PathStruct["SMEPD_Output"]*"firmInfo_"*string(countrycode)*".jld", "firmlistAll", firmlistAll, compress = true)
    end

    println("Done! Output is under $(PathStruct["SMEPD_Output"])")
    println("Calibration date is $CALIBRATION_DATE")
end
