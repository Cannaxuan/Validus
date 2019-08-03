function fs2PDinput_v2(PathStruct, firminfo, DTDi, countrycode)
 # firminfo, DTDi = firmpreDTD[i], DTDres[i]

    firmlist =
        load(PathStruct["CRI_Calibration_Parameter"]*"firmlist_with_comp_num_"*string(countrycode)*".jld")["firmlist"]
    monthNumbers = Int(maximum(firmlist[:, 3]))

    ####  firmspecific_BeforeAverDiff:
        ## Col1:    Company code
        ## Col2:    yyyy
        ## col3:    mm
        ## col4:    rfr
        ## col5:    index return
        ## col6:    DTD
        ## col7:    NI/TA
        ## col8:    M/B
        ## col9:    Cash/TA
        ## col10:   SIZE
        ## col11:   Sigma
    firmspecific_BeforeAverDiff = fill(NaN, (monthNumbers, 11))
    l = length(DTDi)
    firmspecific_BeforeAverDiff[(end-l+1):end, 6]   = DTDi    ## Col6 DTD
    firmspecific_BeforeAverDiff[(end-l+1):end, 1:3] = [firminfo[:, 1] fld.(firminfo[:, 2], 100) mod.(firminfo[:, 2], 100)]
    ##  firminfo
        ## 3:NI/TA
        ## 4:sales/TA
        ## 5:TL/TA
        ## 6:CASH/TA
        ## 7cash/CL
        ## 8:CL/TL
        ## 9:LB/TL
        ## 10:BE/TL
        ## 11:BE/CL
        ## 12:TA in million for log(TA/median TA )
        ## 13:TA/TL for log(TA/TL)
    firmspecific_BeforeAverDiff[(end-l+1):end, [7, 9]] = [firminfo[:, 3] firminfo[:, 6]]    ## Col7:NI/TA, Col9:Cash/TA
    firmspecific =
        load(PathStruct["CRI_Calibration_Parameter"]*"firmspecific_BeforeAverDiff_"*string(countrycode)*".jld")["firmspecific"]
    tmpfirm = nanMean(firmspecific[:, 2:5, :], 3)
    idxtmp = Int.(ismember_CK(firmspecific_BeforeAverDiff[(end-l+1):end, 2:3], tmpfirm[:, 1:2], "rows")[2])
    firmspecific_BeforeAverDiff[(end-l+1):end, 4:5] = tmpfirm[idxtmp, 3:4]
    return firmspecific_BeforeAverDiff, monthNumbers
end
