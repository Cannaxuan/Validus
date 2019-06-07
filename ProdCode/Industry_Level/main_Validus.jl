using Printf, MAT
function main_Validus(dataEndDate,PathStruct,smeEcon=[1 3 9 10])
     ## ------------------------------------------------------------------------
     ## Step0: Preparation1:  Define the nargins
     ## ------------------------------------------------------------------------
     ## Preparation: Pre-defination of constants
     options = Dict()
     options["nSize"] = [[0 2];[2 10];[10 100]] ## bountries of micro, small, medium size industries
     options["industryCodes"] = [10008 10002 10003 10004 10005 10006 10007 10011 10013 10014]
     options["qtIndustryFac"] = 0.5    ## The quantile to generate the industry PD factors
     options["facThresMths"] = 60   ## The firms with PD less than or equal to [thresMths] months will be removed
####################################
### lasso or deepselect???
     options["regMethod"] = "lasso"
     options["thresMethod"] = "lasso"
####################################
    options["smeHorizon"] = 60    ## The horizon for generating portfolio's PDs[should be <= 60]
     options["startMth"] = 199601
     loadFacs = true     ## Whether to load the existing global and industry factors
     loadSMEInfo = true  ## whether to load the existing portfolio's data set
     dataEndMth = floor(Int, dataEndDate/100)

     ## Generate the global, regional and other common factors
     println('\n' * "======================= Default Correlation Modelling =======================")
     print( "Data set is up to $dataEndMth")

     globalEconCodes = findall(.!isnan.(PathStruct["GROUPS"]))
     ## The order of industries affects the generation of the industry PD and POE
     ## factors. We set the financial sector to be the first.
     #### -------------------------------
     #### Step1: Load/Generate factors ####
     #### -------------------------------
     print("Generate the factors of (transformed) PDs up to $dataEndMth ...")
     if loadFacs && isfile(PathStruct["Industry_Factor"]*"fac.mat")
         facs = matread(PathStruct["Industry_Factor"]*"fac.mat")["facs"]
     else
         facs = generate_factors(globalEconCodes, dataEndMth, options, PathStruct)
         matwrite(PathStruct["Industry_Factor"]*"fac.mat",facs)
     end

end
