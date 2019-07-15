# using PyCall
function get_data_from_DMTdatabase(query, cnt)
    #cnt = connectDB()
    pd = pyimport("pandas")
    df = pd.read_sql(query, con = cnt)
    #df = df.sort_values(by=["U3_Company_Number"])
    tmpFileName = string(tempdir(), "tmp.csv")
    df.to_csv(tmpFileName, index=false)
    df = CSV.read(tmpFileName)
    #df.U3_Company_Number = Int.(df.U3_Company_Number)
    return df
end
