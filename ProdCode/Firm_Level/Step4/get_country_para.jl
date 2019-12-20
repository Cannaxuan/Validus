using DelimitedFiles
using JldTools
function get_country_para(G_CONST::Dict{Any,Any}, countrycode::Int64, parampath::String, CALIBRATION_DATE::Int64, nhorizon::Int64)


    if ~in(G_CONST["GROUPS"][countrycode],G_CONST["TimeVariantOfPara_COUNTRY"])
        PARA_tmp = readdlm(string(parampath, "C", countrycode, "_", CALIBRATION_DATE, ".csv"), ',')
        PARA_def = Array{Float64, 2}(PARA_tmp[3:2+nhorizon,1:G_CONST["NPARA_BASE"]]')

        PARA_other = Array{Float64, 2}(PARA_tmp[nhorizon+4:nhorizon*2+3,1:G_CONST["NPARA_BASE"]]')
        CountryFromFile = PARA_tmp[1,1]
        DateOfFile = PARA_tmp[1,2]

    else

        para = string(parampath, "sb/", countrycode, "/para_both_smc_",
                              countrycode, "_", CALIBRATION_DATE, ".jld")
        if !isfile(para)
            @warn("$para is not found. Try to find altenate files with other calibration dates.")
            candidates = glob(string("para_both_smc_", countrycode, "_*"),
                              string(parampath, "sb/", countrycode))
            if length(candidates) == 1
                para = candidates[1]
            else
                error("Cannot interpret the correct file with $para")
            end
        end
        PARA_def = JldTools.cri_read_jld(para)["DefBeta_HorzinByCovByTime"]
        PARA_other = JldTools.cri_read_jld(para)["OthBeta_HorzinByCovByTime"]

        DateOfFile = CALIBRATION_DATE
        CountryFromFile = countrycode

    end
    return PARA_def,PARA_other,CountryFromFile,DateOfFile
end
