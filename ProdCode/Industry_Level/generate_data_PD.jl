 using ToolCK, Statistics
 function generate_data_PD(folders, econs, dataEndMth, mths = [] )
     ## This function is to generate the valid data matrices of PDs and POEs.
     ## Inputs:
     ##        econs:       economy code(s) (could be a row vector)
     ##        dataEndMth:  the end month of data for all groups [yyyymm]
     ##        mths:        the month index(s)

     #### Generate the data
     global PD_all_forward = []
     global firmlist
     global pdAllForward = []
     global firmInfo = []
     global dateVctr = []
     loadFolder = folders["forwardPDFolder"]

     for iEcon = econs
         # mths = []
         println("## Load the PD data for Economy $iEcon ...")
         temp =
            try
                 firmlist = matread(loadFolder*"firmlist_with_comp_num_"*string(Int(iEcon))*".mat" )
                 PD_all_forward = matread(loadFolder*"PD_all_forward_"*string(Int(iEcon))*".mat" )
                 PD_all_forward
            catch
                 println("-- No stored data for Econ $iEcon !  Generate the new data ..." )
                 firmlist, PD_all_forward = get_country_PD_forward(iEcon, dataEndMth, folders)
                 firmlist, PD_all_forward
            end
         if length(temp) == 2
             firmlist, PD_all_forward = temp
         else
             PD_all_forward = temp
         end

         temp_year = nanMean_CK(PD_all_forward[:, 2, :], 2)
         temp_year[temp_year .== 0] .= NaN
         temp_month = nanMean_CK(PD_all_forward[:, 3, :], 2)
         temp_month[temp_month .== 0] .= NaN
         dateVctrTmp = temp_year*100 + temp_month

         if isempty(mths)
             mths = 1:(size(PD_all_forward, 2) - 3)
         end

         ## Remove the data of the firm whose PD are all NaN
         econPDAll = PD_all_forward[:, (mths .+3), :]
         econFirmInfo = firmlist
         invalidIdx = sum(.!isnan.(econPDAll[:, 1, :]), dims = 1) .== 0
         econFirmInfo = econFirmInfo[vec(.!invalidIdx),:]
         econPDAll = econPDAll[:,:,vec(.!invalidIdx)]

         ## Sequentially construct data that include PDs from valid firms in groupArray at each month

         global dateVctr
         global pdAllForward
         global firmInfo
         if iEcon == econs[1]
             pdAllForward = econPDAll
             firmInfo = econFirmInfo
             dateVctr = dateVctrTmp
         else
             lendateVctr = length(dateVctr)
             lendateVctrTmp = length(dateVctrTmp)
             maxlendate = max(lendateVctr, lendateVctrTmp)

             temp_PD_NaN = fill(NaN, (maxlendate-lendateVctr, size(pdAllForward, 2), size(pdAllForward, 3)))
             pdAllForward = vcat(temp_PD_NaN, pdAllForward)
             dateVctr = vcat(fill(NaN, (maxlendate-lendateVctr, 1)), dateVctr)

             temp_econPD_NaN = fill(NaN, (maxlendate-lendateVctrTmp, size(econPDAll, 2), size(econPDAll, 3)))
             econPDAll = vcat(temp_econPD_NaN, econPDAll)
             dateVctrTmp = vcat(fill(NaN, (maxlendate-lendateVctrTmp, 1)), dateVctrTmp)

             pdAllForward = cat(pdAllForward, econPDAll, dims = 3)
             firmInfo = vcat(firmInfo, econFirmInfo)
             dateVctr = nanMean_CK(hcat(dateVctr, dateVctrTmp), 2)
         end
     end
     return pdAllForward, dateVctr, firmInfo
 end