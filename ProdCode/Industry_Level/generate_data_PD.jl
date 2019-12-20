function  generate_data_PD(folders, loadName, econCodesInput, ipart, mths = [])

    ## This function is to generate the valid data matrices of PDs and POEs.
    println("Generate Global CCI for Part "*string(ipart)*" ...")

    fileidx = findfirst(".jld", loadName)
    fileName = loadName[1:fileidx[1]-1]
    loadFolder = folders["forwardPDFolder"]

    ## MtrxPD, dateVctr, firmInfo = generate_data_PD(folders, loadName, econCodesInput, ipart)
    #### Generate the data
    PD_all_forward = []
    firmlist = []
    PD_all_forward_part = []
    pdAllForward = []
    firmInfo = []
    dateVctr = []

    ## Generate Global CCI with seperate time observations.
    for iEcon = econCodesInput
         println("load all Forward PD for Econ $iEcon")
         PD_all_forward = load(loadFolder*"PD_all_forward_"*string(Int(iEcon))*"Part"*string(Int(ipart))*".jld")["PD_all_forward_Part$(Int(ipart))"]
         temp_year = nanMean(PD_all_forward[:, 2, :], 2)
         temp_year[temp_year .== 0] .= NaN
         temp_month = nanMean(PD_all_forward[:, 3, :], 2)
         temp_month[temp_month .== 0] .= NaN
         dateVctrTmp = temp_year*100 + temp_month

         if isempty(mths)
             mths = 1:(size(PD_all_forward, 2) - 3)
         end

         ## No need to remove the data of the firm whose PD are all NaN,
         ## since the data of the firm with PD less than or equal to [thresMths] months have been removed
         econPDAll = PD_all_forward[:, (mths .+3), :]
         econFirmInfo = load(loadFolder*"firmlist_with_comp_num_"*string(Int(iEcon))*".jld")["firmlist"]
         # invalidIdx = sum(.!isnan.(econPDAll[:, 1, :]), dims = 1) .== 0
         # econFirmInfo = econFirmInfo[vec(.!invalidIdx), :]
         # econPDAll = econPDAll[:, :, vec(.!invalidIdx)]

         PD_all_forward = nothing
         # firmlist = nothing

         ## Sequentially construct data that include PDs from valid firms in groupArray at each month

         if iEcon == econCodesInput[1]
             pdAllForward = econPDAll
             firmInfo = econFirmInfo
             dateVctr = dateVctrTmp
         else
             lendateVctr = length(dateVctr)
             lendateVctrTmp = length(dateVctrTmp)
             maxlendate = max(lendateVctr, lendateVctrTmp)

             # temp_PD_NaN = fill(NaN, (maxlendate-lendateVctr, size(pdAllForward, 2), size(pdAllForward, 3)))
             pdAllForward = vcat(fill(NaN, (maxlendate-lendateVctr, size(pdAllForward, 2), size(pdAllForward, 3))), pdAllForward)
             dateVctr = vcat(fill(NaN, (maxlendate-lendateVctr, 1)), dateVctr)

             # temp_econPD_NaN = fill(NaN, (maxlendate-lendateVctrTmp, size(econPDAll, 2), size(econPDAll, 3)))
             econPDAll = vcat(fill(NaN, (maxlendate-lendateVctrTmp, size(econPDAll, 2), size(econPDAll, 3))), econPDAll)
             dateVctrTmp = vcat(fill(NaN, (maxlendate-lendateVctrTmp, 1)), dateVctrTmp)

             pdAllForward = cat(pdAllForward, econPDAll, dims = 3)
             firmInfo = vcat(firmInfo, econFirmInfo)
             dateVctr = nanMean(hcat(dateVctr, dateVctrTmp), 2)
         end
    end

    ## MtrxPD = pdAllForward

    ## test econCodesInput=[1 3]
    # econCodes = econCodesInput
    if ~isdir(loadFolder)
        mkdir(loadFolder)
    end
    MtrxPD = permutedims(pdAllForward, [1, 3, 2])
    # dataMtrxPD = ipart == 1 ? MtrxPD : cat(dataMtrxPD, MtrxPD, dims = 1)
    # MtrxPD = PermutedDimsArray(MtrxPD, [1, 3, 2])

    ## save PD_forward.jld files
    save(loadFolder*fileName*".jld", "MtrxPD", MtrxPD, "dateVctr", dateVctr, "firmInfo", firmInfo, "econCodesInput", econCodesInput, compress = true)

    return MtrxPD, dateVctr, firmInfo
end
