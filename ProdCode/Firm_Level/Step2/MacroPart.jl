function MacroPart(IncreTable, RatioM, LogRatioM, medianVtr; econ = [1 3 9 10])
#=
 Output:
    finalX:   :NI2TA, :Sales2TA, :TL2TA, :Cash2TA, :Cash2CL, :CL2TL, :LTB2TL,
              :BE2TL, :BE2CL, :LogTA2median, :LogTA2TL, :rfr, :fxrate, :stkrtn, :medianDTD, :medianOverSigma
    finalXres::NI2TA, :Cash2TA, :CL2TL, :BE2CL, :LogTA2TL, :medianDTD, :medianOverSigma
    monthmedian::monthDate, :econID, :Count, :DTD, :M2B, :Sigma, :OverSigma, :medianTA, :medianBE
    DTD:
    FirmIndex: :CompNo, :monthDate, :econID
    lb, ub: lower and upper bound of each column
    industry:
=#
    finalX = join(RatioM, LogRatioM, on = [:CompNo, :monthDate, :econID], kind = :left)
    finalX = join(finalX, IncreTable[:, [:CompNo, :monthDate, :rfr, :fxrate, :stkrtn, :DTD, :Sigma, :M2B, :industryID]],
                  on = [:CompNo, :monthDate], kind = :left)
    # centralized rfr and fxrate
    for iEcon = econ
        # global finalX
        idx = finalX.econID .== iEcon
        rfrmean = nanMean(finalX.rfr[idx, :])
        finalX.rfr[idx, :] = (finalX.rfr[idx, :] .- rfrmean) ./ rfrmean
        fxmean = nanMean(finalX.fxrate[idx, :])
        finalX.fxrate[idx, :] = (finalX.fxrate[idx, :] .- fxmean) ./ fxmean
    end
    # winsorizartion
    # for further change the regressor!!!!
    winprop = [:NI2TA, :Cash2TA, :CL2TL, :BE2CL, :LogTA2TL]
    lb = DataFrame()
    ub = DataFrame()
    for col = names(finalX)
        # global lb, ub
        if col in winprop
        ## prctile/quantile function in matlab is different from that in julia.
        ## Therefore, the results are different from the thousandth, leading to different numbers of NaN.
            ## In Julia, Quantiles are computed via linear interpolation between the points ((k-1)/(n-1), v[k]),
            ## for k = 1:n where n = length(itr).
            l = quantile(finalX[.!isnan.(finalX[:, col]), col], 0.01)
            u = quantile(finalX[.!isnan.(finalX[:, col]), col], 0.99)
            lb[col] = l
            ub[col] = u
            finalX[col][finalX[col] .< l] .= NaN
            finalX[col][finalX[col] .> u] .= NaN
        end
    end

    finaltemp = Matrix(finalX[[winprop; :DTD]])
    nanidx = any(isnan.(finaltemp), dims = 2)
    finalX = finalX[.!nanidx[:], :]

    ## calculation of month median
    monthlist = unique(finalX.monthDate)
    propertylist = [:DTD, :M2B, :Sigma]
    monthmedian = DataFrame(fill(NaN, 4*length(monthlist), length(propertylist) + 3))
    names!(monthmedian,  vcat(:monthDate, :econID, :Count, propertylist))

    for iMonth = 1:length(monthlist)
        for iEcon = 1:length(econ)
            idxecon = finalX.econID .== econ[iEcon]
            idxmonth = finalX.monthDate .== monthlist[iMonth]
            monthmedian[4*(iMonth-1)+iEcon, :monthDate] = monthlist[iMonth]
            monthmedian[4*(iMonth-1)+iEcon, :econID] = econ[iEcon]
            for i = names(monthmedian)
                if i in propertylist
                    monthmedian[4*(iMonth-1)+iEcon, i] = nanMedian(finalX[idxecon .& idxmonth, i])
                elseif i == :Count
                    monthmedian[4*(iMonth-1)+iEcon, i] = count(idxecon .& idxmonth)
                end
            end
        end
    end
    monthmedian.OverSigma = 1 ./ monthmedian.Sigma
    monthmedian = join(monthmedian, medianVtr, on = [:monthDate, :econID], kind = :left)
    missing2NaN!(monthmedian)

    ## subset DTD
    finalX.outputDTD = finalX.DTD
    ## remove DTD, Sigma and M2B, add median DTD and median 1/Sigma
    deletecols!(finalX, [:DTD, :Sigma, :M2B])
    finalX = join(finalX, monthmedian[:, [:monthDate, :econID, :DTD, :OverSigma]], on = [:monthDate, :econID], kind = :left)
    finalX.medianDTD = finalX.DTD
    finalX.medianOverSigma = finalX.OverSigma
    missing2NaN!(finalX)

    # error "invalid redefinition of constant DTD", therefore, change variable name from DTD to DTDres
    DTDres = finalX.outputDTD

    deletecols!(finalX, [:outputDTD, :DTD, :OverSigma])
    ## subset Industry and FirmIndex
    industry = finalX.industryID
    deletecols!(finalX, :industryID)
    FirmIndex = finalX[:, [:CompNo, :monthDate, :econID]]
    deletecols!(finalX, [:CompNo, :monthDate, :econID])

    ## subset finalX
    finalXres = finalX[:, [:NI2TA, :Cash2TA, :CL2TL, :BE2CL, :LogTA2TL, :medianDTD, :medianOverSigma]]

    return DTDres, finalX, monthmedian, FirmIndex, lb, ub, industry, finalXres
end
