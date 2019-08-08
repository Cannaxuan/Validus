function compute_level_trend(firmspecific, firmlist, countrycode)

    firmspecific[isinf.(firmspecific)] .= NaN
    start = time()
    ## global GConst
    nob = size(firmspecific, 1)
    nfirm = size(firmspecific, 3)
    ##  construct matrix to hold starting of each variable of each firm
    startVar = zeros(nfirm, 6)
    startVar[:, 5] .= nob

    vrbl = firmspecific[:, [6, 7, 9, 10], :]    # 6. DTD  7. NI/TA  9. cash/TA  10. Size
    vrbl_mean = fill(NaN, (nob, 4, nfirm))
    vrbl_diff = fill(NaN, (nob, 4, nfirm))
    println("Calculate the level and the trend ...")

    compNoVec = nanMean(firmspecific[:, 1, :], 1)
    startVar[:, 6] .= NaN
    for iFirm = 1:nfirm
        ## Loop through each variable :
        ## 1. distance to default  2. net_income/total_asset  3. cash/total asset  4. size
        for iVar = 1:4
            ## Find the start and end of the variable
            startT = findfirst(isfinite.(vrbl[:, iVar, iFirm]))
            endT = Int(firmlist[iFirm, 3])
            if isempty(startT)
                startVar[iFirm, iVar] = nob
            else
                startVar[iFirm, iVar] = startT
            end
            ##  Loop through dates (first 6 months)
            for iDate = startT:min(endT, (startT+5))
                ## observations
                obs = vrbl[max(1, iDate-12+1):iDate, iVar, iFirm]
                vrbl_mean[iDate, iVar, iFirm] = nanMean(obs)

                ## Find last finite value in the observations
                lastFinite = findlast(isfinite.(obs))
                if lastFinite != nothing
                #     vrbl_diff[iDate, iVar, iFirm] = NaN
                # else
                    vrbl_diff[iDate, iVar, iFirm] = obs[lastFinite] - vrbl_mean[iDate, iVar, iFirm]
                end


            end

            ##  Loop through dates (7 months and beyond)
            for iDate = (startT + 6):endT
                ## observations
                obs = vrbl[max(1, iDate-12+1):iDate, iVar, iFirm]

                ## Check for 6 min points
                if sum(isfinite.(obs)) > 5
                    vrbl_mean[iDate, iVar, iFirm] = nanMean(obs)
                else
                    vrbl_mean[iDate, iVar, iFirm] = NaN
                end

                ## Find last finite value in the observations
                lastFinite = findlast(isfinite.(obs))
                if isempty(lastFinite)
                    vrbl_diff[iDate, iVar, iFirm] = NaN
                else
                    vrbl_diff[iDate, iVar, iFirm] = obs[lastFinite] - vrbl_mean[iDate, iVar, iFirm]
                end
            end
        end
    end
    ## firmspecific:
    ##      1. company code  2. yr (yyyy)   3. mth (mm)      4. index return   5.  3 month r
    ##      6. DTD(AVG)      7. DTD(DIF)    8. CASH/TA(AVG)  9. CASH/TA(DIF)   10. NI/TA(AVG)
    ##      11. NI/TA(DIF)   12. SIZE(AVG)  13. SIZE(DIF)    14. M/B           15. SIGMA
    firmspecific = hcat(firmspecific[:, vcat(1:5, 8, 11), :], vrbl_mean, vrbl_diff)
    vrbl_mean = nothing;    vrbl_diff = nothing
    firmspecific = firmspecific[:, vcat(1:3, 5, 4, 8, 12, 10, 14, 9, 13, 11, 15, 6, 7), :] ## change by SiDate???

    s =  @sprintf "# Elapsed time = %3.2f seconds." (time()-start)
    println(s)
    return firmspecific
end
