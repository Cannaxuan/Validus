function Cal_CountryPD_v011(Para_def, Para_other, Data, nhorizon)
    # Para_def, Para_other, Data = para_def_nonfinance, para_other_nonfinance, data[:,4:end]
    #= This script calculates cumulative default probabilities by considering
       forward defaut intensity as well as forward other-exit intensity.
       INPUT:
            Data        :   nObs * nVar matrix
            Para_def    :   nVar * nhorizon matrix, parameter sets for default/bankrupt.
            Para_other  :   nVar * nhorizon matrix, parameter sets for other exit.

       OUTPUT:
            PD          :   nObs * nhorizon matrix, default probaiblity across
                            different time horizon for different companies.
    =#
    nrows = size(Data, 1)
    deltaT = 1/12
    var = [ones(nrows) Data]

    lambda_ij_def = exp.(var*Para_def)
    lambda_ij_other = exp.(var*Para_other)

    sum_lambda_ij = cumsum(lambda_ij_def[:, 1:nhorizon-1] + lambda_ij_other[:, 1:nhorizon-1], dims = 2)
    cond_PD = @. 1 - exp(-lambda_ij_def*deltaT)
    PD = cumsum(cond_PD .* [ones(nrows) exp.(-sum_lambda_ij*deltaT)], dims = 2)

    return PD
end
