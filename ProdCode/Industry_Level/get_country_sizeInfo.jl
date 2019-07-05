function get_country_sizeInfo(iEcon, dateStart, dataEndDate, folders, options)
# iEcon, dateStart, dataEndDate, folders, options = iSmeEconCode, dateStart, dataEndDate, folders, options
     turnOverFolder = folders["SMEinfoFolder"]
     CleanDataFolder = folders["dataSource"]*"\\IDMTData\\CleanData\\"
     temp =
     try
         println(" # Load retrieved raw salesRevTurn data for Economy $iEcon ! ...")
         Sales_rev_turn_raw = load(turnOverFolder*"sales_rev_turn_raw_"*string(iEcon)*".jld")
         sales_rev_turn_raw = Sales_rev_turn_raw["sales_rev_turn_raw"]
         Sales_Rev_Turn_Raw = Sales_rev_turn_raw["Sales_Rev_Turn_Raw"]
         sales_rev_turn_raw, Sales_Rev_Turn_Raw
     catch
         println(" # No retrieved raw salesRevTurn data for Economy $iEcon ! Retrieving the new data ...")
         sales_rev_turn_raw, Sales_Rev_Turn_Raw =
            retrieve_sales_rev_turn_raw(iEcon, dateStart, dataEndDate, turnOverFolder, CleanDataFolder)
         ## save jld file
         save(turnOverFolder*"sales_rev_turn_raw_"*string(iEcon)*".jld", "sales_rev_turn_raw", sales_rev_turn_raw,
         "Sales_Rev_Turn_Raw", Sales_Rev_Turn_Raw, compress = true)
         ## save mat file
         # Sales_rev_turn_raw = Dict()
         # Sales_rev_turn_raw["sales_rev_turn_raw"] = sales_rev_turn_raw
         # Sales_rev_turn_raw["Sales_Rev_Turn_Raw"] = Sales_Rev_Turn_Raw
         # matwrite(turnOverFolder*"sales_rev_turn_raw_"*string(iEcon)*".mat", Sales_rev_turn_raw)
         sales_rev_turn_raw, Sales_Rev_Turn_Raw
     end
     sales_rev_turn_raw, Sales_Rev_Turn_Raw = temp

     println("- Prioiritize and clean salvs_rev_turn data for Economy $iEcon ...")
     sales_rev_turn_clean = clean_sales_rev_turn(sales_rev_turn_raw)

     println("- Construct Month End salvs_rev_turn data for Economy $iEcon ...")
     salesRevTurnMth = construct_mth_data(sales_rev_turn_clean, iEcon, dataEndDate, options, folders)
     # save jld file with compression
     save(turnOverFolder*"salesRevTurnMth_"*string(iEcon)*".jld", "salesRevTurnMth", salesRevTurnMth, compress = true)
     # save mat file
     # salesRevTurnMth = Dict("salesRevTurnMth" => salesRevTurnMth)
     # matwrite(turnOverFolder*"salesRevTurnMth_"*string(iEcon)*".mat", salesRevTurnMth)

     return salesRevTurnMth
end
