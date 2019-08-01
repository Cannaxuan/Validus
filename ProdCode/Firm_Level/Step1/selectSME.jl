function selectSME(PathStruct, smeEcon, DataMonth)
    MeFirms = DataFrame()
	SmFirms = DataFrame()
	MiFirms = DataFrame()

    for iEcon = smeEcon
        SalesData2D =
            load(PathStruct["Firm_DTD_Regression_FS"]*"SalesData2D_"*string(iEcon)*".jld")["SalesData2D"]
        append!(MeFirms, SalesData2D[SalesData2D.Size .== 3, :])
        append!(SmFirms, SalesData2D[SalesData2D.Size .== 2, :])
        append!(MiFirms, SalesData2D[SalesData2D.Size .== 1, :])
    end

    save(PathStruct["Firm_DTD_Regression_FS"]*"SME_SalesData.jld", "MeFirms", MeFirms, "SmFirms", SmFirms, "MiFirms", MiFirms, compress = true)
end
