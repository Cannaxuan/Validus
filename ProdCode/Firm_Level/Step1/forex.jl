function forex(PathStruct, smeEcon, DataMonth)
    # fxratesAll = matread(PathStruct["FxPath"]*"fxRate.mat")["fxRate"]
    ## change fxRate.mat to fxRateEcon.mat to match the econ's fx
    fxRateEcon = matread(PathStruct["FxPath"]*"fxRateEcon.mat")["fxRateEcon"]
    for iEcon = smeEcon
        irow = fxRateEcon["ID"][iEcon, 3]
        fxrate = fxRateEcon["Data"][irow, 1]
        # fxrate = fxratesAll["Data"][iEcon]
        fxrate = fxrate[fxrate[:, 2] .!= NaN, :]
        fxrate[:, 1] = fld.(fxrate[:, 1], 100)
        idxmthendf = vcat(findall(diff(fxrate[:, 1]) .!= 0), size(fxrate, 1))
        fxrate = DataFrame(fxrate[idxmthendf, :])
        names!(fxrate, [:monthDate, :fxrate])
        save(PathStruct["Firm_DTD_Regression_FxRate"]*"fxrate_"*string(iEcon)*".jld", "fxrate", fxrate, compress = true)
    end
end
