function handlepdall(allcat, pdAllForward, firmInfo, dateVctr, indicator)
    # allcat, pdAllForward, firmInfo, dateVctr, indicator = MeFirms, pdAllForwardtemp, firmInfo, dateVctr, 1
    complist = unique(allcat.CompNo)

    for i = complist
        compseg = allcat[allcat.CompNo .== i, :]
        idx1 = in.(compseg.monthDate, [dateVctr])
        idx2 = indexin(compseg.monthDate, dateVctr)
        idx = Int.(idx2[idx1])
        idxcomp = fld.(firmInfo[:, 1], 1000) .== i
        pdAllForward[idx, 2, idxcomp] .= indicator
    end

    return pdAllForward
end
