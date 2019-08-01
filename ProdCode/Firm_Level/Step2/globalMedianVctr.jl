function globalMedianVctr(PathStruct, DataMonth; econ = [1 3 9 10])
    FS_Raw_Combined = load(PathStruct["Firm_DTD_Regression_FS"]*"FS_Raw_Combined.jld")["FS_Raw_Combined"]

    monthall = unique(FS_Raw_Combined.monthDate)
    medianVtr = DataFrame(fill(NaN, 4*length(monthall), 4))
    names!(medianVtr, [:monthDate, :econID, :medianTA, :medianBE])

    for iMonth = 1: length(monthall)
        for iEcon = 1 : size(econ, 2)
            temp = DataFrame()
            temp.monthDate = monthall[iMonth]
            temp.econID = econ[iEcon]
            idx = (FS_Raw_Combined.monthDate .== temp.monthDate) .& (FS_Raw_Combined.econID .== temp.econID)
            temp.medianTA = nanMedian(FS_Raw_Combined.TA[idx,:])
            temp.medianBE = nanMedian(FS_Raw_Combined.TA[idx,:] .- FS_Raw_Combined.TL[idx,:])
            medianVtr[4 * (iMonth - 1) + iEcon, :] = temp
        end
    end
    return medianVtr
end
