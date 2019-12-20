function formalizeRegressionM(IncreTable, medianVtr)
    # IncreTable, medianVtr = IncreSmtable, medianVtr
    RatioM = RatioPart(IncreTable)
    LogRatioM = LogRatioPart(IncreTable, medianVtr)
    DTDres, finalX, monthmedian, FirmIndex, lb, ub, industry, finalXres = MacroPart(IncreTable, RatioM, LogRatioM, medianVtr)

    return DTDres, finalX, monthmedian, FirmIndex, lb, ub, industry, finalXres
end
