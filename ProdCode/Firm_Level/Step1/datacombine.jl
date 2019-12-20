function datacombine(PathStruct, smeEcon, DataMonth)
#=
 This function is used for loading data from earlier steps.
 Load :SMElist.jld,'fxrate.jld,'FS_Raw.jld,'FS_Original.jld' in economy 1, 3, 9, 10
 Output: S/M/E DTDInput.jld
    :CompNo, :monthDate, :industryID, :econID, :Sales, :CL, :LTB, :TL, :TA,
    :rfr, :stkrtn, :NI2TA, :Cash, :fxrate, :tmr, :Sales2TA, :CA, :NI, :BE

    'tmr', 'CA', 'NI' are all NaN for current stage

=#

	Fx_Combined = DataFrame()
	FS_Raw_Combined = DataFrame()
	FS_Original_Combined = DataFrame()

    for iEcon = smeEcon
        # global Fx_Combined, FS_Raw_Combined, FS_Original_Combined
        fxrate = load(PathStruct["Firm_DTD_Regression_FxRate"]*"fxrate_"*string(iEcon)*".jld")["fxrate"]
        FS_Raw = load(PathStruct["Firm_DTD_Regression_FS"]*"FS_Raw_"*string(iEcon)*".jld")["FS_Raw"]
        FS_Original = load(PathStruct["Firm_DTD_Regression_FS"]*"FS_Original_"*string(iEcon)*".jld")["FS_Original"]

        fxrate.econID = repeat([iEcon], nrow(fxrate))
        append!(Fx_Combined, fxrate)

        FS_Raw.econID = repeat([iEcon], nrow(FS_Raw))
        append!(FS_Raw_Combined, FS_Raw)

        FS_Original.CompNo = fld.(FS_Original.CompNo, 1000)
        append!(FS_Original_Combined, FS_Original)
    end
    save(PathStruct["Firm_DTD_Regression_FxRate"]*"Fx_Combined.jld", "Fx_Combined", Fx_Combined, compress = true)
    save(PathStruct["Firm_DTD_Regression_FS"]*"FS_Raw_Combined.jld", "FS_Raw_Combined", FS_Raw_Combined, compress = true)
    save(PathStruct["Firm_DTD_Regression_FS"]*"FS_Original_Combined.jld", "FS_Original_Combined", FS_Original_Combined, compress = true)

    SME_SalesData = load(PathStruct["Firm_DTD_Regression_FS"]*"SME_SalesData.jld")
    MeFirms = SME_SalesData["MeFirms"]
    SmFirms = SME_SalesData["SmFirms"]
    MiFirms = SME_SalesData["MiFirms"]
    SME_SalesData = nothing

	MeFirms = datacombine_sub_v1(MeFirms, Fx_Combined, FS_Raw_Combined, FS_Original_Combined)
	SmFirms = datacombine_sub_v1(SmFirms, Fx_Combined, FS_Raw_Combined, FS_Original_Combined)
	MiFirms = datacombine_sub_v1(MiFirms, Fx_Combined, FS_Raw_Combined, FS_Original_Combined)
	## :CompNo, :monthDate, :industryID, :econID, :Sales, :CL, :LTB, :TL, :TA, :rfr, :stkrtn, :NI2TA, :Cash, :fxrate

	Me_DTDInput = prepareCols_v1(MeFirms)
	Sm_DTDInput = prepareCols_v1(SmFirms)
	Mi_DTDInput = prepareCols_v1(MiFirms)
	## :CompNo, :monthDate, :industryID, :econID, :Sales, :CL, :LTB, :TL, :TA,
	## :rfr, :stkrtn, :NI2TA, :Cash, :fxrate, :tmr, :Sales2TA, :CA, :NI, :BE

	## 'tmr', 'CA', 'NI' are all NaN for current stage

	save(PathStruct["Firm_DTD_Regression_FS"]*"Me_DTDInput.jld", "Me_DTDInput", Me_DTDInput, compress = true)
	save(PathStruct["Firm_DTD_Regression_FS"]*"Sm_DTDInput.jld", "Sm_DTDInput", Sm_DTDInput, compress = true)
	save(PathStruct["Firm_DTD_Regression_FS"]*"Mi_DTDInput.jld", "Mi_DTDInput", Mi_DTDInput, compress = true)

end
