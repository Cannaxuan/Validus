function retrieve_financial_statement_raw(BBG_ID, dateStart, dateEnd, fsFieldID)
    # BBG_ID, dateStart, dateEnd, fsFieldID = companyList[i], dateStart, dateEnd, 127
    ## This function retrieves the raw data of financial statements including entries and field values from SQL.

    ## Pre Retrieval
    global GConst

    numberEntry = length(GConst["FS_ENTRY"])
    FinancialStatement_v = Dict()

    ## Get the financial statement field names.
    for i = 1:numberEntry
        FinancialStatement_v[GConst["FS_ENTRY"][i]] = i
    end

    sql = "SELECT Field_Mnemonic FROM [Tier2].[REF].BBG_FIELD_DEFINITION WHERE ID IN ('$fsFieldID')"
    cnt = connectDB()
    fsFieldName = string.(Matrix(get_data_from_DMTdatabase(sql, cnt)))
    for i = 1:length(fsFieldName)
        FinancialStatement_v[fsFieldName[i]] = i + numberEntry
    end

    ## Retrieve financial statement entry.
    BBGsql= "$BBG_ID"
    sql = "select * from [TEST].[DBO].[FUN_RETRIEVE_FS_ENT]('$(BBGsql[2:end-1])','$dateStart','$dateEnd')"
    financialStatementEnt = Matrix(get_data_from_DMTdatabase(sql, cnt))
    if isempty(financialStatementEnt)
        # println("No FSEnt data for BBG_IDs: $BBG_ID")
        financialStatement_v = Array{Float64, 2}(undef, 0, (size(financialStatementEnt, 2) + 1) )
        FinancialStatement_v = Dict()
        return financialStatement_v, FinancialStatement_v
    end
    financialStatementEnt[ismissing.(financialStatementEnt)] .= NaN
    financialStatementEnt = Float64.(financialStatementEnt)

    ## Retrieve financial statement data in terms of segment because there seems a limit of integer arrays passing to the database.

    fsID = split_data(Int64.(financialStatementEnt[:, FinancialStatement_v["FS_ID"]]), 1000)

    financialStatementDat = Vector{Array{Float64, 2}}(undef, size(fsID, 1))
    for i = 1:size(fsID, 1)
        # println("financialStatementDat$i")
        ID = "$(fsID[i])"
        sql = "select * from [TEST].[DBO].[FUN_RETRIEVE_FS_DAT]('$(ID[2:end-1])', '$fsFieldID')"
        ## financialStatementDat[i] = convert(Array, get_data_from_DMTdatabase(sql, cnt))
        fSData = Matrix(get_data_from_DMTdatabase(sql, cnt))
        # if !all(ismissing.(tmp))
        if !isempty(fSData)
            fSData[ismissing.(fSData)] .= NaN
            financialStatementDat[i] = Float64.(fSData)
        else
            # println("No fSData for fsIDs: $(fsID[i])")
            financialStatementDat[i] = Array{Float64, 2}(undef, 0, size(fSData, 2))
        end
    end
    financialStatementDat = vcat(financialStatementDat...)

    if isempty(financialStatementDat)
        # println("No FSDat data for fsID: $fsID")
        financialStatement_v = Array{Float64, 2}(undef, 0, (size(financialStatementEnt, 2) + 1))
        FinancialStatement_v = Dict()
        return financialStatement_v, FinancialStatement_v
    end

    FSDatpivot = pivot(DataFrame(financialStatementDat), :x1, :x2, :x3 , ops = nanMean)
    realID = parse.(Float64, String.(names(FSDatpivot)[2:end]))
    Matrix(FSDatpivot)[ismissing.(Matrix(FSDatpivot))] .= NaN
    FSDatpivot = Float64.(Matrix(FSDatpivot))

    hasDat = in.(financialStatementEnt[:, FinancialStatement_v["FS_ID"]], [FSDatpivot[:, 1]])
    idx = indexin(financialStatementEnt[:, FinancialStatement_v["FS_ID"]], FSDatpivot[:, 1])
    financialStatement_v = cat(financialStatementEnt[hasDat, :], FSDatpivot[idx[idx .!= nothing], 2:end], dims = 2)
    financialStatement_v = Matrix(sort(DataFrame(financialStatement_v), (Symbol("x"*"$(FinancialStatement_v["BBG_ID"])"), Symbol("x"*"$(FinancialStatement_v["Period_End"])"))))

    return financialStatement_v, FinancialStatement_v
end
