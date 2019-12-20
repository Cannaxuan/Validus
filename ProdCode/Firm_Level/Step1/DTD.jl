function DTD(PathStruct, smeEcon, DataMonth)
    DTDlist = DataFrame()
    for iEcon = smeEcon
        ## firmspecific =
        ## matread(PathStruct["firmspecific_justBeforeMissingHandling"]*"firmSpecific_final_"*string(iEcon)*".mat")["firmSpecific_final"]
        firmspecific =
        read_jld(PathStruct["firmspecific_justBeforeMissingHandling"]*"firmSpecific_final_"*string(iEcon)*".jld")["firmSpecific_final"]
        # firmspecific index meaning:
        # 1: company code 2: year 3: month 6: DTD(level) 7: DTD trend 15: Sigma 14: M/B
        DTD_Source = firmspecific[:, [1, 2, 3, 6, 7, 15, 14], :]
        firmspecific = nothing
        A, B, C = size(DTD_Source)
        DTD_Source = permutedims(DTD_Source, [1, 3, 2])
        DTD_Source = reshape(DTD_Source, A*C, B)
        DTD_Source = DataFrame(DTD_Source)
        names!(DTD_Source, [:CompNo, :Year, :Month, :DTDlevel, :DTDtrend, :Sigma, :M2B])
        save(PathStruct["Firm_DTD_Regression_CriRiskFactor"]*"DTD_Source_"*string(iEcon)*".jld", "DTD_Source", DTD_Source, compress = true)
        append!(DTDlist, DTD_Source)
    end
    ## DTD current value = level + trend
    DTDlist.DTD = DTDlist.DTDlevel + DTDlist.DTDtrend
    deletecols!(DTDlist, [:DTDlevel, :DTDtrend])
    DTD_Source_Combined = DTDlist[DTDlist.DTD .!== NaN, :]
    DTDlist = nothing
    save(PathStruct["Firm_DTD_Regression_CriRiskFactor"]*"DTD_Source_Combined.jld", "DTD_Source_Combined", DTD_Source_Combined, compress = true)

end
