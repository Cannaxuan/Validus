function convert_currency_financial_statement(fsData, fsCurrency, exchangeCurrency, fxRate, FsData = Dict("Period_End" => 1))
    # fsData, fsCurrency, exchangeCurrency, fxRate = salesRevTurnInUSD, financialStatement[:, FinancialStatement["Currency"]], USD_FX_ID, fxRate
    #=
     This function converts the currency of data from financial statement variable by variables.
     fsCurrency is a matrix of the same size as the data columns in fsData and
     indicates the currency index of each data in the data column.
     exchangeCurrency is the currency index of this exchange which is recorded in company information matrix.
    =#

    ## USD_FX_ID = 1094
    if FsData["Period_End"] == 1
        nHeadCol = 1
    else
        nHeadCol = FsData["Time_Use_Last"]
    end
    currencyToBeConverted = fsCurrency[in.(fsCurrency, [fxRate["ID"][fxRate["ID"] .!= exchangeCurrency]])]
    currencyToBeConverted = unique(currencyToBeConverted)
    currencyToBeConverted = currencyToBeConverted[isfinite.(currencyToBeConverted)]
    fxThisExchange = fxRate["Data"][fxRate["ID"] .== exchangeCurrency][1]


    if !isempty(currencyToBeConverted)
        for i = 1:length(currencyToBeConverted)
            idxRate = fxRate["ID"] .== currencyToBeConverted[i]
            ind = findall(fsCurrency[:, :] .== currencyToBeConverted[i])
            idxValueInThisCurrency = LinearIndices(fsData)[ind] .+ nHeadCol .* size(fsData, 1)
            dateThisCurrency = fsData[LinearIndices(fsData)[ind], FsData["Period_End"]]
            fxThisCurrencyThisDate = get_specific_day_value(fxRate["Data"][idxRate][1], dateThisCurrency)[1]
            fxThisExchangeThisDate = get_specific_day_value(fxThisExchange, dateThisCurrency)[1]
            fsData[idxValueInThisCurrency] =
            fsData[idxValueInThisCurrency] .* fxThisExchangeThisDate[:, 2]./ fxThisCurrencyThisDate[:, 2]
        end
    end
    return fsData
end
