function DTDinput(PathStruct, enddate, smeEcon, nyear, DataMonth)
    # PathStruct, enddate, smeEcon, nyear, DataMonth = PathStruct, DataDate, smeEcon, nyear, DataMonth
    #=
         DTDinput Retrievement

             This function extract the DTD input for further DTD calculation from the dirac,
         and pick out the latest possible value for each month.
         Here we assume at least there is one available value for each month.

         Output: store in '\..\..\Data\DTDinput\(econ number)\compAll.jld' in table format
            	 Column information could be found via compAll.Properties.VariableNames:
        		 'CompNo','monthDate','MarketCap','CL','LTB','TL','TA','rfr'
    =#
    dataStart = enddate - nyear*10000
    for iEcon = smeEcon
        # DTDinput = matread(PathStruct["DTDinputpath"]*"DTDInput_"*string(iEcon)*".mat")
        # DTDInput = DTDinput["DTDInput"]
        ## Column: 
            ## 1. Company_Number/Mapping_Number  2. Time  3. MarketCap  4. Current Liability
            ## 5. Long-term Borrow  6. Total Liability  7. Total Asset  8. Risk free rate
        compAll = matread(PathStruct["DTDinputpath"]*"DTDInput_"*string(iEcon)*".mat")["dtdInput"]
        compAll = compAll[compAll[:, 2] .> dataStart, :]
        compAll = compAll[compAll[:, 2] .<= enddate, :]
        compAll = compAll[dropdims(sum(.!isfinite.(compAll[:, 3:8]), dims = 2) .<= 0, dims = 2), :]
        compAll = Matrix(sort(DataFrame(compAll), (:x1, :x2)))
        idxComp = findall(diff(fld.(compAll[:, 1], 1000)) .!= 0)
        idxTime = findall(diff(fld.(compAll[:, 2], 100)) .!= 0)
        idxMonthEnd = union(sort(union(idxComp, idxTime)), size(compAll, 1))
        compAll = compAll[idxMonthEnd, :]
        compAll[:, 1] = fld.(compAll[:, 1], 1000)
        compAll[:, 2] = fld.(compAll[:, 2], 100)

        compAll = Matrix(sort(DataFrame(compAll), (:x1, :x2)))
        FS_Raw = DataFrame(compAll)
        compAll = nothing
        names!(FS_Raw, [:CompNo, :monthDate, :MarketCap, :CL, :LTB, :TL, :TA, :rfr])
        save(PathStruct["Firm_DTD_Regression_FS"]*"FS_Raw_"*string(iEcon)*".jld", "FS_Raw", FS_Raw, compress = true)
    end

end
