function forex(PathStruct, smeEcon, DataMonth)
    # fxratesAll = matread(PathStruct["FxPath"]*"fxRate.mat")["fxRate"]
    ## change fxRate.mat to fxRateEcon.mat to match the econ's fx, which is after DMT's comfirmation
    fxRateEcon = matread(PathStruct["FxPath"]*"fxRateEcon.mat")["fxRateEcon"]
    for iEcon = smeEcon
        irow = Int(fxRateEcon["ID"][iEcon, 3])
        fxrate = fxRateEcon["Data"][irow, 1]
        # fxrate = fxratesAll["Data"][iEcon]
        fxrate = fxrate[fxrate[:, 2] .!= NaN, :]    ## delete the NaN rows
        fxrate[:, 1] = fld.(fxrate[:, 1], 100)
        idxmthendf = vcat(findall(diff(fxrate[:, 1]) .!= 0), size(fxrate, 1))
        fxrate = DataFrame(fxrate[idxmthendf, :])
        names!(fxrate, [:monthDate, :fxrate])

        fxrate_raw = deepcopy(fxrate)
        mu = mean(fxrate_raw.fxrate)
        sigma = std(fxrate_raw.fxrate)
        fxrate.fxrate = (fxrate_raw.fxrate .- mu) ./ sigma

        save(PathStruct["Firm_DTD_Regression_FxRate"]*"fxrate_"*string(iEcon)*".jld", "fxrate", fxrate, compress = true)
        save(PathStruct["Firm_DTD_Regression_FxRate"]*"fxrate_Raw_"*string(iEcon)*".jld", "fxrate_raw", fxrate_raw, "mu", mu, "sigma", sigma, compress = true)
        CSV.write(PathStruct["Firm_DTD_Regression_FxRate"]*"fxrate_Raw_"*string(iEcon)*".csv",fxrate_raw)
    end
end
