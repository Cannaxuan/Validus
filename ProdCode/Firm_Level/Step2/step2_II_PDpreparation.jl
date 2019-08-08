function  step2_II_PDpreparation(PathStruct, DataMonth, smeEcon, countrycode = 9)

    # econs = findall(.!isnan.(PathStruct["GROUPS"]))
    econs = vcat(PathStruct["ECONSREGION"]...)

    fullperiod =
        matread(PathStruct["Industry_Data"]*"pd60hUpToMostRecent_bk.mat")["dataUpToMostRecent"][:,[1,2,3,16]]
    ## column 16 represents one year PD
    full_period_date = fullperiod[:, 2]*100 + fullperiod[:, 3]

    ## Load Total FirmHistory
    UpdatedFirmHistory = Array{Float64, 2}(undef, 0, 6)
    for i = 1:length(econs)
        # global UpdatedFirmHistory
        firmHistory = matread(PathStruct["CompanyInformationFolder"]*"FirmHistory_"*string(econs[i])*".mat")["firmHistory"]
        UpdatedFirmHistory = vcat(UpdatedFirmHistory, firmHistory[:,[1,2,3,8,10,11]])
        ## UpdatedFirmHistory columns:
        ## 1. Company Number  2.Time Start  3. Time end  4. econ  5.Sector Number  6.Group Number
    end

    ## Construct time series
    Timevec = yearmonth.(collect(Date(1988, 1, 29):Month(1):(Date(string(DataMonth), "yyyymm") + Month(1))))
    PD_all_date = first.(Timevec)*100 + last.(Timevec)

    pdAllForward = []
    firmInfo = []

    for i = 1:length(econs)
        # global Timevec, UpdatedFirmHistory, pdAllForward, firmInfos
        idx_Econs = findall(UpdatedFirmHistory[:, 4] .== econs[i])
        firmlist = UpdatedFirmHistory[idx_Econs, :]
        save(PathStruct["FullPeriodPD"]*"firmlist_with_comp_num_"*string(econs[i])*".jld", "firmlist", firmlist, compress = true)

        unique_firmlist = unique(fld.(firmlist[:, 1], 1000))
        PD_all = fill(NaN, length(Timevec), 4, size(unique_firmlist,1))
        PD_all[:, 2, :] .= first.(Timevec)
        PD_all[:, 3, :] .= last.(Timevec)

        for j = 1:length(unique_firmlist)
            # global PD_all， PD_all_date
            PD_all[:, 1, j] .= unique_firmlist[j]
            idx_fullperiod = fullperiod[:, 1] .== unique_firmlist[j]
                ##  fullperiod is from dataUpToMostRecent, the PD file;
                ##  unique_firmlist is from firmHistory, the firm information file
            idx_Date = fullperiod[idx_fullperiod, 2]*100 + fullperiod[idx_fullperiod, 3]
            a = in.(PD_all_date, [idx_Date])
            PD_all[a, 4, j] = fullperiod[idx_fullperiod, 4]     ## one year pd
        end
        save(PathStruct["FullPeriodPD"]*"PD_all_"*string(econs[i])*".jld", "PD_all", PD_all, compress = true)

        econPDAll = PD_all[:, 4, :]
        PD_all = nothing

        ## change PD_all to 2D 9 columns (col 1: comp num, col 2: date, col3-9: pd) and also take out NaN rows
        ## Attention: The number of firms in "firmlist" is more than the number of firms in "PD_all"
        x = in.(firmlist[:, 1], [unique_firmlist*1000])
        econFirmInfo = firmlist[x, :]

        ## Remove the data of the firms whose PD are all NaN
        validIdx = sum(.!isnan.(econPDAll), dims = 1) .!= 0
        econFirmInfo = econFirmInfo[validIdx[:], :]
        econPDAll = econPDAll[:, validIdx[:]]

        flag = size(econFirmInfo, 1) - size(econPDAll, 2)
        if flag != 0
            println("Strange Econ"*string(econs[i]))
        end

        ##  Sequentially construct data that includes all the PDs of all valid firms in groupArray at each month
        if i == econs[1]
            pdAllForward = econPDAll
            firmInfo = econFirmInfo
        else
            pdAllForward = hcat(pdAllForward, econPDAll)
            firmInfo = vcat(firmInfo, econFirmInfo)
        end
        println("Econ Done "*string(econs[i]))
    end

    ## the firm level data have been compared and confirmed to be identical
    dateVctr = PD_all_date

    ## add one column for tag SME indicator
    pdAllForwardtemp = reshape(deepcopy(pdAllForward), size(pdAllForward, 1), 1, size(pdAllForward, 2))
    pdAllForwardtemp = hcat(pdAllForwardtemp, fill(NaN, size(pdAllForward, 1), 1, size(pdAllForward, 2)))

    pdAllForward = nothing

    SME_SalesData = load(PathStruct["Firm_DTD_Regression_FS"]*"SME_SalesData.jld")
    MeFirms = SME_SalesData["MeFirms"]
    SmFirms = SME_SalesData["SmFirms"]
    MiFirms = SME_SalesData["MiFirms"]
    SME_SalesData = nothing

    pdAllForwardtemp = handlepdall(MeFirms, pdAllForwardtemp, firmInfo, dateVctr, 1) ## indicator 1: medium
    pdAllForwardtemp = handlepdall(SmFirms, pdAllForwardtemp, firmInfo, dateVctr, 2) ## indicator 2: small
    pdAllForwardtemp = handlepdall(MiFirms, pdAllForwardtemp, firmInfo, dateVctr, 3) ## indicator 3: micro

    save(PathStruct["FullPeriodPD"]*"pdAllForwardtemp.jld", "pdAllForwardtemp", pdAllForwardtemp, compress = true)
    save(PathStruct["FullPeriodPD"]*"firmInfo.jld", "firmInfo", firmInfo, compress = true)
    save(PathStruct["FullPeriodPD"]*"dateVctr.jld", "dateVctr", dateVctr, compress = true)

    Varresult = compute_Var_quantile(pdAllForwardtemp, dateVctr, firmInfo, smeEcon)
    save(PathStruct["SMEPD_Input"]*"Varresult.jld", "Varresult", Varresult, compress = true)

    fxratesAll = matread(PathStruct["FxPath"]*"fxRateEcon.mat")["fxRateEcon"]
    idx = Int(fxratesAll["ID"][countrycode, 3])     ## to find the match row of econ
    fxrate = fxratesAll["Data"][idx, 1]
    save(PathStruct["SMEPD_Input"]*"fxrate.jld", "fxrate", fxrate, compress = true)

end
