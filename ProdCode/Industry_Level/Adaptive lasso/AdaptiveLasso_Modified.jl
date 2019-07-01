function AdaptiveLasso_Modified(DifferentY_Columnwise_FewNansAllowed, TheSameX_NonnanMatrix_WithoutIntercept, switch_parallel::Bool = false)
  # DifferentY_Columnwise_FewNansAllowed, TheSameX_NonnanMatrix_WithoutIntercept = y, x
 # switch_parallel = false
    #=
        This function is used to Calibrate Factor Regression with EconCCI added using AdaptiveLasso method
        Inputs:
            DifferentY_Columnwise_FewNansAllowed :: Matrix
            TheSameX_NonnanMatrix_WithoutIntercept :: Matrix
            switch_parallel :: Bool
        Outputs:
            EstimatedCoefficients_WithAdditionalIntercept
        by Caesar
    =#

    # DifferentY_Columnwise_FewNansAllowed = deepcopy(CalibrationOfLogPdFactorRegression["DifferentY_Columnwise_FewNansAllowed"][startIdx:end, iLoc])
    # TheSameX_NonnanMatrix_WithoutIntercept = deepcopy(CalibrationOfLogPdFactorRegression["TheSameX_NonnanMatrix_WithoutIntercept"][startIdx:end, :])
    # switch_parallel = false
    EstimatedCoefficients_WithAdditionalIntercept = fill(NaN64, 1 + size(TheSameX_NonnanMatrix_WithoutIntercept, 2), size(DifferentY_Columnwise_FewNansAllowed, 2))
    ## preset and precheck 2
    @assert size(DifferentY_Columnwise_FewNansAllowed, 1) == size(TheSameX_NonnanMatrix_WithoutIntercept, 1)
    any(isnan.(TheSameX_NonnanMatrix_WithoutIntercept[:])) && error("There exists nan in TheSameX_NonnanMatrix_WithoutIntercept!!!")

    ## Nan Number detecting
    FlagNan = isnan.(DifferentY_Columnwise_FewNansAllowed)
    NoOfNonNans = sum(.~FlagNan,  dims = 1)
    # writeMat("nan.mat", ("FlagNan1", "NoOfNonNans1"), (Int.(FlagNan), NoOfNonNans))
    ##  Detect all-nan Y columns if any
    IdxOfY_AllNans = findall(vec(all(FlagNan, dims = 1)))
    if  ~isempty(IdxOfY_AllNans)
         EstimatedCoefficients_WithAdditionalIntercept[:, IdxOfY_AllNans] = fill(NaN, 1+size(TheSameX_NonnanMatrix_WithoutIntercept,2),  length(IdxOfY_AllNans))
    end

    ## Detect and process almost-unchanged Y columns if any, for fast processing
    Flag1OfY_AlmostIdenticalEntries =
        maximum(DifferentY_Columnwise_FewNansAllowed, dims = 1) - minimum(DifferentY_Columnwise_FewNansAllowed, dims = 1) .< 1e-8
    Flag2OfY_AlmostIdenticalEntries = sum(abs.(diff(DifferentY_Columnwise_FewNansAllowed)) .> 1e-8, dims = 1) .<= 3
    FlagOfY_AlmostIdenticalEntries = Flag1OfY_AlmostIdenticalEntries .| Flag2OfY_AlmostIdenticalEntries
    IdxOfY_AlmostIdenticalEntries  = findall(vec(FlagOfY_AlmostIdenticalEntries))
    # writeMat("nan.mat", ("FlagOfY_AlmostIdenticalEntries1"), (Int.(FlagOfY_AlmostIdenticalEntries)))
    if ~isempty(IdxOfY_AlmostIdenticalEntries)
        EstimatedCoefficients_WithAdditionalIntercept[:, IdxOfY_AlmostIdenticalEntries] =
            [nanMedian(DifferentY_Columnwise_FewNansAllowed[:, IdxOfY_AlmostIdenticalEntries], 1)';
                zeros(size(TheSameX_NonnanMatrix_WithoutIntercept,2), length(IdxOfY_AlmostIdenticalEntries))]
    end

    ## Calculate the  parameters of Varied Non-Nan Entries of Y
    IdxOfY_VariedNonNanEntries = setdiff(findall(vec(.~FlagOfY_AlmostIdenticalEntries)), IdxOfY_AllNans)
    if !isempty(IdxOfY_VariedNonNanEntries)
        EstimatedCoefficients_WithAdditionalIntercept[:, IdxOfY_VariedNonNanEntries] = InnerProcessor_AdaLasso(DifferentY_Columnwise_FewNansAllowed[:, IdxOfY_VariedNonNanEntries], TheSameX_NonnanMatrix_WithoutIntercept, switch_parallel)
    end

    # writeMat("kk.mat", "EstimatedCoefficients_WithAdditionalIntercept1", EstimatedCoefficients_WithAdditionalIntercept)
    return EstimatedCoefficients_WithAdditionalIntercept
end


function InnerProcessor_AdaLasso(DifferentY_Columnwise::Matrix{Float64}, TheSameX_NonnanMatrix::Matrix{Float64}, switch_parallel::Bool)
    # DifferentY_Columnwise, TheSameX_NonnanMatrix = DifferentY_Columnwise_FewNansAllowed[:, IdxOfY_VariedNonNanEntries], TheSameX_NonnanMatrix_WithoutIntercept
    ## This function is used to Calculate the regression parameters of model

    # DifferentY_Columnwise = deepcopy(DifferentY_Columnwise_FewNansAllowed[:, IdxOfY_VariedNonNanEntries])
    # TheSameX_NonnanMatrix = deepcopy(TheSameX_NonnanMatrix_WithoutIntercept)
    EstimatedCoefficients = fill(NaN64, 1 + size(TheSameX_NonnanMatrix, 2), size(DifferentY_Columnwise, 2))

    if switch_parallel
        nothing  ## add parallel later on
    else
        # s = MSession()
        # eval_string(s, raw"addpath(['C:\Users\rmikk\Documents\RMI\DefaultCorrelationToJulia\ProdCode'])")
        @inbounds for j = 1:size(DifferentY_Columnwise,2)
            jRowIdx_NonNanEntriesInY = findall(vec(.~isnan.(DifferentY_Columnwise[:, j])))
            beta, runinfo = AdaptiveLasso_Genuine(DifferentY_Columnwise[jRowIdx_NonNanEntriesInY, j], TheSameX_NonnanMatrix[jRowIdx_NonNanEntriesInY, :])
            # results = AdaptiveLasso_Genuine_Matlab(DifferentY_Columnwise[jRowIdx_NonNanEntriesInY, j], TheSameX_NonnanMatrix[jRowIdx_NonNanEntriesInY, :], s)
            EstimatedCoefficients[:, j] = beta
        end
    end
    return EstimatedCoefficients

end
