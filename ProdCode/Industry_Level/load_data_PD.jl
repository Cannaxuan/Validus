function  load_data_PD(folders, loadName, econCodesInput, ipart)
    # folders, loadName, econCodesInput, dataEndMth = folders, PDFileName, EconCodes, dataEndMth
    ## This function is to load the full data matrices of PD if it exists.
    println("Generate Global CCI for Part "*string(ipart)*" ...")

    fileidx = findfirst(".jld", loadName)
    fileName = loadName[1:fileidx[1]-1]
    loadFolder = folders["forwardPDFolder"]

    MtrxPD, dateVctr, firmInfo = generate_data_PD(folders, econCodesInput, ipart)
    ## test econCodesInput=[1 3]
    # econCodes = econCodesInput
    if ~isdir(loadFolder)
        mkdir(loadFolder)
    end
    MtrxPD = permutedims(MtrxPD, [1, 3, 2])
    # dataMtrxPD = ipart == 1 ? MtrxPD : cat(dataMtrxPD, MtrxPD, dims = 1)
    # MtrxPD = PermutedDimsArray(MtrxPD, [1, 3, 2])

    ## save PD_forward.jld files
    save(loadFolder*fileName*".jld", "MtrxPD", MtrxPD, "dateVctr", dateVctr, "firmInfo", firmInfo, "econCodesInput", econCodesInput, compress = true)

    return MtrxPD, dateVctr, firmInfo
end
