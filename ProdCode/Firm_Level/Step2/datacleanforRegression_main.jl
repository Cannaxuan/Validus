function datacleanforRegression_main(PathStruct, DataMonth, smeEcon, PDEcon)
    ## DTDlist cols
    ## 1:CompNo,    2:Year,     3:Month,    4:DTDlevel,     5:DTDtrend,     6:Sigma,    7:M2B
    DTDlist = load(PathStruct["Firm_DTD_Regression_CriRiskFactor"]*"DTD_Source_Combined.jld")["DTD_Source_Combined"]
    #=
     SME table cols
     1: CompNo  2: monthDate  3: industryID  4: econID  5: Sales  6: CL       7: LTB    8: TL
     9: TA      10:rfr        11:stkrtn      12:NI2TA   13:Cash   14:fxrate   15:tmr    16:Sales2TA
     17:CA      18:NI         19:BE
    =#
    Metable = load(PathStruct["Firm_DTD_Regression_FS"]*"Me_DTDInput.jld")["Me_DTDInput"]
	Smtable = load(PathStruct["Firm_DTD_Regression_FS"]*"Sm_DTDInput.jld")["Sm_DTDInput"]
	Mitable = load(PathStruct["Firm_DTD_Regression_FS"]*"Mi_DTDInput.jld")["Mi_DTDInput"]

    DTDlist.CompNo = fld.(DTDlist.CompNo, 1000)
    DTDlist.monthDate = DTDlist.Year * 100 + DTDlist.Month
    DTDlist = DTDlist[:, [:CompNo, :Sigma, :M2B, :DTD, :monthDate]]

    #=
     SME table cols after join DTD
     1: CompNo  2: monthDate  3: industryID  4: econID   5: Sales   6: CL       7: LTB    8: TL
     9: TA      10:rfr        11:stkrtn      12:NI2TA    13:Cash    14:fxrate   15:tmr    16:Sales2TA
     17:CA      18:NI         19:BE          20:Sigma    21:M2B     22:DTD
    =#
    IncreMetable = DTDmapping(Metable, DTDlist)
    IncreSmtable = DTDmapping(Smtable, DTDlist)
    IncreMitable = DTDmapping(Mitable, DTDlist)

    # median TA and median BE by smeEcon
    medianVtr = globalMedianVctr(PathStruct, DataMonth)

    #=
        finalX:   :NI2TA, :Sales2TA, :TL2TA, :Cash2TA, :Cash2CL, :CL2TL, :LTB2TL,
                  :BE2TL, :BE2CL, :LogTA2median, :LogTA2TL, :rfr, :fxrate, :stkrtn, :medianDTD, :medianOverSigma
        finalXres::NI2TA, :Cash2TA, :CL2TL, :BE2CL, :LogTA2TL, :medianDTD, :medianOverSigma
    =#
    DTDMe, finalMeX, DTDmedianMe, FirmIndexMe, lbMe, ubMe, industryMe, finalMeXres =
        formalizeRegressionM(IncreMetable, medianVtr)
    DTDSm, finalSmX, DTDmedianSm, FirmIndexSm, lbSm, ubSm, industrySm, finalSmXres =
        formalizeRegressionM(IncreSmtable, medianVtr)
    DTDMi, finalMiX, DTDmedianMi, FirmIndexMi, lbMi, ubMi, industryMi, finalMiXres =
        formalizeRegressionM(IncreMitable, medianVtr)

    ## Change the ColNames depends on the order of regressors
    ColNames1 = [:NI2TA, :Cash2TA, :CL2TL, :BE2CL, :LogTA2TL]
    ColNames2 = vcat(ColNames1, :medianDTD, :medianOverSigma)
    ColNames_finalX    = [:NI2TA, :Sales2TA, :TL2TA, :Cash2TA, :Cash2CL, :CL2TL, :LTB2TL, :BE2TL, :BE2CL,
                          :LogTA2median, :LogTA2TL, :rfr, :stkrtn, :fxrate, :medianDTD, :medianOverSigma]
    ColNames_DTDmedian = [:monthDate, :econID, :DTD, :OverSigma, :Count, :M2B, :Sigma, :medianTA, :medianBE]

    ## Convert to matrix
    ## replaced finalMeX's col 13 :fxrate and col 14 :stkrtn
    finalMeX    = Matrix(finalMeX[ColNames_finalX])
    DTDmedianMe = Matrix(DTDmedianMe[ColNames_DTDmedian])
    FirmIndexMe = Matrix(FirmIndexMe)
    lbMe        = Matrix(lbMe[ColNames1])
    ubMe        = Matrix(ubMe[ColNames1])
    finalMeXres = Matrix(finalMeXres[ColNames2])

    finalSmX    = Matrix(finalSmX[ColNames_finalX])
    DTDmedianSm = Matrix(DTDmedianSm[ColNames_DTDmedian])
    FirmIndexSm = Matrix(FirmIndexSm)
    lbSm        = Matrix(lbSm[ColNames1])
    ubSm        = Matrix(ubSm[ColNames1])
    finalSmXres = Matrix(finalSmXres[ColNames2])

    finalMiX    = Matrix(finalMiX[ColNames_finalX])
    DTDmedianMi = Matrix(DTDmedianMi[ColNames_DTDmedian])
    FirmIndexMi = Matrix(FirmIndexMi)
    lbMi        = Matrix(lbMi[ColNames1])
    ubMi        = Matrix(ubMi[ColNames1])
    finalMiXres = Matrix(finalMiXres[ColNames2])

    ## Lasso Regression
    println(repeat("#", 100))
    betaMe, RsMe = LassoRegression(DTDMe, finalMeXres, ColNames2)
    betaSm, RsSm = LassoRegression(DTDSm, finalSmXres, ColNames2)
    betaMi, RsMi = LassoRegression(DTDMi, finalMiXres, ColNames2)

    ## save for CST
    # samplebetaMe = DataFrame(betaMe')
    # names!(samplebetaMe, [:Constant; ColNames_finalX])
    # CSV.write(PathStruct["Firm_DTD_Regression_Parameter"]*"beta.csv",  samplebetaMe)

    save(PathStruct["SMEPD_Input"]*"sampleMatrices.jld",
        "finalMeX", finalMeX, "finalSmX", finalSmX, "finalMiX", finalMiX,
        "FirmIndexMe", FirmIndexMe, "FirmIndexSm", FirmIndexSm, "FirmIndexMi", FirmIndexMi,
        "DTDMe", DTDMe, "DTDSm", DTDSm, "DTDMi", DTDMi,
        "lbMe", lbMe, "ubMe", ubMe, "lbSm", lbSm, "ubSm", ubSm, "lbMi", lbMi, "ubMi", ubMi, compress = true)

    CSV.write(PathStruct["SMEPD_Input"]*"finalMeX.csv",DataFrame(finalMeX))
    CSV.write(PathStruct["SMEPD_Input"]*"FirmIndexMe.csv",DataFrame(FirmIndexMe))
    CSV.write(PathStruct["SMEPD_Input"]*"lbMe.csv",DataFrame(lbMe))
    CSV.write(PathStruct["SMEPD_Input"]*"ubMe.csv",DataFrame(ubMe))

    CSV.write(PathStruct["SMEPD_Input"]*"finalSmX.csv",DataFrame(finalSmX))
    CSV.write(PathStruct["SMEPD_Input"]*"FirmIndexSm.csv",DataFrame(FirmIndexSm))
    CSV.write(PathStruct["SMEPD_Input"]*"lbSm.csv",DataFrame(lbSm))
    CSV.write(PathStruct["SMEPD_Input"]*"ubSm.csv",DataFrame(ubSm))

    CSV.write(PathStruct["SMEPD_Input"]*"finalMiX.csv",DataFrame(finalMiX))
    CSV.write(PathStruct["SMEPD_Input"]*"FirmIndexMi.csv",DataFrame(FirmIndexMi))
    CSV.write(PathStruct["SMEPD_Input"]*"lbMi.csv",DataFrame(lbMi))
    CSV.write(PathStruct["SMEPD_Input"]*"ubMi.csv",DataFrame(ubMi))


    save(PathStruct["Firm_DTD_Regression_Parameter"]*"beta.jld",
        "betaMe", betaMe, "betaSm", betaSm, "betaMi", betaMi,
        "RsMe", RsMe, "RsSm", RsSm, "RsMi", RsMi, compress = true)


    save(PathStruct["Firm_DTD_Regression_CriRiskFactor"]*"medianInfo.jld",
        "DTDmedianMe", DTDmedianMe, "DTDmedianSm", DTDmedianSm, "DTDmedianMi", DTDmedianMi, compress = true )

        CSV.write(PathStruct["SMEPD_Input"]*"DTDmedianMe.csv",DataFrame(DTDmedianMe))
        CSV.write(PathStruct["SMEPD_Input"]*"DTDmedianSm.csv",DataFrame(DTDmedianSm))
        CSV.write(PathStruct["SMEPD_Input"]*"DTDmedianMi.csv",DataFrame(DTDmedianMi))

    ## trans from mat to jld
    firmlist = read_jld(PathStruct["Firm_Specific"]*"firmList_withCompNum_"*string(PDEcon)*".jld")["firmList_withCompNum"]
    ##  matread(PathStruct["Firm_Specific"]*"firmList_withCompNum_"*string(PDEcon)*".mat")["firmList_withCompNum"]

    save(PathStruct["CRI_Calibration_Parameter"]*"firmList_with_comp_num_"*string(PDEcon)*".jld",
        "firmlist", firmlist, compress = true)

    firmspecific = read_jld(PathStruct["Firm_Specific"]*"firmSpecific_afterNormalize_beforeAverDiff_"*string(PDEcon)*".jld")["firmSpecific_afterNormalize_beforeAverDiff"]
    ## matread(PathStruct["Firm_Specific"]*"firmSpecific_afterNormalize_beforeAverDiff_"*string(PDEcon)*".mat")["firmSpecific_afterNormalize_beforeAverDiff"]

    save(PathStruct["CRI_Calibration_Parameter"]*"firmspecific_BeforeAverDiff_"*string(PDEcon)*".jld",
        "firmlist", firmlist, "firmspecific", firmspecific)

    cp(PathStruct["Firm_Specific"]*"UpLwBounds_"*string(PDEcon)*".csv",
       PathStruct["CRI_Calibration_Parameter"]*"UpLwBounds_"*string(PDEcon)*".csv", force = true)

    ## find the parameter file in dirac and copy it to validus path
    files = searchdir(PathStruct["paramPath"]*"current_smc\\", "C"*string(PDEcon)*"_")
    idx = maximum(findfirst.(isequal('_'), files))
    CALIBRATION_DATE = maximum(map(x->parse(Int, x[idx+1:idx+8]), files))

    ## for further PD calculate by countrycode
    cp(PathStruct["paramPath"]*"current_smc\\C"*string(PDEcon)*"_"*string(CALIBRATION_DATE)*".csv",
    PathStruct["CRI_Calibration_Parameter"]*"C"*string(PDEcon)*"_"*string(CALIBRATION_DATE)*".csv", force = true)


end
