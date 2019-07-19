function retrieve_sales_rev_turn_raw(iEcon, dateStart, dateEnd, turnOverFolder, CleanDataFolder)
    # dateEnd = dataEndDate
     global GConst
     temp =
     try
         Companyinformation = matread(turnOverFolder*"CompanyInformation_"*string(iEcon)*".mat")
         Companyinformation
     catch
         Companyinformation = matread(CleanDataFolder*"EconomicInformation\\CompanyInformation\\CompanyInformation_"*string(iEcon)*".mat")
         matwrite(turnOverFolder*"CompanyInformation_"*string(iEcon)*".mat", Companyinformation)
         ## julia to save mat file would be quite larger than matlab, later consider to use copy file
         Companyinformation
     end
     Companyinformation = temp
     companyInformation = Companyinformation["companyInformation"]
     CompanyInformation = Companyinformation["CompanyInformation"]
     temp =
     try
         fxRate = matread(turnOverFolder*"fxRate.mat")["fxRate"]
         # fxRate = fxrate["Data"]
         fxRate
     catch
         fxRate = matread(CleanDataFolder*"GlobalInformation\\fxRate.mat")["fxRate"]
         # fxRate = fxrate["Data"]
         matwrite(turnOverFolder*"fxRate.mat", fxrate)
         ## julia to save mat file would be quite larger than matlab, later consider to use copy file
         fxRate
     end
     fxRate = temp
     ## collect financialStatementRaw
     ## For both matlab and Julia:
     ##     need to split because there was a strange error that happens sometimes when trying to retrieve large amount of FS_ID
     companyList = split_data(Int64.(companyInformation[:, Int64(CompanyInformation["BBG_ID"])]), 10)
     financialStatement = Vector{Array{Float64, 2}}(undef, size(companyList, 1))
     FinancialStatement = Dict()
     # @distributed
     for i = 1:size(companyList, 1)
         # println("generate FS for $i, $(size(companyList, 1)-i) left.")
         global financialStatement, FinancialStatement2
         financialStatement[i], FinancialStatement2 =  retrieve_financial_statement_raw(companyList[i], dateStart, dateEnd, 127)
         if !isempty(FinancialStatement2)
            FinancialStatement = FinancialStatement2
         end
     end
     financialStatement = vcat(financialStatement...)
     # findall(ismissing.(financialStatement))
     financialStatement = filter_financial_statement(financialStatement, FinancialStatement, dateEnd)

     ##  Convert the currency ID to FX ID.
     currency = unique(financialStatement[:, FinancialStatement["Currency"]])
     currency = currency[.!isnan.(currency)]
     fxID = convert_currencyID_to_FXID(currency, GConst["REGION_OF_ECON"][iEcon])
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
                                                                       FinancialStatement["Time_Available_CRI"]]], GConst["PERIOD_END"])
     ## Convert BBGID to U3 company number
     BBGID = financialStatement[:, FinancialStatement["BBG_ID"]]
     Lia = in.(BBGID, [companyInformation[:, Int64(CompanyInformation["BBG_ID"])]])
     Lib = indexin(BBGID, companyInformation[:, Int64(CompanyInformation["BBG_ID"])])
     missingComps = findall(.!Lia)
     if !isempty(missingComps)
         # for i = 1:length(missingComps)
         #     println("We have missing information for company with BBG_ID: $(BBGID[LinearIndices(Lia)[missingComps[i]]])")
         # end
         financialStatement = financialStatement[.!in.(1:size(financialStatement,1), [missingComps]),:]
         Lib = Lib[.!in.(1:size(Lib,1), [missingComps]),:]
     end
     u3CompanyID = companyInformation[Lib, Int64.(CompanyInformation["Company_Number"])]

     ##  Extract final output
     sales_rev_turn_raw = hcat(u3CompanyID, financialStatement[:, FinancialStatement["BBG_ID"]], firstTimeUse, salesRevTurnInUSD[:, 2],
                            financialStatement[:, [FinancialStatement["Fiscal_Period"], FinancialStatement["Is_Consolidated"],
                            FinancialStatement["Filing_Status"], FinancialStatement["Period_End"]]])
     Sales_Rev_Turn_Raw = Dict("U3_COMP_ID" => 1, "BBG_ID" => 2, "FIRST_TIME_CAN_USE_FS" => 3, "SALES_REV_TURN" => 4,
                               "FISCAL_PERIOD" => 5, "IS_CONSOLIDATED" => 6, "FILING_STATUS" => 7, "PERIOD_END" => 8)

     return sales_rev_turn_raw, Sales_Rev_Turn_Raw
end
