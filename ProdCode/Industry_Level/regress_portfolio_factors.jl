function  regress_portfolio_factors(smeInfo, facs, resultFolder, options, indSizeOption)

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









     return regResult
end
