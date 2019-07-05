function convert_currencyID_to_FXID(currencyID, region)
     # currencyID, region = currency, GC["REGION_OF_ECON"][iEcon]
    ##  This function converts currency ID into its corresponding FX ID with USD in a particualr time zone.
    global GC
    timeZone = GC["REGIONTIMEZONE"][region]
    currencyID = Int64.(unique(currencyID))
    strID = "$currencyID"[2:end-1]
    idx = uniqueidx(currencyID)[2] ## IC
    sql = "Select * from [Test].[DBO].[RETRIEVE_FX_ID]('$strID','$timeZone')"
    cnt = connectDB()
    fxID = Int64.(Matrix(get_data_from_DMTdatabase(sql, cnt)))

    isIn = in.(currencyID, [fxID[:,1]])
    idx = indexin(currencyID, fxID[:,1])

    inID = hcat(currencyID[isIn, 1], fxID[idx[idx .!= nothing], 2])
    notInID = hcat(currencyID[.!isIn, 1], Int64.(zeros(size(currencyID[.!isIn, 1],1))))
    currencyID = vcat(inID, notInID)

    return currencyID
end
