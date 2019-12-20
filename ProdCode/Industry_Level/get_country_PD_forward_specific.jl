function get_country_PD_forward_specific(countryCode, dataEndMth, folders, nHorizon = 60)

    ## This function is to extract the (cumulative) probability of survival (PS) for a specified economy/country.
    ## [Only valid if the calibrationDate >= 20130607.
    ## Otherwise, the address of the loaded data is changed, leading to the change of the range of nhorizon as well.]
    sourceFolder =  folders["dataSource"]
    saveFolder = folders["forwardPDFolder"]
    dataMthToLoad = date_yyyymm_add(dataEndMth, 1)

    loadPath = sourceFolder*"\\Processing\\M2_Pd\\"
    loadPath_para = sourceFolder*"\\Products\\M2_Pd\\"

    firmList_withCompNum = read_jld(loadPath*"FSTransformed\\firmList_withCompNum_"*string(countryCode)*".jld")["firmList_withCompNum"]
    ##   matread(loadPath*"FSTransformed\\firmList_withCompNum_"*string(countryCode)*".mat")["firmList_withCompNum"]
    firmSpecific_final = read_jld(loadPath*"FinalDataForCalibration\\firmSpecific_final_"*string(countryCode)*".jld")["firmSpecific_final"]
    ##   matread(loadPath*"FinalDataForCalibration\\firmSpecific_final_"*string(countryCode)*".mat")["firmSpecific_final"]
    firmMonth = read_jld(loadPath*"FinalDataForCalibration\\firmMonth_"*string(countryCode)*".jld")["firmMonth"]
    ##   matread(loadPath*"FinalDataForCalibration\\firmMonth_"*string(countryCode)*".mat")["firmMonth"]

    firmlist = firmList_withCompNum
    idx_finance = firmlist[:, 5] .== 10008
    firmSpecific_final[:, [8, 9], idx_finance] .= 0     ##convert CA_Over_CL   to 0 for Finance
    firmSpecific_final[:, [16, 17], .!idx_finance] .= 0 ##convert Cash_Over_TA to 0 for non-Finance
    firmSpecific_final[:, 18, .!idx_finance] .= 0       ##convert AggDTD       to 0 for non-Finance
    firmSpecific_final[:, 19, idx_finance] .= 0         ##convert AggDTD       to 0 for Finance

    if countryCode == 15 || countryCode == 16
       temp=zeros(size(firmSpecific_final, 1), 1, size(firmSpecific_final, 3))
       temp[:, :, idx_finance] = ones(size(firmSpecific_final[:, :, idx_finance], 1),
                                           1, size(firmSpecific_final[:, :, idx_finance], 3))
       firmSpecific_final = cat(firmSpecific_final, temp, dims= 2)
       ## Add Intercept
    end

    firmspecific = firmSpecific_final[:, 4:end, :]
    firmList_withCompNum = nothing ;  firmSpecific_final = nothing

    if countryCode == 2 || countryCode == 15 || countryCode == 16  ## get Structure Break Econ's forwrd PD
        ## Load Structure Break Econ's Parameter
        path = loadPath_para*"current_smc\\sb\\"*string(countryCode)*"\\"
        key = "para_both_smc_"*string(countryCode)
        # SBPara = searchdir(path, key)
        SBPara = glob(key*"*.jld", path)
        if isempty(SBPara)
            SBPara = glob(key*"*.mat", path)
        end
        HorzinByCovByTime = read_jld(SBPara[1])
        DefBeta_HorzinByCovByTime = HorzinByCovByTime["DefBeta_HorzinByCovByTime"]
        OthBeta_HorzinByCovByTime = HorzinByCovByTime["OthBeta_HorzinByCovByTime"]
        HorzinByCovByTime = nothing
        ## Pre-check: the months amount of firmlist firmmonth & firmspecific should be exactly the same
        ## DefBeta_HorzinByCovByTime
        ## OthBeta_HorzinByCovByTime
        if  size(firmspecific, 1) !== size(firmMonth, 1) || size(firmMonth, 1) !== size(DefBeta_HorzinByCovByTime, 3)
            error("Please double check these three files: firmlist firmspecific para_both")
        end
        ## This part is for calculating Structure Break's Econ forwards PD
        PD_all_forward = []
        for iMonthSB = 1:size(firmspecific, 1)
            paraDef = DefBeta_HorzinByCovByTime[:, :, iMonthSB]'
            paraOther = OthBeta_HorzinByCovByTime[:, :, iMonthSB]'
            paraDef[3, :] = paraDef[3, :]/100       ## for 3m-interest rate
            paraOther[3, :] = paraOther[3, :]/100   ## for 3m-interest rate
            tempfirmspecific = firmspecific[iMonthSB, :, :]
            tempfirmmonth = firmMonth[iMonthSB, :, :]
            if countryCode == 2
                paraDef = paraDef[setdiff(1:end, 18), :]
                paraOther = paraOther[setdiff(1:end, 18), :]
            end
            temp_PD_all_forward = cal_country_PD_forward(tempfirmspecific, paraDef, paraOther, nHorizon)[1]
            PD_all_forward = isempty(PD_all_forward) ? temp_PD_all_forward : cat(PD_all_forward, temp_PD_all_forward, dims = 3)
        end
    else  ## get Econ's forwrd PD without Structure Break
        paraDef, paraOther = get_country_param(countryCode, dataMthToLoad, sourceFolder)
        paraDef[3, :] = paraDef[3, :]/100       ## for 3m-interest rate
        paraOther[3, :] = paraOther[3, :]/100   ## for 3m-interest rate

        nObs, nVar, nFirm = size(firmspecific)
        # firmspecific = permutedims(firmspecific, [2, 3, 1])
        firmspecific = PermutedDimsArray(firmspecific, [2, 3, 1])
        # firmspecific = deepcopy(reshape(firmspecific, (nVar, nFirm*nObs)))
        firmspecific = reshape(firmspecific, (nVar, nFirm*nObs))

        ## Calculate the cumulative probabilities of default and other exit
        PD_all_forward = cal_country_PD_forward(firmspecific, paraDef, paraOther, nHorizon)[1]
        # PD_all_forward = deepcopy(reshape(PD_all_forward, (:, nFirm, nObs)))
        PD_all_forward = reshape(PD_all_forward, (:, nFirm, nObs))
    end
    ## Combine the firm codes and the date to the cumulative PD and POE
    # PD_all_forward = permutedims(PD_all_forward, [3, 1, 2])
    PD_all_forward = PermutedDimsArray(PD_all_forward, [3, 1, 2])
    PD_all_forward = cat(firmMonth, PD_all_forward, dims=2)

    if ~isdir(saveFolder*"\\specific")
        mkdir(saveFolder*"\\specific")
    end

    ## save jld files
    save(saveFolder*"\\specific\\firmlist_with_comp_num_"*string(countryCode)*".jld", "firmlist", firmlist, compress = true)
    save(saveFolder*"\\specific\\PD_all_forward_"*string(countryCode)*".jld", "PD_all_forward", PD_all_forward, compress = true)
    return firmlist, PD_all_forward
end
