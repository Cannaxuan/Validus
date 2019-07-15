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
     # transSamplePDHorizon = trans_func(samplePD)
     transSamplePDHorizon = @. log(-log(1 - samplePD))
     regPDFacsRes = regression_factor(transSamplePDHorizon, PDFacs, resultFolder, regMethod, options)
     estTransPDFlatHorizon = 1 .- exp.(-exp.(regPDFacsRes["dataMtrxEst"]))
     nObs = size(regPDFacsRes["dataMtrxEst"], 1)
     regResult = Dict()
     regResult["PDestFwd"] = deepcopy(reshape(estTransPDFlatHorizon, nObs, sum(validIndIdx), nHorizon))
     regResult["PDest"] = cumsum(regResult["PDestFwd"], dims = 3)
     regResult["coef"] = deepcopy(reshape(regPDFacsRes["coef"], 1 + size(PDFacs, 2), sum(validIndIdx), nHorizon))
     regResult["resid"] = deepcopy(reshape(regPDFacsRes["resid"], nObs, sum(validIndIdx), nHorizon))
     regResult["rsqr"] = deepcopy(reshape(regPDFacsRes["rsqr"], sum(validIndIdx), nHorizon))

     if isCheckRes
        #  Calculate the avergage R-squares of regressions accross industries
        averRsqrFacPD = nanMean(regResult["rsqr"], 1)

       println(repeat("-", 100))
       println("    $regMethod regression of the portfolios''s transformed PDs on all the PD-related factors:")
       for i = 1:length(averRsqrFacPD)
           s =  @sprintf "# Average Rsquare = %3.2f " (averRsqrFacPD[i])
           println(s)
       end
       println("    $regMethod regression of the portfolio''s transformed POEs on all the POE-related factors:")
       println(repeat("-", 100))
     end

     s =  @sprintf "   # Elapsed time = %3.2f seconds." (time()-start)
     println(s)
     return regResult
end
