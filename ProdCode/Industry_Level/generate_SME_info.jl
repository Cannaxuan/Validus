function generate_SME_info(smeEconCodes, dateStart, dataEndDate, smeDateVctr, options, folders)
     start = time()
     dataEndMth = floor(Int, dataEndDate/100)
     pfThresMths = 0  ## The firms with PD less than or equal to [thresMths] months will be removed?
     if haskey(options, "pfThresMths")
         pfThresMths = options["pfThresMths"]
     end
     nSize = options["nSize"]
     industryCodes = options["industryCodes"]
     fwdPDFolder = folders["forwardPDFolder"]
     turnOverFolder = folders["SMEinfoFolder"]
     CleanDataFolder = folders["dataSource"]*"\\IDMTData\\CleanData\\"

     ##  Load the Selected Countries PD data
     nEcons = length(smeEconCodes)
     println("* The SME's information comes from $nEcons economy(s)!")
     ctyInfo = Dict()
     ctyInfo["firmList"] = []
     ctyInfo["ForwardPD"] = []
     ctyInfo["SalesRevTurn"] = []
     for iEcon = 1:nEcons
         iSmeEconCode = smeEconCodes[iEcon]
         ## generate sales_rev_turn data as Size indicator
         println(" - Collect size information from Economy $iSmeEconCode ...")
         temp =
         try
             Sales_rev_turn_raw = matread(turnOverFolder*"salesRevTurnMth_"*string(iSmeEconCode)*".mat")
             sales_rev_turn_raw = Sales_rev_turn_raw["sales_rev_turn_raw"]
             Sales_Rev_Turn_Raw = Sales_rev_turn_raw["Sales_Rev_Turn_Raw"]
         catch
             println("# No stored size data for Economy $iSmeEconCode ! Generate the new data ...")
             salesRevTurnMth = get_country_sizeInfo(iSmeEconCode, dateStart, dataEndDate, folders, options)
         end
         println("- Collect portfolio information from Economy $iSmeEconCode ...")
         try
             firmlist = load(fwdPDFolder*"firmlist_with_comp_num_"*string(iSmeEconCode)*".jld")["firmlist"]
             PD_all_forward = load(fwdPDFolder*"PD_all_forward_"*string(iSmeEconCode)*".jld")["PD_all_forward"]
         catch
             println(" # No stored data for Economy $iEcon ! Generate the new data ...")
             firmlist, PD_all_forward = get_country_PD_forward(iSmeEconCode, dataEndMth, folders)
         end
         ## Extend the date length of PD
         k_year = PD_all_forward[:, 2, :]
         mid_year = map(i -> try mean(k_year[i, .~isnan.(k_year[i, :])]) catch; NaN end, 1:size(k_year, 1))
         k_month = PD_all_forward[:, 3, :]
         mid_month = map(i -> try mean(k_month[i, .~isnan.(k_month[i, :])]) catch; NaN end, 1:size(k_month, 1))
         dateVctr = mid_year*100 + mid_month
         dateVctr = deepcopy(reshape(dateVctr, length(dateVctr), 1))

         isSmeDate, idxSmeDate = ismember_CK(smeDateVctr, dateVctr)
         isSmeDate = in.(smeDateVctr, [dateVctr])
         idxSmeDate = indexin(dateVctr[:], smeDateVctr[:])




     end






     return ctyInfo, smeInfo
end
