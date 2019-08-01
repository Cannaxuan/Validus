function LassoRegression(YY, XX, ColNames)
    # YY, XX, ColNames = DTDMi, finalMiXres, ColNames2
    global GC
    par = Dict()
    par["initial"] = "Lasso"
    par["isPrint"] = 1
    println("=== Addaptive Lasso (Initial estimator: lasso) ===")
    nTests = 10
    betaAll = Array{Float64,2}(undef, 8, 0)
    rsqrAll = Array{Float64,2}(undef, 1, 0)
    for iTest = 1:nTests
        # global betaAll, rsqrAll
        par["randseed"] = iTest
        beta, info = AdaptiveLasso_Genuine(YY, XX, par)
        if iTest == 1
            betaAll = beta
            rsqrAll = info["Step2"]["rsqr"]
        else
            betaAll = hcat(betaAll, beta)
            rsqrAll = hcat(rsqrAll, info["Step2"]["rsqr"])
        end
    end

    ##  Two sequential steps to select beta from candidate solutions
    ## 1) Select the variables according the number of occrence
    ## 2) Select the beta with the largest rsqrs
    isZeroBetaAll = betaAll .!= 0
    idxVariInBeta = sum(isZeroBetaAll, dims = 2) .> nTests/2
    idxSelBeta = all((isZeroBetaAll .- idxVariInBeta) .== 0, dims = 1)
    idxBestBeta = findfirst(rsqrAll .== maximum(rsqrAll[idxSelBeta]))[2] ## find the column
    beta = betaAll[:, idxBestBeta]

    ## for R square
    Rs = rsqrAll[:, idxBestBeta]

    RegressorsName = [:Constant; ColNames]

    idx = findall(beta .!= 0)
    println(repeat("-", 100))
    println("Selected Regressors:")
    for i in idx
        println(string.(RegressorsName[i]))
    end
    beta = [beta[1], beta[2], 0, 0, beta[3], 0, beta[4], 0, 0, beta[5], 0, beta[6], 0, 0, 0, beta[7], beta[8]]
    return beta, Rs
end
