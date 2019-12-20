function Cal_CountryPD_v012(G_CONST::Dict{Any,Any}, para_def::Array{Float64}, para_other::Array{Float64}, data::Array{Float64,2}, nhorizon::Int64,countrycode::Int64)
    # this script calculates cumulative default probabilities
    # by considering forward defaut intensity as well as forward other-exit()
    # intensity.
    # modified by SJ on July 9, 2010

    # INPUT : data        :   nObs * nVar matrix
    #         para_def    :   nVar * nhorizon matrix, parameter sets for
    #                         default/bankrupt
    #         para_other  :   nVar * nhorizon matrix, parameter sets for other exit()

    # OUTPUT: PD       :   nObs * nhorizon matrix, default probaiblity across
    #                         different time horizon for different companies

    ## TirmVariant
    # this function is modified from Cal_CountryPD_v11.
    # for AR computation

    nObs = size(data, 1)                                # number of firms
    deltaT = 1/12

    # obsRow_v011[data, groupnum, countrycode, dummy]
    var = [ones(nObs,1) data]

    lambda_ij_def = []
    lambda_ij_other = []
    if in(G_CONST["GROUPS"][countrycode],G_CONST["TimeVariantOfPara_COUNTRY"])

        # para_def = zeros(size(para_def1,1),size(para_def1,2),1)
        # para_def[:,:,1] = para_def1
        def_intensity = var.*permutedims(para_def,[3 2 1])
        lambda_ij_def = exp.(dropdims(sum(def_intensity,dims = 2),dims = 2))

        # para_other = zeros(size(para_other1,1),size(para_other1,2),1)
        # para_other[:,:,1] = para_other1
        oth_intensity = var.*permutedims(para_other,[3 2 1])
        lambda_ij_other = exp.(dropdims(sum(oth_intensity,dims = 2),dims = 2))


    else
        lambda_ij_def = exp.(var*para_def)
        lambda_ij_other = exp.(var*para_other)

    end


    sum_lambda_ij = cumsum(lambda_ij_def[:,1:nhorizon-1] + lambda_ij_other[:,1:nhorizon-1], dims = 2)

    cond_PD = 1 .- exp.(-lambda_ij_def * deltaT)

    PD = cumsum(cond_PD .* [ones(nObs, 1) exp.(-sum_lambda_ij * deltaT)], dims = 2)

    return PD

end
