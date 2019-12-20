function get_country_param(countryCode, dataMthToLoad, sourceFolder)
## This function is to collect the parameters of common factors and firm-specific attributes for each country

    loadPath = sourceFolder*"\\Products\\M2_Pd\\current_smc\\"

    ## Identify the file to load
    caliFiles = searchdir(loadPath, "C"*string(countryCode)*"_")[1]

    ## Load the calibration parameters
    paraTemp = CSV.read(loadPath*caliFiles; datarow = 3, header = false) #
    ## New Methodology 12/03/2018 (Agg DTDMedian)
    ## convert Dataframe to Array
    paraDef = paraTemp[1:60, 1:17]
    paraDef[:1] = parse.(Float64, paraDef[:1])
    paraDef = convert(Matrix{Float64}, paraDef)
    paraDef = paraDef'

    #paraOther = CSV.read(loadPath*caliFiles, header = false, datarow = 64)
    paraOther = paraTemp[62:121, 1:17]
    paraOther[:1] = parse.(Float64, paraOther[:1])
    paraOther = convert(Matrix{Float64}, paraOther)
    paraOther = paraOther'

    countryFromFile = countryCode
    dateOfFile = parse(Int, split(split(caliFiles, "_")[2], ".")[1])

    return paraDef, paraOther, countryFromFile, dateOfFile
end
