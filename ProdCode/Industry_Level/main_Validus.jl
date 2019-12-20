
function main_Validus(dataEndDate, PathStruct, smeEcon = [1 3 9 10])
    # dataEndDate = DataDate

     ## ------------------------------------------------------------------------
     ## Step0: Preparation1:  Define the nargins
     ## ------------------------------------------------------------------------
     ## Preparation: Pre-defination of constants
     options = Dict()
     options["nSize"] = [[0 2]; [2 10]; [10 100]] ## bountries of micro, small, medium size industries
     options["industryCodes"] = [10008 10002 10003 10004 10005 10006 10007 10011 10013 10014]
     options["qtIndustryFac"] = 0.5    ## The quantile to generate the industry PD factors
     options["facThresMths"] = 60   ## The firms with PD less than or equal to [thresMths] months will be removed
     options["regMethod"] = "lasso"
     options["thresMethod"] = "lasso"
     options["smeHorizon"] = 60    ## The horizon for generating portfolio's PDs[should be <= 60]
     options["startMth"] = 199601
     options["startDate"] = 19960101
     loadFacs = true     ## Whether to load the existing global and industry factors
     loadSMEInfo = true  ## whether to load the existing portfolio's data set
     dataEndMth = fld(dataEndDate, 100)

     ## Generate the global, regional and other common factors
     println('\n' * "======================= Default Correlation Modelling =======================")
     print( "Data set is up to $dataEndMth")

     globalEconCodes = findall(.!isnan.(PathStruct["GROUPS"]))
     ## The order of industries affects the generation of the industry PD and POE
     ## factors. We set the financial sector to be the first.
     #### ----------------------------------------------------------------------
     #### Step1: Load/Generate factors
     #### ----------------------------------------------------------------------
     print("Generate the factors of (transformed) PDs up to $dataEndMth ...")
     if loadFacs && isfile(PathStruct["Industry_Factor"]*"fac.jld")
         facs = load(PathStruct["Industry_Factor"]*"fac.jld")["facs"]
         dateVctr = facs["dateVctr"]
         industryFacsPD = facs["industryFacsPD"]
     else
         facs = generate_factors(globalEconCodes, dataEndMth, options, PathStruct)
         save(PathStruct["Industry_Factor"]*"fac.jld", "facs", facs)
     end
     #### ----------------------------------------------------------------------
     #### Step2: Load/Generate SME portfolio information
     #### ----------------------------------------------------------------------
     println("Generate the SME's information up to $dataEndMth ...")
     if loadSMEInfo && isfile(PathStruct["SMEinfoFolder"]*"smeInfo.jld")
         SmeInfo = load(PathStruct["SMEinfoFolder"]*"smeInfo.jld")
         smeInfo = SmeInfo["smeInfo"]
         smeEcon = SmeInfo["smeEcon"]
     else
         ctyInfo, smeInfo =
            # generate_SME_info(smeEcon, options["startDate"], dataEndDate, facs["dateVctr"], options, PathStruct, parts)
            generate_SME_info(smeEcon, PathStruct["DATE_START_DATA"], dataEndDate, facs["dateVctr"], options, PathStruct)
         save(PathStruct["SMEinfoFolder"]*"smeInfo.jld", "smeInfo", smeInfo, "smeEcon", smeEcon, compress = true)
         save(PathStruct["SMEinfoFolder"]*"ctyInfo.jld", "ctyInfo", ctyInfo, "smeEcon", smeEcon, compress = true)
     end
     #### ----------------------------------------------------------------------
     #### Step3: Load/Establish the factor model specific to the porfolio(according to size, industry)
     #### ----------------------------------------------------------------------
     println("Establish the factor model specific to the SME porfolio ... ")
     println( "Julia cannot read large mat file, need to resave it by adding '-v7.3' through matlab!!!")
     if isfile(PathStruct["Industry_FactorModel"]*"smeModel.jld")
         smeModelResult_indSize = load(PathStruct["Industry_FactorModel"]*"smeModel.jld")["smeModelResult_indSize"]
     else
         ## 1) Regress each industry/size PDs on industry factors
         println("* Regress SME's average PDs on the global industry PD factors ...")
         smeModelResult_indSize = regress_portfolio_factors(smeInfo, facs["industryFacsPD"], PathStruct["Industry_FactorModel"], options,"indSize")
         save(PathStruct["Industry_FactorModel"]*"smeModel.jld", "smeModelResult_indSize", smeModelResult_indSize, compress = true)
     end
     #### ----------------------------------------------------------------------
     #### Step4: Generate combined PD and quantile data
     #### ----------------------------------------------------------------------
     calculate_quantile_industry(dataEndDate, PathStruct, smeEcon)
     #### ----------------------------------------------------------------------
     #### Step5: Save data
     #### ----------------------------------------------------------------------
     saveDataInExcel(PathStruct, smeModelResult_indSize, smeInfo, options)

end
