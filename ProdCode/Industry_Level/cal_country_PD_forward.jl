function cal_country_PD_forward(firmFS, paraDef, paraOther, nHorizon=size(paraDef, 2))
    ## This script calculates (cumulative) probabilities of default and (cumulative)
    ## probability of other exit by considering forward defaut intensity
    ## as well as forward other-exit intensity.

    ## INPUT : firmFS     :    nVar * nObs matrix
    ##         paraDef    :    nVar * nhorizon matrix, parameter sets for default
    ##         paraOther  :    nVar * nhorizon matrix, parameter sets for other exit
    ##         nHorizon   :    the end month to compute

    ## OUTPUT: cumPD      :    nhorizon * nObs matrix, culmulative probability of default
    ##         cumPOE     :    nhorizon * nObs matrix, culmulative probability of other exit
    ##         PS         :    nhorizon * nObs matrix, probability of survival

    delta = 1/12

    paraDef = paraDef[:, 1:nHorizon]
    paraOther = paraOther[:, 1:nHorizon]
    intensityDefault = exp.(paraDef[1, :] .+ paraDef[2:end, :]'*firmFS)
    intensityOther = exp.(paraOther[1, :] .+ paraOther[2:end, :]'*firmFS)
    PS = exp.(cumsum((intensityDefault + intensityOther)*delta,dims=1))  ## unconditional PS
    PD = - exp.(-intensityDefault * delta) .+ 1  ## conditional PD
    forwardPD =[ones(1, size(PS,2));PS[1:end-1,:]] .* PD
    ## cumPD = cumsum(forwardPD, dims=1)
    ## cumPOE = - cumPD - PS .+1
    return forwardPD, PS
end
