function  regress_portfolio_factors(smeInfo, facs, resultFolder, options, indSizeOption)
# smeInfo, facs, resultFolder, options, indSizeOption =
# smeInfo, facs["industryFacsPD"], PathStruct["Industry_FactorModel"], options,"indSize"
     regMethod = "lasso"
     isCheckRes = true
     if haskey(options, "regMethod"); regMethod = options["regMethod"];  end
     if haskey(options, "isCheckRes");  isCheckRes = options["isCheckRes"]; end
     start = time()

     nHorizon = options["smeHorizon"]
     custMth = options["startMth"]
     # for iHorizon = options["smeHorizon"]
     println("# Generating result for all horizons")
     if indSizeOption == "indOnly"
         samplePD = smeInfo["smeIndPD"]
     elseif indSizeOption == "indSize"
         samplePD = smeInfo["smeIndSizePD"]
     end

     validIndIdx = sum(.!isnan.(samplePD[:, :, 1]), dims = 1) .!= 0
     ##   PDFlatHorizon = reshape(samplePD, nObs, nInd * nHorizon)
     ## To avoid the value Inf after transformation,
     ## 1) replace the entries of value less than eps with eps;
     ## 2) replace the entries of value greater than 1-eps with 1-eps.
     samplePD[samplePD .< eps(Float64)] .= eps(Float64)
     samplePD[samplePD .> (1 - eps(Float64))] .= 1 - eps(Float64)
     ## Transform the data matrix from the domain [0,1] to the whole set of real numbers
     ## transPDFlatHorizon = trans_func(PDFlatHorizon);
     ## Regression of the portfolio's PDs and POE's on the global, industry and other common factors
     PDFacs = facs
     transSamplePDHorizon = trans_func(samplePD)
     regPDFacsRes = regression_factor(transSamplePDHorizon, PDFacs, resultFolder, regMethod)











     return regResult
end
