function generate_factors(EconCodes, dataEndMth, options, folders)
    # EconCodes, dataEndMth, options, folders = globalEconCodes, dataEndMth, options, PathStruct
     #### This function is to generate the main and common factors of the transformed data matrix.
     start = time()
     industryCodes = options["industryCodes"]
     facThresMths = 60  ## The firms with PD less than or equal to [thresMths] months will be removed
     if haskey(options, "facThresMths")
         facThresMths = options["facThresMths"]
     end
     qtIndustryFac = options["qtIndustryFac"]  ## The quantile for extracting the industry factors

     #### Generate the factor matrix of all firms (in all groups) if it does not exist
     ## if ~loadFacSuccess
     println('\n' * "@ Generate factors ...")
     ## Divide into different time obervations and generate Forward PD files
     mthObs = (fld(dataEndMth, 100)- fld(options["startMth"], 100)) *12 + mod(dataEndMth, 100) - mod(options["startMth"], 100) + 1
     parts = fld(mthObs, 100) + 1

     ## check global and generate all Econ Forward PD files
     industryFacsPD, dateVctr = generate_PDfile(folders, EconCodes, dataEndMth, mthObs, parts, facThresMths, industryCodes, qtIndustryFac)

     facs = Dict()
     facs["industryFacsPD"] = industryFacsPD
     facs["dateVctr"] = dateVctr
     facs["parts"] = parts
     s =  @sprintf "# Elapsed time = %3.2f seconds." (time()-start)
     println(s)

     return facs
end
