function get_individual_first_use_time(timePerValue, dateEnd)
    # timePerValue, dateEnd =
    # financialStatement[:,[FinancialStatement["Period_End"], FinancialStatement["Time_Release"],
    #                       FinancialStatement["Time_Available_CRI"]]], GConst["PERIOD_END"]
#=
    This function picks the first time we can use a particular financial data given three kinds of date.
    timePerValue:
    C1: Latest_Period_End (PE);
    C2: Announcement_Date (AD);
    C3: CRI_Available_Date (CRI).

    The logic of determining the first use time is based on the statistical
    analysis on the entire table [TIER3].[ENT].[FUNDAMENTALS] on 2016-04-16.
    The logic here is not perfect but statistically most accurate. To whom
    may concern, you can refer to the excel file 'FS time analysis' which
    contains the detailed statistical result on this analysis. I strongly
    suggest that such analysis be performed regularly as well as try best to
    secure the accuracy of the CRI available date.
=#

    ## Is valid PE, AD and CRI
    idxPE = .!isnan.(timePerValue[:, 1])
    idxAD = .!isnan.(timePerValue[:, 2])
    idxCRI = .!isnan.(timePerValue[:, 3])

    # dateadd = Date.(string.(Int64.(timePerValue[:, 1])), "yyyymmdd") .+ Month(3)
    timeadd = fill(NaN, size(timePerValue, 1), 1)
    timePerValue = hcat(timePerValue[:, 1:3], timeadd)
    dateadd = Date.(string.(Int64.(timePerValue[idxPE, 1])), "yyyymmdd") .+ Month(3)
    comp1 = map(s -> parse(Int, replace(s, "-" => "")), string.(dateadd))
    timeadd[idxPE] = comp1
    comp2 = fill(dateEnd, size(timePerValue, 1), 1)
    timePerValue[:, 4] = minimum(hcat(timeadd, comp2), dims = 2)
    timePerValue[:, 4][isnan.(timePerValue[:, 4])] .= dateEnd


    firstUseTime = fill(NaN, size(timePerValue, 1), 1)

    ##  The status of validity of the three times is denoted by [idxPE, idxAD, idxCRI]
    ##  Case 1: [1, 1, 1].
    #   Use announcement date unless it is 1 year after PE when we use PE+3.
    idx = idxPE .& idxAD .& idxCRI
    idx1 = BitArray{1}(undef, size(timePerValue, 1))

    idx1[idxPE .& idxAD] =
        Dates.value.(Date.(string.(Int64.(timePerValue[(idxPE .& idxAD), 2])), "yyyymmdd")) .-
        Dates.value.(Date.(string.(Int64.(timePerValue[(idxPE .& idxAD), 1])), "yyyymmdd")) .<= 365
    idx1[.!(idxPE .& idxAD)] .= false

    firstUseTime[idx .& idx1] = timePerValue[idx .& idx1, 2]
    firstUseTime[idx .& (.!idx1)] = timePerValue[idx .& (.!idx1), 4]

    ## Case 2: [1, 1, 0].
    ## Use announcement date if announcement date is within one year after PE,
    ## otherwise we use PE+3m, because we think the AD may be inaccurate.
    ## The reason of using PE+3m in this case is that the 0.99 quantile of (AD-PE) is 94 days.
    ## Such information was obtained from CRI database TIER3 on 2016-04-16.
    idx2 = idxPE .& idxAD .& (.!idxCRI)
    firstUseTime[idx2 .& idx1] = timePerValue[idx2 .& idx1, 2]
    firstUseTime[idx2 .& (.!idx1)] = timePerValue[idx2 .& (.!idx1), 4]

    ## Case 3: [1, 0, 1].
    ## Use PE+3m.
    idx3 = idxPE .& (.!idxAD) .& idxCRI
    idx4 = timePerValue[:,1] .< timePerValue[:,3] .<= timePerValue[:,4]
    firstUseTime[idx3 .& (.!idx4)] = timePerValue[idx3 .& (.!idx4), 4]
    firstUseTime[idx3 .& idx4] = timePerValue[idx3 .& idx4, 3]

    ## Case 4: [0, 1, 1].
    ## Use AD.
    idx5 = (.!idxPE) .& idxAD .& idxCRI
    firstUseTime[idx5] = timePerValue[idx5, 2]

    ## Case 5: [1, 0, 0]
    ## Use PE+3m.
    idx6 = idxPE .& (.!idxAD) .& (.!idxCRI)
    firstUseTime[idx6] .= timePerValue[idx6, 4]

    ## Case 6 to 8: [0, 1, 0], [0, 0, 1] and [0, 0, 0].
    ## Discard the financial statement.
    return firstUseTime
end
