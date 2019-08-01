function LogRatioPart(IncreTable, medianVtr)
# :CompNo, :monthDate, :econID, :LogTA2median, :LogTA2TL
    IncreTable = IncreTable[:, [:CompNo, :monthDate, :econID, :TA, :TL]]
    medianVtr = medianVtr[:, [:monthDate, :econID, :medianTA]]
    LogRatioM = join(IncreTable, medianVtr, on = [:monthDate, :econID], kind = :left)

    LogRatioM.LogTA2median = LogRatioM.TA./LogRatioM.medianTA
    LogRatioM.LogTA2TL = LogRatioM.TA./LogRatioM.TL
    deletecols!(LogRatioM, [:TA, :TL, :medianTA])

    LogRatioM.LogTA2median[LogRatioM.LogTA2median .< eps(Float64), :] .= eps(Float64)
    LogRatioM.LogTA2TL[LogRatioM.LogTA2TL .< eps(Float64), :] .= eps(Float64)

    LogRatioM.LogTA2median = log.(LogRatioM.LogTA2median)
    LogRatioM.LogTA2TL = log.(LogRatioM.LogTA2TL)

    return LogRatioM
end
