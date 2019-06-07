function generate_factors(EconCodes, dataEndMth, options, folders)
     #### This function is to generate the main and common factors of the transformed data matrix.
     start=time()
     industryCodes = options["industryCodes"]
     facThresMths = 60  ## The firms with PD less than or equal to [thresMths] months will be removed
     if haskey(options,"facThresMths")
         facThresMths=options["facThresMths"]
     end
     qtIndustryFac = options["qtIndustryFac"]  ## The quantile for extracting the industry factors

     #### Generate the factor matrix of all firms (in all groups) if it does not exist
     ## if ~loadFacSuccess
     println('\n' * "@ Generate factors ...")
     ## Load the full PD data up to [dataEndMth] (Genetate the PDPOE data if it does not exist)
     PDFileName = "PD_forward.mat"
     dataMtrxPD, dateVctr, firmInfo = load_data_PD(folders, PDFileName, EconCodes, dataEndMth)


     return facs
end
