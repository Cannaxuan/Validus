function AdaptiveLasso_Genuine(y::Vector{Float64}, X::Matrix{Float64}, options, par = Dict())
    # y, X = y, x
    #=
        This function is used to perform Adaptive Lasso Regression
        Inputs:
            y :: Matrix
            X :: Matrix
            switch_parallel :: Bool
        Outputs:
            runinfo :: Dict, in most cases, we use runinfo["beta"]
        by Caesar
    =#

    runinfo = Dict()
    runinfo["Step1"] = Dict()
    runinfo["Step2"] = Dict()
    ## Preset Options in GLMNet
    nfold = 10 # numbers of folds in cross validation (Default = 10)
    nlambda = 100 # numbers of candidate penalty parameters in cross validation (Default = 100)
    cvRule = "lambda_min" #option to choose cross validation rule (Default = 'lambda_min')
    alpha = 1 # option to choose elastic-net mixing parameter in [0,1] (Default = 1)
    tol = 1e-6 # tolerance of final estimates (Default = 1e-6)
    randseed = 0
    isParallel = false
    isPrint = 0 # work silently (=0) or not (=1) (Default = 0)
    N, p = size(X)
    if N >= 2p
        initial = "OLS" # option to choose the initial estimator
    else
        initial = "Lasso"
    end
    if !isempty(par)
         if haskey(par,"initial"); initial = par["initial"]; end
         if haskey(par,"nfold"); nfold = par["nfold"]; end
         if haskey(par,"nlambda"); nlambda = par["nlambda"]; end
         if haskey(par,"cvRule"); cvRule = par["cvRule"]; end
         if haskey(par,"alpha"); alpha = par["alpha"]; end
         if haskey(par,"tol"); tol = par["tol"]; end
         if haskey(par,"randseed"); randseed = par["randseed"]; end
         if haskey(par,"isParallel"); isParallel = par["isParallel"]; end
         if haskey(par,"isPrint"); isPrint = par["isPrint"]; end
    end


    beta = fill(NaN64, 1 + size(X, 2)) # Outputs


    # glmnetcv will standardize X by default but OLS not
    meanX = mean(X, dims = 1)
    stdX = std(X, dims = 1)
    X_Standard = (X .- meanX) ./ stdX
    start = time()
    ## Step 1: Compute the initial estimator

    if initial == "OLS"
        # ols = fit(LinearModel, [ones(N, 1) X_OLS], y)
        # OLS_fit = fit(LinearModel, [ones(N, 1) X_OLS], y)
        data = DataFrame([X_Standard y])
        ols = lm(@formula(x11 ~ x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10), data)
        beta = StatsBase.coef(ols)
        # beta = coef(OLS_fit)
    else
        options["nlambda"] = nlambda
        options["thresh"] = tol
        options["alpha"] = alpha

        rng = Random.seed!(randseed)
        cv = glmnetcv(X, y, alpha = alpha, nlambda = nlambda, tol = tol, nfolds = nfold, parallel = isParallel)
        # cv, _ = glmnetcv(X, y, alpha = alpha, nlambda = nlambda, tol = tol, nfolds = nfold, parallel = isParallel)
        beta = [cv.path.a0[findmin(cv.meanloss)[2]]; cv.path.betas[:, findmin(cv.meanloss)[2]]]
        runinfo["Step1"]["cvinfo"] = cv
    end
    runinfo["Step1"]["beta"] = beta
    # runinfo["Step1"]["beta"] = [beta[1] .- (meanX./stdX)*beta[2:end]; beta[2:end]./(stdX)']
    runinfo["Step1"]["method"] = initial
    runinfo["Step1"]["rsqr"] = 1 - norm(y .- beta[1] .- X*beta[2:end])^2 / norm(y .- mean(y))^2

    ## Step 2: Compute the adaptive lasso estimator
    abscoef = abs.(beta[2:end])
    w = 1 ./ abscoef
    idx_nonzero = findall(vec(abscoef .!= 0))

    if ~(sum(idx_nonzero) .== 0)
        wR = w[idx_nonzero]
        xR = X[:, idx_nonzero]
        rng = Random.seed!(randseed)
        cv = glmnetcv(xR, y, alpha = alpha, nlambda = nlambda, tol = tol, nfolds = nfold, penalty_factor = wR, parallel = isParallel)
        # cv, _ = glmnetcv(xR, y, alpha = alpha, nlambda = nlambda, tol = tol, nfolds = nfold, penalty_factor = wR, parallel = isParallel)
        betaR = cv.path.betas[:, findmin(cv.meanloss)[2]]
        # betaR = cv.path.betas[:, indmin(cv.stdloss)]
        beta = zeros(p + 1, 1)
        beta[1] = cv.path.a0[findmin(cv.meanloss)[2]]  ## Intercept
        # beta[1] = cv.path.a0[indmin(cv.stdloss)]  ## Intercept
        beta[idx_nonzero .+ 1] = betaR
        runinfo["Step2"]["cvinfo"] = cv
    end

    runinfo["Step2"]["beta"] = beta
    #runinfo["Step2"]["beta"] = [beta[1] .- (meanX./stdX)*beta[2:end]; beta[2:end]./(stdX)']
    runinfo["Step2"]["weights"] = w
    runinfo["Step2"]["method"] = "TobitWeightedLasso_cv"
    runinfo["Step2"]["rsqr"] = 1 - norm(y .- beta[1] .- X*beta[2:end])^2 / norm(y .- mean(y))^2

    s =  @sprintf "# Computational time = %3.2f seconds." (time()-start)
    println(s)

    return runinfo["Step2"]["beta"], runinfo
end


function AdaptiveLasso_Genuine(y::Vector{Float64}, X::Matrix{Float64}, par = Dict())
    # y, X, par = YY, XX, par
    # #=
    #     This function is used to perform Adaptive Lasso Regression
    #     Inputs:
    #         y :: Matrix
    #         X :: Matrix
    #         switch_parallel :: Bool
    #     Outputs:
    #         runinfo :: Dict, in most cases, we use runinfo["beta"]
    #     by Caesar
    # =#

    runinfo = Dict()
    runinfo["Step1"] = Dict()
    runinfo["Step2"] = Dict()
    ## Preset Options in GLMNet
    nfold = 10 # numbers of folds in cross validation (Default = 10)
    nlambda = 100 # numbers of candidate penalty parameters in cross validation (Default = 100)
    cvRule = "lambda_min" #option to choose cross validation rule (Default = 'lambda_min')
    alpha = 1 # option to choose elastic-net mixing parameter in [0,1] (Default = 1)
    tol = 1e-6 # tolerance of final estimates (Default = 1e-6)
    randseed = 0
    isParallel = false
    isPrint = 0 # work silently (=0) or not (=1) (Default = 0)
    N, p = size(X)
    if N >= 2p
        initial = "OLS" # option to choose the initial estimator
    else
        initial = "Lasso"
    end
    if !isempty(par)
         if haskey(par,"initial"); initial = par["initial"]; end
         if haskey(par,"nfold"); nfold = par["nfold"]; end
         if haskey(par,"nlambda"); nlambda = par["nlambda"]; end
         if haskey(par,"cvRule"); cvRule = par["cvRule"]; end
         if haskey(par,"alpha"); alpha = par["alpha"]; end
         if haskey(par,"tol"); tol = par["tol"]; end
         if haskey(par,"randseed"); randseed = par["randseed"]; end
         if haskey(par,"isParallel"); isParallel = par["isParallel"]; end
         if haskey(par,"isPrint"); isPrint = par["isPrint"]; end
    end


    beta = fill(NaN64, 1 + size(X, 2)) # Outputs


    # glmnetcv will standardize X by default but OLS not
    meanX = mean(X, dims = 1)
    stdX = std(X, dims = 1)
    X_Standard = @. (X - meanX) / stdX
    start = time()

    ## Step 1: Compute the initial estimator

    if initial == "OLS"
        # ols = fit(LinearModel, [ones(N, 1) X_OLS], y)
        # OLS_fit = fit(LinearModel, [ones(N, 1) X_OLS], y)
        data = DataFrame([X_Standard y])
        ols = lm(@formula(x8 ~ x1 + x2 + x3 + x4 + x5 + x6 + x7), data)
        beta = StatsBase.coef(ols)
        # beta = coef(OLS_fit)
    else
        # options["nlambda"] = nlambda
        # options["thresh"] = tol
        # options["alpha"] = alpha
        rng = Random.seed!(randseed)
        #cv = glmnetcv(X, y, alpha = alpha, nlambda = nlambda, tol = tol, nfolds = nfold, parallel = isParallel)
        cv = glmnetcv(X_Standard, y, alpha = alpha, nlambda = nlambda, tol = tol, nfolds = nfold, parallel = isParallel)
        # cv, _ = glmnetcv(X, y, alpha = alpha, nlambda = nlambda, tol = tol, nfolds = nfold, parallel = isParallel)
        beta = [cv.path.a0[findmin(cv.meanloss)[2]]; cv.path.betas[:, findmin(cv.meanloss)[2]]]
        runinfo["Step1"]["cvinfo"] = cv
    end
    # runinfo["Step1"]["beta"] = deepcopy(beta)
    runinfo["Step1"]["beta"] = [beta[1] .- (meanX./stdX)*beta[2:end]; beta[2:end]./(stdX)']
    runinfo["Step1"]["method"] = initial
    # runinfo["Step1"]["rsqr"] = 1 - norm(y .- beta[1] .- X*beta[2:end])^2 / norm(y .- mean(y))^2
    runinfo["Step1"]["rsqr"] = 1 - norm(y .- beta[1] .- X_Standard*beta[2:end])^2 / norm(y .- mean(y))^2

    ## Step 2: Compute the adaptive lasso estimator
    abscoef = abs.(beta[2:end])
    w = 1 ./ abscoef
    idx_nonzero = findall(vec(abscoef .!= 0))

    if ~(sum(idx_nonzero) .== 0)
        wR = w[idx_nonzero]
        #xR = X[:, idx_nonzero]
        xR = X_Standard[:, idx_nonzero]
        rng = Random.seed!(randseed)
        cv = glmnetcv(xR, y, alpha = alpha, nlambda = nlambda, tol = tol, nfolds = nfold, penalty_factor = wR, parallel = isParallel)
        betaR = cv.path.betas[:, findmin(cv.meanloss)[2]]
        beta = zeros(p + 1, 1)
        beta[1] = cv.path.a0[findmin(cv.meanloss)[2]]  ## Intercept
        beta[idx_nonzero .+ 1] = betaR
        runinfo["Step2"]["cvinfo"] = cv
    end

    # runinfo["Step2"]["beta"] = beta
    runinfo["Step2"]["beta"] = [beta[1] .- (meanX./stdX)*beta[2:end]; beta[2:end]./(stdX)']
    runinfo["Step2"]["weights"] = w
    runinfo["Step2"]["method"] = "TobitWeightedLasso_cv"
    # runinfo["Step2"]["rsqr"] = 1 - norm(y .- beta[1] .- X*beta[2:end])^2 / norm(y .- mean(y))^2
    runinfo["Step2"]["rsqr"] = 1 - norm(y .- beta[1] .- X_Standard*beta[2:end])^2 / norm(y .- mean(y))^2
    s =  @sprintf "# Computational time = %3.2f seconds." (time()-start)
    println(s)
    return runinfo["Step2"]["beta"], runinfo
end
