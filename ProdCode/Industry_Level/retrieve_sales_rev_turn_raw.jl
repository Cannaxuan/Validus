function retrieve_sales_rev_turn_raw(iEcon, dateStart, dateEnd, turnOverFolder, CleanDataFolder)
     global GC
     try
         CompanyInformation = matread(turnOverFolder*"CompanyInformation_"*string(iEcon)*".mat")
     catch
         Companyinformation = matread(CleanDataFolder*"EconomicInformation\\CompanyInformation\\CompanyInformation_"*string(iEcon)*".mat")
     end
     companyInformation = Companyinformation["companyInformation"]
     CompanyInformation = Companyinformation["CompanyInformation"]
     try
         fxRate = matread(turnOverFolder*"fxRate.mat")
     catch
         fxRate = matread(CleanDataFolder*"GlobalInformation\\fxRate.mat")
     end
     ## collect financialStatementRaw
     ## Below is for matlab:
     ## (need to split because there was a strange error that happens sometimes
     ##  when trying to retrieve large amount of FS_ID)







     return sales_rev_turn_raw, Sales_Rev_Turn_Raw
end
