function datacleanforRegression_main(PathStruct, DataMonth, smeEcon, PDEcon)

    DTDlist = load(PathStruct["Firm_DTD_Regression_CriRiskFactor"]*"DTD_Source_Combined.jld")["DTD_Source_Combined"]
    Metable = load(PathStruct["Firm_DTD_Regression_FS"]*"Me_DTDInput.jld")["Me_DTDInput"]
	Smtable = load(PathStruct["Firm_DTD_Regression_FS"]*"Sm_DTDInput.jld")["Sm_DTDInput"]
	Mitable = load(PathStruct["Firm_DTD_Regression_FS"]*"Mi_DTDInput.jld")["Mi_DTDInput"]

    DTDlist.CompNo = fld.(DTDlist.CompNo, 1000)
    DTDlist.monthDate = DTDlist.Year * 100 + DTDlist.Month
    DTDlist = DTDlist[:, [:CompNo, :Sigma, :M2B, :DTD, :monthDate]]

    IncreMetable = DTDmapping(Metable, DTDlist)
    IncreSmtable = DTDmapping(Smtable, DTDlist)
    IncreMitable = DTDmapping(Mitable, DTDlist)


    # median TA and median BE
    medianVtr = globalMedianVctr(PathStruct, DataMonth)

    ##
    DTDMe, finalMeX, DTDmedianMe, FirmIndexMe, lbMe, ubMe, industryMe, finalMeXres =
        formalizeRegressionM(IncreMetable, medianVtr)
    DTDSm, finalSmX, DTDmedianSm, FirmIndexSm, lbSm, ubSm, industrySm, finalSmXres =
        formalizeRegressionM(IncreSmtable, medianVtr)
    DTDMi, finalMiX, DTDmedianMi, FirmIndexMi, lbMi, ubMi, industryMi, finalMiXres =
        formalizeRegressionM(IncreMitable, medianVtr)

    ## Change the ColNames depends on the order of regressors
    ColNames1 = [:NI2TA, :Cash2TA, :CL2TL, :BE2CL, :LogTA2TL]
    ColNames2 = vcat(ColNames1, :medianDTD, :medianOverSigma)
    ColNames_finalX = [:NI2TA, :Sales2TA, :TL2TA, :Cash2TA, :Cash2CL, :CL2TL, :LTB2TL, :BE2TL, :BE2CL, :LogTA2median, :LogTA2TL, :rfr, :stkrtn, :fxrate, :medianDTD, :medianOverSigma]
    ColNames_DTDmedian = [:monthDate, :econID, :DTD, :OverSigma, :Count, :M2B, :Sigma, :medianTA, :medianBE]

    ## Convert to matrix
    finalMeX = Matrix(finalMeX[ColNames_finalX])
    DTDmedianMe = Matrix(DTDmedianMe[ColNames_DTDmedian])
    FirmIndexMe = Matrix(FirmIndexMe)
    lbMe = Matrix(lbMe[ColNames1])
    ubMe = Matrix(ubMe[ColNames1])
    finalMeXres = Matrix(finalMeXres[ColNames2])

    finalSmX = Matrix(finalSmX[ColNames_finalX])
    DTDmedianSm = Matrix(DTDmedianSm[ColNames_DTDmedian])
    FirmIndexSm = Matrix(FirmIndexSm)
    lbSm = Matrix(lbSm[ColNames1])
    ubSm = Matrix(ubSm[ColNames1])
    finalSmXres = Matrix(finalSmXres[ColNames2])

    finalMiX = Matrix(finalMiX[ColNames_finalX])
    DTDmedianMi = Matrix(DTDmedianMi[ColNames_DTDmedian])
    FirmIndexMi = Matrix(FirmIndexMi)
    lbMi = Matrix(lbMi[ColNames1])
    ubMi = Matrix(ubMi[ColNames1])
    finalMiXres = Matrix(finalMiXres[ColNames2])

    ## Lasso Regression
    println(repeat("#", 100))
    betaMe, RsMe = LassoRegression(DTDMe, finalMeXres, ColNames2)
    betaSm, RsSm = LassoRegression(DTDSm, finalSmXres, ColNames2)
    betaMi, RsMi = LassoRegression(DTDMi, finalMiXres, ColNames2)

    save(PathStruct["SMEPD_Input"]*"sampleMatrices.jld", "finalMeX", finalMeX, "finalSmX", finalSmX, "finalMiX", finalMiX,
    "FirmIndexMe", FirmIndexMe, "FirmIndexSm", FirmIndexSm, "FirmIndexMi", FirmIndexMi, "DTDMe", DTDMe, "DTDSm", DTDSm,
    "DTDMi", DTDMi, "lbMe", lbMe, "ubMe", ubMe, "lbSm", lbSm, "ubSm", ubSm, "lbMi", lbMi, "ubMi", ubMi, compress = true)

    save(PathStruct["Firm_DTD_Regression_Parameter"]*"beta.jld", "betaMe", betaMe, "betaSm", betaSm, "betaMi", betaMi,
    "RsMe", RsMe, "RsSm", RsSm, "RsMi", RsMi, compress = true)

    save(PathStruct["Firm_DTD_Regression_CriRiskFactor"]*"medianInfo.jld", "DTDmedianMe", DTDmedianMe, "DTDmedianSm", DTDmedianSm,
    "DTDmedianMi", DTDmedianMi, compress = true )


    firmlist =
        matread(PathStruct["Firm_Specific"]*"firmList_withCompNum_"*string(PDEcon)*".mat")["firmList_withCompNum"]

    save(PathStruct["CRI_Calibration_Parameter"]*"firmList_with_comp_num_"*string(PDEcon)*".jld",
     "firmlist", firmlist, compress = true)

    firmspecific =
        matread(PathStruct["Firm_Specific"]*"firmSpecific_afterNormalize_beforeAverDiff_"*string(PDEcon)*".mat")["firmSpecific_afterNormalize_beforeAverDiff"]

    save(PathStruct["CRI_Calibration_Parameter"]*"firmspecific_BeforeAverDiff_"*string(PDEcon)*".jld",
    "firmlist", firmlist, "firmspecific", firmspecific)

    cp(PathStruct["Firm_Specific"]*"UpLwBounds_"*string(PDEcon)*".csv",
       PathStruct["CRI_Calibration_Parameter"]*"UpLwBounds_"*string(PDEcon)*".csv", force = true)

    files = searchdir(PathStruct["paramPath"]*"current_smc\\", "C"*string(PDEcon)*"_")
    CALIBRATION_DATE = maximum(map(x->parse(Int, x[4:11]), files))

    cp(PathStruct["paramPath"]*"current_smc\\C"*string(PDEcon)*"_"*string(CALIBRATION_DATE)*".csv",
    PathStruct["CRI_Calibration_Parameter"]*"C"*string(PDEcon)*"_"*string(CALIBRATION_DATE)*".csv", force = true)


end
