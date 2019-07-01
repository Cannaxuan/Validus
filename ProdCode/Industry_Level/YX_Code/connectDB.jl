function connectDB(;driver = "SQL Server", server="DIRAC\\DIRAC2012")

    pyodbc = pyimport("pyodbc")
    cnt = pyodbc.connect("DRIVER={$driver}; SERVER=$server; Trusted_Connection=yes")

    return cnt
end
