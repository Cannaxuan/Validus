function retrieve_sales_rev_turn_raw(iEcon, dateStart, dateEnd, turnOverFolder, CleanDataFolder)
    # dateEnd = dataEndDate
     global GC
     temp =
     try
         Companyinformation = matread(turnOverFolder*"CompanyInformation_"*string(iEcon)*".mat")
         Companyinformation
     catch
         Companyinformation = matread(CleanDataFolder*"EconomicInformation\\CompanyInformation\\CompanyInformation_"*string(iEcon)*".mat")
         Companyinformation
     end
     Companyinformation = temp
     companyInformation = Companyinformation["companyInformation"]
     CompanyInformation = Companyinformation["CompanyInformation"]
     temp =
     try
         fxRate = matread(turnOverFolder*"fxRate.mat")["fxRate"]
         fxRate
     catch
         fxRate = matread(CleanDataFolder*"GlobalInformation\\fxRate.mat")["fxRate"]
         fxRate
     end
     fxRate = temp
     ## collect financialStatementRaw
     ## For both matlab and Julia:
     ##     need to split because there was a strange error that happens sometimes when trying to retrieve large amount of FS_ID
     companyList = split_data(Int64.(companyInformation[:, Int64(CompanyInformation["BBG_ID"])]), 10)
     financialStatement =  Vector{Array{Union{Missing, Float64}, 2}}(undef, size(companyList, 1))
     for i = 1:size(companyList, 1)
         println(i)
         financialStatement[i], FinancialStatement2 =  retrieve_financial_statement_raw(companyList[i], dateStart, dateEnd, 127)
         if ~isempty(FinancialStatement2)
             FinancialStatement = FinancialStatement2
         end
     end

     financialStatement = vcat(financialStatement...)
     # findall(ismissing.(financialStatement))
     financialStatement = filter_financial_statement(financialStatement, FinancialStatement, dateEnd)

     ##  Convert the currency ID to FX ID.
     currency = unique(financialStatement[:, FinancialStatement["Currency"]])
     currency = currency[.!isnan.(currency)]
     fxID = convert_currencyID_to_FXID(currency, GC["REGION_OF_ECON"][iEcon])
     isIn = in.(financialStatement[:,FinancialStatement["Currency"]], [fxID[:,1]])
     idx = indexin(financialStatement[:,FinancialStatement["Currency"]], fxID[:,1])
     financialStatement[isIn, FinancialStatement["Currency"]] = fxID[idx[idx .!= nothing], 2]
     financialStatement =  financialStatement[isIn, :]

     ## Convert currency to USD
     conversionDate = financialStatement[:, FinancialStatement["Period_End"]]
     dataToBeConverted = financialStatement[:, FinancialStatement["SALES_REV_TURN"]]
     USD_FX_ID = 1094
     salesRevTurnInUSD = hcat(conversionDate, dataToBeConverted)
     salesRevTurnInUSD = convert_currency_financial_statement(salesRevTurnInUSD,
                         financialStatement[:, FinancialStatement["Currency"]], USD_FX_ID, fxRate)

    ## Get 1st time use
    ## Revised  @20160919, add one more input for this function
    firstTimeUse = get_individual_first_use_time(financialStatement[:,[FinancialStatement["Period_End"], FinancialStatement["Time_Release"],
                                                                       FinancialStatement["Time_Available_CRI"]]], GC["PERIOD_END"])






     return sales_rev_turn_raw, Sales_Rev_Turn_Raw
     a=[1 2 3 4; 2 3 4 5; 3 4 5 6]
     a[:,[1, 2, 3]]
end
