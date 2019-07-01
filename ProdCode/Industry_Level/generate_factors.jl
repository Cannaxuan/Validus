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
     dataMtrxPD, dateVctr = cust_data(dataMtrxPD, dataEndMth, options["startMth"], dateVctr)

     ## Remove the data of the firm with PD less than or equal to [thresMths] months
     validColIdx = deepcopy(vec(sum(isfinite.(dataMtrxPD[:, :, 1]), dims = 1) .>= facThresMths))
     dataMtrxPD = dataMtrxPD[:, validColIdx, :]
     firmInfo = firmInfo[validColIdx, :]

     ## To avoid the value Inf after transformation, replace the entries of value < eps with eps and
     ## replace the entries of value > 1-eps with 1-eps
     dataMtrxPD[dataMtrxPD .< eps(Float64)] .= eps(Float64)
     dataMtrxPD[dataMtrxPD .> (1 - eps(Float64))] .= (1 - eps(Float64))

     ## Transform the PD matrice from domain [0,1] to the whole set of real numbers
     transDataMtrxPD = trans_func(dataMtrxPD)

     ##  Generate the global industry PD factors
     println("1) Extract the global industry factors ...")
     industryFacsPD = extract_industry_factors(transDataMtrxPD, firmInfo, industryCodes, qtIndustryFac)

     facs = Dict()
     facs["industryFacsPD"] = industryFacsPD
     facs["dateVctr"] = dateVctr
     s =  @sprintf "# Elapsed time = %3.2f seconds." (time()-start)
     println(s)
     return facs
end
