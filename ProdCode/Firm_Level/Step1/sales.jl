function sales(PathStruct, enddate, smeEcon, nyear)
    # PathStruct, enddate, smeEcon, nyear = PathStruct, DataDate, smeEcon, nyear
    DataMonth = fld(enddate, 100)
    monthVctr = load(PathStruct["Industry_Factor"]*"fac.jld")["facs"]["dateVctr"]
    fxRate = matread(PathStruct["SMEinfoFolder"]*"fxRate.mat")
    for iEcon = smeEcon

        salesRevTurnMth = load(PathStruct["SMEinfoFolder"]*"salesRevTurnMth_"*string(iEcon)*".jld")["salesRevTurnMth"]
        # salesRevTurnMth = matread(PathStruct["SMEinfoFolder"]*"salesRevTurnMth_"*string(iEcon)*".mat")["salesRevTurnMth"]

        nrows = nyear * 12

        salesData = cat(salesRevTurnMth, repeat(monthVctr, outer = (1, 1, size(salesRevTurnMth, 3))), dims = 2)
        # salesRevTurnMth = nothing
        salesData = salesData[end-nrows+1:end, :, :]
        salesData = salesData[:, :, .!isnan.(nanMean(salesData[:, 1, :], 1))]
        complist = nanMean(salesData[:, 1, :], 1)
        ucomplist = unique(complist)

        test = salesData[:, 5, :]
        test[test .== 0] .= NaN
        salesData[:, 5, :] = test
        test = nothing

        ## merge the pages have the same company number
        for i = 1:length(ucomplist)
            # global complist, ucomplist, salesData
            idx = complist .== ucomplist[i]
            if sum(idx) > 1
                subidx = findall(idx .!= 0)
                salesData[:, :, subidx[1]] = nanMean(salesData[:, :, idx], 3)
                salesData = cat(salesData[:, :, 1:subidx[1]], salesData[:, :,(subidx[end]+1):end], dims = 3)
                complist = vcat(complist[1:subidx[1]], complist[(subidx[end]+1):end])
            end
        end
        companyInformation = load(PathStruct["SMEinfoFolder"]*"CompanyInformation_"*string(iEcon)*".jld")["Companyinformation"]["companyInformation"]
        ## matread(PathStruct["SMEinfoFolder"]*"CompanyInformation_"*string(iEcon)*".mat")["companyInformation"]
        idxlist = in.(complist, [companyInformation[:, 1]])
        idxInfo = indexin(complist, companyInformation[:, 1])
        complist = hcat(complist, fill(NaN, length(complist), 1))
        complist[idxlist, end] = companyInformation[idxInfo, 7]

        a, b, c = size(salesData)
        SalesData2D = reshape(permutedims(salesData, [1, 3, 2]), (a*c, b))
        salesData = nothing
        idx = .!isnan.(SalesData2D[:, 2]) .& .!isnan.(SalesData2D[:, 5])
        SalesData2D = SalesData2D[idx, :]

        SalesData2D = hcat(SalesData2D, fill(NaN, size(SalesData2D, 1), 2))
        idx1 = in.(SalesData2D[:, 1], [complist[:, 1]])
        idx2 = indexin(SalesData2D[:, 1], complist[:, 1])
        SalesData2D[idx1, end-1] = complist[idx2, 2]

        fxrate = fxRate["Data"][iEcon]

        for i = 1:size(SalesData2D, 1)
            # global SalesData2D
            index = findlast(fxrate[:, 1] .<= SalesData2D[i, 4])
            SalesData2D[i, 2] = SalesData2D[i, 2] .* fxrate[index, 2]
        end
        SalesData2D[:, end] .= iEcon
        SalesData2D = DataFrame(SalesData2D)
        names!(SalesData2D, [:CompNo, :Sales, :avblDate, :settleDate, :Size, :monthDate, :industryID, :econID])

        save(PathStruct["Firm_DTD_Regression_FS"]*"SalesData2D_"*string(iEcon)*".jld", "SalesData2D", SalesData2D, compress = true)
    end

end
