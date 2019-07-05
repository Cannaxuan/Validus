function generate_SME_info(smeEconCodes, dateStart, dataEndDate, smeDateVctr, options, folders)
# smeEconCodes = smeEcon
# dateStart = PathStruct["DATE_START_DATA"]
# smeDateVctr = facs["dateVctr"]
# folders =PathStruct
     start = time()
     dataEndMth = floor(Int, dataEndDate/100)
     pfThresMths = 0  ## The firms with PD less than or equal to [thresMths] months will be removed?
     if haskey(options, "pfThresMths")
         pfThresMths = options["pfThresMths"]
     end
     nSize = options["nSize"]
     industryCodes = options["industryCodes"]
     fwdPDFolder = folders["forwardPDFolder"]
     ##
     turnOverFolder = folders["SMEinfoFolder"]
     CleanDataFolder = folders["dataSource"]*"\\IDMTData\\CleanData\\"

     ##  Load the Selected Countries PD data  ##
     nEcons = length(smeEconCodes)
     println("* The SME's information comes from $nEcons economy(s)!")
     ctyInfo = Dict()
     ctyInfo["firmList"] = Array{Float64,2}(undef, 0, 6)
     ctyInfo["ForwardPD"] = Array{Float64,3}(undef, 280, 0, 60)
     ctyInfo["SalesRevTurn"] = Array{Float64,2}(undef, 280, 0)

     for iEcon = 1:nEcons
         iSmeEconCode = smeEconCodes[iEcon]
         ## generate sales_rev_turn data as Size indicator
         println(" - Collect size information from Economy $iSmeEconCode ...")
         temp =
         try
             salesRevTurnMth = load(turnOverFolder*"salesRevTurnMth_"*string(iSmeEconCode)*".jld")["salesRevTurnMth"]
         catch
             println("# No stored size data for Economy $iSmeEconCode ! Generate the new data ...")
             salesRevTurnMth = get_country_sizeInfo(iSmeEconCode, dateStart, dataEndDate, folders, options)
             salesRevTurnMth
         end
         salesRevTurnMth = temp

         println("- Collect portfolio information from Economy $iSmeEconCode ...")
         temp =
         try
             firmlist = load(fwdPDFolder*"firmlist_with_comp_num_"*string(iSmeEconCode)*".jld")["firmlist"]
             PD_all_forward = load(fwdPDFolder*"PD_all_forward_"*string(iSmeEconCode)*".jld")["PD_all_forward"]
             firmlist, PD_all_forward
         catch
             println(" # No stored data for Economy $iSmeEconCode ! Generate the new data ...")
             firmlist, PD_all_forward = get_country_PD_forward(iSmeEconCode, dataEndMth, folders)
             firmlist, PD_all_forward
         end
         firmlist, PD_all_forward = temp

         ## Extend the date length of PD
         k_year = PD_all_forward[:, 2, :]
         mid_year = map(i -> try mean(k_year[i, .~isnan.(k_year[i, :])]) catch; NaN end, 1:size(k_year, 1))
         k_month = PD_all_forward[:, 3, :]
         mid_month = map(i -> try mean(k_month[i, .~isnan.(k_month[i, :])]) catch; NaN end, 1:size(k_month, 1))
         dateVctr = mid_year*100 + mid_month
         dateVctr = deepcopy(reshape(dateVctr, length(dateVctr), 1))

         isSmeDate = in.(smeDateVctr, [dateVctr])
         idxSmeDate = indexin(smeDateVctr[:], dateVctr[:])
         idxSmeDate = idxSmeDate[isSmeDate[:]]
         idxSmeDate = convert(Array{Int64}, idxSmeDate)

         PDAllForward = fill(NaN, (length(smeDateVctr), size(PD_all_forward, 2), size(PD_all_forward, 3)))
         PDAllForward[isSmeDate[:], :, :] = PD_all_forward[idxSmeDate, :, :]
         ctyFirmList = firmlist
         ctyForwardPD = permutedims(PDAllForward[:, 4:end, :], [1 3 2])
         # PD_all_forward = nothing

         isValid = sum(isfinite.(ctyForwardPD[:, :, 1]), dims = 1) .>= pfThresMths
         ctyFirmList = ctyFirmList[isValid[:], :]
         ctySalesRevTurn = salesRevTurnMth[:, 2, isValid[:]]

         ctyForwardPD = ctyForwardPD[:, isValid[:], :]

         size_1 = size(ctyFirmList,1)
         size_2 = size(firmlist, 1)
         println("# Number of collected firms: $size_1 (in total $size_2 listed)")

         ctyInfo["firmList"] = cat(ctyInfo["firmList"],  ctyFirmList, dims = 1)
         ctyInfo["ForwardPD"] = cat(ctyInfo["ForwardPD"], ctyForwardPD, dims = 2)
         ctyInfo["SalesRevTurn"] = cat(ctyInfo["SalesRevTurn"], ctySalesRevTurn, dims = 2)
     end


     ## Generate the smeInfo
     ## calculate smeCumPD accross size and industry
     println("# Generating Industry Size average PD")
     intCol = 1
     smeInfo = Dict()
     smeInfo["smeIndSizePD"] =
        fill(NaN, (size(ctyInfo["ForwardPD"], 1), length(industryCodes)*size(nSize, 1), size(ctyInfo["ForwardPD"], 3)))
     smeInfo["smeIndSizeCount"] =
        fill(NaN, (size(ctyInfo["ForwardPD"], 1), length(industryCodes)*size(nSize, 1)))
     smeInfo["smeIndPD"] =
        fill(NaN, (size(ctyInfo["ForwardPD"], 1), length(industryCodes), size(ctyInfo["ForwardPD"], 3)))
     smeInfo["smeIndCount"] =
        fill(NaN, (size(ctyInfo["ForwardPD"], 1), length(industryCodes)))

     for iIndu = 1: length(industryCodes)
         iInduFirmIdx =
            (repeat(reshape(in.(ctyInfo["firmList"][:,5], industryCodes[iIndu]), (1,:)),
            size(ctyInfo["ForwardPD"], 1), 1)) .& (ctyInfo["SalesRevTurn"] .>= nSize[1, 1]) .& (ctyInfo["SalesRevTurn"] .< nSize[end, end])
         iInduFirmIdxHorizon = repeat(iInduFirmIdx, inner = (1, 1, 60))
         smeInfo["smeIndPD"][:,iIndu,:] =
            sum(.!isnan.(ctyInfo["ForwardPD"] .* iInduFirmIdxHorizon), dims = 2) ./ sum(iInduFirmIdxHorizon, dims = 2)
         smeInfo["smeIndPD"][smeInfo["smeIndPD"] .== 0] .= NaN
         smeInfo["smeIndCount"][:,iIndu] = sum(iInduFirmIdxHorizon[:, :, 1], dims = 2)

         for iSize = 1:size(nSize, 1)
             iInduSizeFirmIdx = repeat(reshape(in.(ctyInfo["firmList"][:,5], industryCodes[iIndu]), (1, :)),
             size(ctyInfo["ForwardPD"], 1) , 1) .& (ctyInfo["SalesRevTurn"] .>= nSize[iSize,1]) .& (ctyInfo["SalesRevTurn"] .< nSize[iSize,2])
             smeInfo["smeIndSizeCount"][:, intCol] = sum(iInduSizeFirmIdx, dims = 2)
             iInduSizeFirmIdxHorizon = repeat(iInduSizeFirmIdx, inner = (1, 1, 60))

             temp = nanSum_CK(ctyInfo["ForwardPD"] .* iInduSizeFirmIdxHorizon, 2)
             temp_1 = reshape(temp, size(temp,1), 1, size(temp, 2))
             smeInfo["smeIndSizePD"][:,intCol,:] = temp_1 ./ sum(iInduSizeFirmIdxHorizon, dims = 2)

             smeInfo["smeIndSizePD"][smeInfo["smeIndSizePD"] .==0] .= NaN
             intCol += 1
         end
     end
     println("# The target portfolio contains $(size(ctyInfo["firmList"], 1)) firms in total!")
     s =  @sprintf "# Elapsed time = %3.2f seconds." (time()-start)
     println(s)
     return ctyInfo, smeInfo
end
