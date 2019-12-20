using MAT
using Plots
using Plots.Measures
using DelimitedFiles
using ProgressMeter
using JldTools;

prePath = raw"\\unicorn6\TeamData\VT_DT\Validus\ProdCode"
include("$prePath/Industry_Level/Adaptive lasso/nanMean.jl")
include(prePath*"\\Firm_Level\\Step4\\get_country_pd_hist.jl")
include(prePath*"\\Firm_Level\\Step4\\get_country_para.jl")
include(prePath*"\\Firm_Level\\Step4\\Cal_CountryPD_v012.jl")
include(prePath*"\\Firm_Level\\Step4\\DP_country_abnml_v011.jl")
include(prePath*"\\Firm_Level\\Step4\\powercurve.jl")
include(prePath*"\\Firm_Level\\Step4\\CommonFunctions.jl")
include(prePath*"\\Firm_Level\\Step4\\validus_path_define_forAR.jl")
include(prePath*"\\Industry_Level\\Adaptive lasso\\nanMean.jl")

using .CommonFunctions;
using CriConsts

function ar_calculate_fig(groupNum::Int64, DataMth::Int64, CalibrationDate::Int64)
    ## Part1: prepare
    # G_CONST = GCdef(DataMth*100)
    # Econs = findall(vec(G_CONST["GROUPS"]) .== groupNum)

    PathStruct, Econs = validus_path_define_forAR(DataMth, groupNum)
    econIndex = 1
    groupPD = []
    groupfirmList = []

    for econNum in Econs

        savepath = string(PathStruct["Firm_Data"], "ARResults\\", CalibrationDate, "_econ", join(Econs, "_"), "\\")
        if !isdir(savepath)
            mkpath(savepath)
        end
        ARPath = string(PathStruct["Firm_Data"], "ARResults\\AR_SMC\\")
        if !isdir(ARPath)
            mkpath(ARPath)
        end

        official_ARPath = G_CONST["AR_OUTPUT_SMC"]

        paramPath = G_CONST["CALI_SMC_PATH"]
        legendStr = string(CalibrationDate, "SMC")
        arType = "Clean_AR"

        # These two lines are for counting the number of months from Jan 1990 to
        # current month. Hence, not need to judge whether the data is treated by
        # missing values treatment.
        loadpath = PathStruct["SMEPD_Output"]

        println(" Begin to calculate proxy PDall in Econ $econNum")
        firmSpecific_final = JldTools.cri_read_jld(string(loadpath, "firmSpecific_final_", econNum, ".jld"))["firmSpecific_final"]
        firmList = JldTools.cri_read_jld(string(loadpath, "firmInfo_", econNum, ".jld"))["firmlistAll"]
        firmList = firmList[:, 2:end]
        firmMonth = firmSpecific_final[:, 1:3, :]

        ## Part2: compute AR for each economy
        # choose the dataset for ECONOMY AR calculation

        # rmiyany 20171117
        idx_finance = firmList[:, 4] .== 10008
        firmSpecific_final[:, [8,9], idx_finance] .= 0;   #convet CA_Over_CL to 0 for Finance
        firmSpecific_final[:, [16,17], .!idx_finance] .= 0; #convert Cash_Over_TA to 0 for non-Finance

        # rmils 20180123
        firmSpecific_final[:, 19, idx_finance] .= 0; #convert aggregate dtd[nonfin] to 0 for Finance
        firmSpecific_final[:, 18, .!idx_finance] .= 0;  #convert aggregate dtd[fin] to 0 for nonFinance

        # rmils 20180302
        firmSpecific_final = cat(firmSpecific_final, zeros(
            size(firmSpecific_final, 1), 1, size(firmSpecific_final, 3)), dims = 2)
        firmSpecific_final[:, end, idx_finance] .= 1

        # remove the columns of "company_number", "year" and "month" in
        # order to keep the structure consistent to the case by unclean
        # dataset [12 columns of covariates]
        firmSpecific = firmSpecific_final[:, 4:end, :]

        # calculate the PD for economy
        allPD = get_country_pd_hist(G_CONST, econNum, paramPath, firmSpecific, firmList, firmMonth,
                G_CONST["CALI_DATA_PATH"], "", G_CONST["MAX_HORIZON"], "", -1, CalibrationDate)[1]

        if econIndex == 1
            groupPD = allPD
            groupfirmList = firmList
        else
            groupPD = cat(groupPD, allPD, dims = 3)
            groupfirmList = vcat(groupfirmList, firmList)
        end
        econIndex = econIndex + 1

        resultFile = string(ARPath, "PD_", econNum, "_", CalibrationDate, ".jld")
        JldTools.cri_write_jld(resultFile,"allPD", allPD)

        println(" Begin to calculate proxy AR in Econ $econNum")
        # preallocated
        AR = fill!(Array{Float64}(undef, 2, G_CONST["MAX_HORIZON"]),NaN)
        PC = fill!(Array{Float64}(undef, 10000, G_CONST["MAX_HORIZON"]),NaN)
        NoofPD = fill!(Array{Float64}(undef, 1, G_CONST["MAX_HORIZON"]),NaN)
        NoofDf = fill!(Array{Float64}(undef, 1, G_CONST["MAX_HORIZON"]),NaN)

        for j = 1 : G_CONST["MAX_HORIZON"]
            try
                PCAR = powercurve(allPD[:, 3 + j, :], firmList, j)
                tmpPC = PCAR[1]
                PC[1 : size(tmpPC, 1), j] = tmpPC
                AR[:,j] = PCAR[2]
                NoofPD[j] = PCAR[3]
                NoofDf[j] = PCAR[4]
            catch
                error("Please check allPD or firmList data for econ ", econNum, "!!!!!!")
            end
        end
        AR_proxy = vcat(AR, NoofPD, NoofDf)

        println(" Begin to calculate official AR in Econ $econNum")

        file = string(G_CONST["CALI_DATA_PATH"], "firmList_", econNum, ".jld")
        firmList = JldTools.cri_read_jld(file)["firmList"]

        file = string(official_ARPath, "PD_", econNum, "_", CalibrationDate, ".jld")
        allPD = JldTools.cri_read_jld(file)["allPD"]

        startMth = 145 # 200001
        allPD[1:startMth-1,:,:] .= NaN


        AR = fill!(Array{Float64}(undef, 2, G_CONST["MAX_HORIZON"]),NaN)
        PC = fill!(Array{Float64}(undef, 10000, G_CONST["MAX_HORIZON"]),NaN)
        NoofPD = fill!(Array{Float64}(undef, 1, G_CONST["MAX_HORIZON"]),NaN)
        NoofDf = fill!(Array{Float64}(undef, 1, G_CONST["MAX_HORIZON"]),NaN)

        for j = 1 : G_CONST["MAX_HORIZON"]
            try
                PCAR = powercurve(allPD[:, 3 + j, :], firmList, j)
                tmpPC = PCAR[1]
                PC[1 : size(tmpPC, 1), j] = tmpPC
                AR[:,j] = PCAR[2]
                NoofPD[j] = PCAR[3]
                NoofDf[j] = PCAR[4]
            catch
                error("Please check allPD or firmList data for econ ", econNum, "!!!!!!")
            end
        end
        AR_official = vcat(AR, NoofPD, NoofDf)
        AR = vcat(AR_proxy, AR_official)
        writedlm(string(ARPath, arType, "_", econNum, "_CaliDate_", CalibrationDate, ".csv"), AR', ',')

    end

    println(" Begin to combine economies as group: ")

    groupAR = fill!(Array{Float64}(undef, 2, G_CONST["MAX_HORIZON"]),NaN)
    PC = fill!(Array{Float64}(undef, 10000, G_CONST["MAX_HORIZON"]),NaN)
    NoofPD = fill!(Array{Float64}(undef, 1, G_CONST["MAX_HORIZON"]),NaN)
    NoofDf = fill!(Array{Float64}(undef, 1, G_CONST["MAX_HORIZON"]),NaN)

    for j = 1 : G_CONST["MAX_HORIZON"]
        try
            PCAR = powercurve(groupPD[:, 3 + j, :], groupfirmList, j)
            tmpPC = PCAR[1]
            PC[1 : size(tmpPC, 1), j] = tmpPC
            groupAR[:,j] = PCAR[2]
            NoofPD[j] = PCAR[3]
            NoofDf[j] = PCAR[4]
        catch
            error("Please check allPD or firmList data for econ ", iEcon, "!!!!!!")
        end
    end
    groupAR = vcat(groupAR, NoofPD, NoofDf)

    # output the AR data results to the path(): ...\ProductionData\AR_SMC
    writedlm(string(ARPath, arType, "_", groupNum, "_CaliDate_", CalibrationDate, ".csv"), groupAR', ',')
    println("Done！group AR file is under "* string(ARPath, arType, "_", groupNum, "_CaliDate_", CalibrationDate, ".csv"))
end
