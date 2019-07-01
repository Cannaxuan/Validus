function RetrieveDwnAccStdrd_v011()
    ## accounting standards that are not GAAP will have lower priority
    sql_query = "SELECT * FROM [Tier2].[PROD].[FUN_RETRIV_DwnAccStdrd]()"
    cnt = connectDB()
    out_num = Matrix(get_data_from_DMTdatabase(sql_query, cnt))
    return out_num
end
