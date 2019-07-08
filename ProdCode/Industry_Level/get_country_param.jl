using CSV
function get_country_param(countryCode, dataMthToLoad,sourceFolder)
## This function is to collect the parameters of common factors and firm-specific attributes for each country

    loadPath = sourceFolder*"\\Products\\M2_Pd\\current_smc\\"

    ## Identify the file to load
    searchdir(path,key) = filter(x->occursin(key,x), readdir(path))
    key = "C"*string(countryCode)*"_"
    caliFiles = searchdir(loadPath,key)[1]

    ## Load the calibration parameters
    paraTemp = CSV.read(loadPath*caliFiles, header = collect(1:18), datarow = 3)

    ## New Methodology 12/03/2018 (Agg DTDMedian)
    ## convert Dataframe to Array
    paraDef = paraTemp[1:60, 1:17]
    paraDef[:1] = parse.(Float64, paraDef[:1])
    paraDef = convert(Array{Float64}, paraDef)
    paraDef = paraDef'

    paraOther = paraTemp[62:121, 1:17]
    paraOther[:1] = parse.(Float64, paraOther[:1])
    paraOther = convert(Array{Float64}, paraOther)
    paraOther = paraOther'

    countryFromFile = countryCode
    dateOfFile = parse(Int, split(split(caliFiles, "_")[2], ".")[1])

    return paraDef, paraOther, countryFromFile, dateOfFile
end
