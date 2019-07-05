function saveDataInExcel(PathStruct, smeModelResult_indSize, smeInfo, options)

    PDest = smeModelResult_indSize["PDest"]
    nIndustry = length(options["industryCodes"])
    nSize = size(options["nSize"], 1)
    nObs = size(PDest, 1)
    nHorizon = size(PDest, 3)

    tranPD = Array{Float64, 3}(undef, 0, nIndustry, nHorizon)
    for iObs = 1:nObs
        tmp = deepcopy(reshape(PDest[iObs, :, :], nSize, nIndustry, nHorizon))
        tranPD = cat(tranPD, tmp, dims = 1)
    end

    transFlatPD = Array{Float64, 2}(undef, size(tranPD, 1), 0)
    for iHorizon = 3:nHorizon
        tmp = tranPD[:, :, iHorizon]
        transFlatPD = cat(transFlatPD, tmp, dims = 2)
    end
    transFlatPD = transFlatPD * 10000

    noFirms = smeInfo["smeIndSizeCount"]'

    ## Write the data into the xls file 'CRI_data_latest.xls'
    CSV.write(PathStruct["Industry_Results"] * "data_table.csv",  DataFrame(transFlatPD), writeheader = false)
    CSV.write(PathStruct["Industry_Results"] * "noFirms.csv",  DataFrame(noFirms), writeheader = false)
    dateNum = year(today()) * 10000 + month(today()) * 100 + day(today())


    ## Save Zipfile's directory up one level
    deliveryFileName = PathStruct["Industry_Data"]*"Products\\P106_Validus_Industry\\CRI_data_" * string(dateNum)*"_New_System.zip"
    prog = PathStruct["PrePath"]*"Code\\Industry_Level\\CreateZipFiles.ps1"
    save_path = PathStruct["Industry_Results"]
    x = run(`powershell -command "& '$prog' '$save_path' '$deliveryFileName'"`)
    mv(deliveryFileName, PathStruct["Industry_Results"] * "CRI_data_"* string(dateNum)*"_New_System.zip", force = true)

    ##  Copy Look_Up_Table
    cp(PathStruct["SourcePath"]*"look-up-table.xlsm", PathStruct["Industry_Results"]*"look-up-table.xlsm", force = true)

end
