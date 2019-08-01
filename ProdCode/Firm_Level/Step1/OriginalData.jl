function OriginalData(PathStruct, enddate, smeEcon, nyear, DataMonth)
    #=  Financial Statement Retrievement
        This function retrieve data from FS_mat_flat.
        Output: "tempdata.jld" for each economy in table format
    	Column info of tempdata: 'CompNo','monthDate','rfr','stkrtn','dtd_MLE','NI2TA','TA','TL','Cash'
    =#
    dataStart = fld(enddate, 100) - nyear * 100
    for iEcon = smeEcon
        FS_mat_flat = matread(PathStruct["OriginalPath"]*"OriginalData_"*string(iEcon)*".mat")["originalData"]
        FS_mat_flat[:, 4:14] = FS_mat_flat[:,3:13]
        FS_mat_flat = FS_mat_flat[FS_mat_flat[:, 2] .> dataStart, :]

        idx = .!isnan.(FS_mat_flat[:, 11])
        Cash = fill(NaN, size(FS_mat_flat, 1), 1)
        Cash[idx] = nanSum(FS_mat_flat[idx, 11:12], 2)

        FS_mat_flat = hcat(FS_mat_flat[:, vcat(1, 2, collect(5:10))], Cash)
        # remove rows have NaN in 'NI2TA','TA','TL','Cash'
        FS_mat_flat = FS_mat_flat[dropdims(sum(.!isfinite.(FS_mat_flat[:, 6:9]), dims = 2) .== 0, dims = 2), :]

        FS_Original = DataFrame(FS_mat_flat)
        names!(FS_Original, [:CompNo, :monthDate, :rfr, :stkrtn, :dtd_MLE, :NI2TA, :TA, :TL, :Cash])
        FS_mat_flat = nothing

        save(PathStruct["Firm_DTD_Regression_FS"]*"FS_Original_"*string(iEcon)*".jld", "FS_Original", FS_Original, compress = true)
    end
end
