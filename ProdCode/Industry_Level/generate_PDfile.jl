function  generate_PDfile(folders, econCodesInput, dataEndMth, mthObs, parts, facThresMths, industryCodes, qtIndustryFac)
    # folders, econCodesInput, dataEndMth, facThresMths = folders, EconCodes, dataEndMth, facThresMths
    ## This function is to load the full data matrices of PD if it exists.
# folders =  PathStruct
    loadFolder = folders["forwardPDFolder"]
    loadPDSuccess = falses(parts, 1)
    for ipart = 1:parts
        if isfile(loadFolder*"PD_forward_Part$ipart.jld")
            loadPDSuccess[ipart] = true
        else
            println("- No existing data of PD for the global economies for part $ipart !")
        end
    end

    #
    if !all(loadPDSuccess[:].==true)
        println('\n' * " # Generate new data of PD for the global economies ...")
        # loadFolder = folders["forwardPDFolder"]
        # seperate = fill(false, length(econCodesInput))
        ## Guarantee all Forward PD jld file have been created, and get the parts
        @sync @distributed for iEcon = econCodesInput
            # mths = []
            println("## Generate the PD files for Economy $iEcon ...")
            file = [loadFolder*"PD_all_forward_"*string(Int(iEcon))*"Part"*string(i)*".jld" for i in 1:parts]
            println(file)
            if !isfile(loadFolder*"firmlist_with_comp_num_"*string(Int(iEcon))*".jld") & !all(isfile.(file))
                println("-- No stored file for Econ $iEcon !  Generate the new file ..." )
                get_country_PD_forward(iEcon, dataEndMth, folders, facThresMths, parts, mthObs)
            end
        end
        ## generate global Forward PD files
        industryFacsPD = []
        dateVctr = []
        for ipart = 1:parts
            PDFileName = "PD_forward_Part$ipart.jld"
            ## Load the full PD data up to [dataEndMth] (Genetate the PDPOE data if it does not exist)
            dataMtrxPD, datelist, firmInfo = load_data_PD(folders, PDFileName, econCodesInput, ipart)
            # endMth = datelist[end]
            # startMth = max(options["startMth"], datelist[1])
            # dataMtrxPD, datelist = cust_data(dataMtrxPD, endMth, startMth, datelist)

            ## To avoid the value Inf after transformation, replace the entries of value < eps with eps and
            ## replace the entries of value > 1-eps with 1-eps
            dataMtrxPD[dataMtrxPD .< eps(Float64)] .= eps(Float64)
            dataMtrxPD[dataMtrxPD .> (1 - eps(Float64))] .= (1 - eps(Float64))

            ## Transform the PD matrice from domain [0,1] to the whole set of real numbers
            # transDataMtrxPD = trans_func(dataMtrxPD)
            transdataMtrxPD = @. log(-log(1 - dataMtrxPD))

            ##  Generate the global industry PD factors
            println("1) Extract the global industry factors for part $ipart ...")
            ## median of global Forward PD for 10 industries
            industryPD = extract_industry_factors(transdataMtrxPD, firmInfo, industryCodes, qtIndustryFac)
            industryFacsPD = ipart == 1 ? industryPD : cat(industryFacsPD, industryPD, dims = 1)
            dateVctr = ipart == 1 ? datelist : vcat(dateVctr, datelist)
        end
    else
        ## load data files
        for ipart = 1:parts
            PD_all_forward_part = load(loadFolder*"PD_forward_Part$ipart.jld")
            dataMtrxPD = PD_all_forward_part["MtrxPD"]
            datelist = PD_all_forward_part["dateVctr"]
            firmInfo = PD_all_forward_part["firmInfo"]
            PD_all_forward_part = nothing
            # endMth = datelist[end]
            # startMth = max(options["startMth"], datelist[1])
            # dataMtrxPD, datelist = cust_data(dataMtrxPD, endMth, startMth, datelist)

            ## To avoid the value Inf after transformation, replace the entries of value < eps with eps and
            ## replace the entries of value > 1-eps with 1-eps
            dataMtrxPD[dataMtrxPD .< eps(Float64)] .= eps(Float64)
            dataMtrxPD[dataMtrxPD .> (1 - eps(Float64))] .= (1 - eps(Float64))

            ## Transform the PD matrice from domain [0,1] to the whole set of real numbers
            # transDataMtrxPD = trans_func(dataMtrxPD)
            transdataMtrxPD = @. log(-log(1 - dataMtrxPD))

            ##  Generate the global industry PD factors
            println("1) Extract the global industry factors for part $ipart ...")
            ## median of global Forward PD for 10 industries
            industryPD = extract_industry_factors(transdataMtrxPD, firmInfo, industryCodes, qtIndustryFac)
            industryFacsPD = ipart == 1 ? industryPD : cat(industryFacsPD, industryPD, dims = 1)
            dateVctr = ipart == 1 ? datelist : vcat(dateVctr, datelist)
        end
    end



    return industryFacsPD, dateVctr
end
