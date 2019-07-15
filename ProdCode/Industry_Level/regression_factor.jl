function regression_factor(dataMtrx3D, factorMtrx3D, resultFolder, regMethod, options)
     # dataMtrx3D, factorMtrx3D, resultFolder, regMethod = transSamplePDHorizon, PDFacs, resultFolder, regMethod
     nFacs = size(factorMtrx3D, 2)
     valid1stRow = findfirst(sum(.!isnan.(factorMtrx3D[:, :, 1]), dims = 2)[:] .== nFacs)
     dataMtrx3D = dataMtrx3D[(valid1stRow:end), :, :]
     factorMtrx3D = factorMtrx3D[(valid1stRow:end), :, :]
     nRows, nCols, nHorizon = size(dataMtrx3D)

     if regMethod == "lasso"
         residAll = Array{Float64}(undef, size(dataMtrx3D, 1), 0)
         rsqrAll = Array{Float64}(undef, size(dataMtrx3D, 2), 0)
         dataMtrxEstAll = Array{Float64}(undef, size(dataMtrx3D, 1), 0)
         coefAll = Array{Float64}(undef, size(factorMtrx3D, 2) + 1, 0)
         coefficient = Array{Float64}(undef, size(factorMtrx3D, 2) + 1, size(dataMtrx3D, 2), 0)
         println("AdaptiveLasso estimation")
         for iHorizon = 1:60
             println("     # Estimating horizon = $iHorizon ")
             dataMtrx = dataMtrx3D[:, :, iHorizon]
             factorMtrx = factorMtrx3D[:, :, iHorizon]
             par = Dict()
             par["initial"] = "Lasso"
             par["isPrint"] = 1
             coef = Array{Float64,2}(undef, 11, 0)
             for i = 1:size(dataMtrx, 2)
                 y = dataMtrx[:,i]
                 x = factorMtrx
                 noNaNrow = .!isnan.(y)
                 y = y[noNaNrow]
                 x = x[noNaNrow, :]
                 # println("We are at i = $i")
                 beta, runinfo = AdaptiveLasso_Genuine(y, x, options, par)
                 coef = cat(coef, beta, dims = 2)
             end
             dataMtrxEst = coef[1,:]' .+ factorMtrx * coef[2:end, :]
             resid = dataMtrx - dataMtrxEst
             dev = dataMtrx .- nanMean(dataMtrx, 1)'
             rsqr = 1 .- (nanSum(resid .* resid, 1) ./ nanSum(dev .* dev, 1))

             dataMtrxEstAll = cat(dataMtrxEstAll, dataMtrxEst, dims = 2)
             residAll = cat(residAll, resid, dims = 2)
             rsqrAll = cat(rsqrAll, rsqr, dims = 2)
             coefAll = cat(coefAll, coef, dims = 2)
             coefficient = cat(coefficient, reshape(coef, size(coef, 1),size(coef, 2), 1), dims = 3)
         end
         Y = dataMtrx3D; X = factorMtrx3D
         AdaptiveLasso_Input_And_Output = Dict()
         AdaptiveLasso_Input_And_Output["Y"] = Y
         AdaptiveLasso_Input_And_Output["X"] = X
         AdaptiveLasso_Input_And_Output["coefficient"] = coefficient
         # matwrite(resultFolder*"\\AdaptiveLasso_Input_And_Output.mat", AdaptiveLasso_Input_And_Output)
         save(resultFolder*"\\AdaptiveLasso_Input_And_Output.jld","AdaptiveLasso_Input_And_Output", AdaptiveLasso_Input_And_Output, compress = true)
     end
     regFacRes = Dict()
     regFacRes["coef"] = coefAll
     regFacRes["rsqr"] = rsqrAll
     regFacRes["resid"] = residAll
     regFacRes["dataMtrxEst"] = dataMtrxEstAll

     return regFacRes
end
