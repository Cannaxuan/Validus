using CriConsts
function validus_path_define_forAR(dataMonth, groupNum)
    # dataMonth = DataMonth

    ## Define global PathStruct for Industry_Level and Firm_Level
    PathStruct = Dict()
    PathStruct["Official"] = raw"\\dirac\cri3\OfficialTest_AggDTD_SBChinaNA\Production"
    PathStruct["PrePath"] = raw"\\unicorn6\TeamData\DT\lsp\CriAT\PrivateFirmModel\Prod"  ## SME Toolbox Production Code Prefix

    global G_CONST
    # G_CONST = G_CONSTdef(dataMonth)
    G_CONST = GCdef(dataMonth*100)

    Econs = findall(vec(G_CONST["GROUPS"]) .== groupNum)
    PathStruct["GROUPS"] = G_CONST["GROUPS"][:]
    PathStruct["DATE_START_DATA"] =  G_CONST["DATE_START_DATA"]
    PathStruct["ECONSREGION"] = G_CONST["ECONSREGION"]

    strSmeEconCodes = join(Econs, "_")
    PathStruct["Firm_Code"] = PathStruct["PrePath"]*"Code\\Firm_Level\\"   ## For firm Step3

    ##Source data
    PathStruct["dataSource"] = PathStruct["Official"]*"Data\\ModelCalibration\\"*string(dataMonth)
    PathStruct["FxPath"] = PathStruct["dataSource"]*"\\IDMTData\\CleanData\\GlobalInformation\\"
    PathStruct["CompanyInformationFolder"] = PathStruct["dataSource"]*"\\IDMTData\\SmartData\\FirmHistory\\Before_MA\\"
    PathStruct["DTDinputpath"] = PathStruct["dataSource"]*"\\IDMTData\\SmartData\\DTDCalculation\\Input\\Before_MA\\"
    PathStruct["OriginalPath"] = PathStruct["dataSource"]*"\\Processing\\M2_Pd\\OriginalData\\"
    PathStruct["Firm_Specific"] = PathStruct["dataSource"]*"\\Processing\\M2_Pd\\FSTransformed\\"
    PathStruct["FinalData"] = PathStruct["dataSource"]*"\\Processing\\M2_Pd\\FinalDataForCalibration\\"
    PathStruct["firmspecific_justBeforeMissingHandling"] = PathStruct["FinalData"]
    PathStruct["paramPath"] = PathStruct["dataSource"]*"\\Products\\M2_Pd\\"
    PathStruct["loadFolder"] = PathStruct["Official"]*"Data\\FullPeriod\\"*string(dataMonth)*"_withoutRevision\\Monthly\\Products\\P2_Pd\\" ## Full Period Data
    PathStruct["SourcePath"] = PathStruct["PrePath"]*"Data\\Look_Up_Table\\" ## Look Up Table Source Folder
    PathStruct["SME_Titles"] = PathStruct["PrePath"]*"Data\\Firm_Calculation_User_Input\\SME_Titles\\"

    ## Industry Part
    PathStruct["Industry_Data"] = PathStruct["PrePath"]*"Data\\"*string(dataMonth)* "\\Industry\\"
    PathStruct["Industry_Factor"] = PathStruct["Industry_Data"]*"DataPreparation\\Factors\\"
    PathStruct["forwardPDFolder"] = PathStruct["Industry_Data"]*"DataPreparation\\PD_forward\\"
    PathStruct["SMEinfoFolder"] = PathStruct["Industry_Data"]*"DataPreparation\\Econs_"*strSmeEconCodes*"\\"
    PathStruct["Industry_FactorModel"] = PathStruct["Industry_Data"]*"FactorModel\\Econs_"*strSmeEconCodes*"\\"
    PathStruct["Industry_Results"] = PathStruct["Industry_Data"]*"Products\\P106_Validus_Industry\\Econs_"*strSmeEconCodes*"\\"

    ## Firm Part
    PathStruct["Firm_Data"] = PathStruct["PrePath"]*"Data\\"*string(dataMonth)* "\\Firm\\"
    PathStruct["Firm_DTD_Regression_CriRiskFactor"] = PathStruct["Firm_Data"]*"DTD_Regression\\Econs_"*strSmeEconCodes*"\\CriRiskFactor\\"
    PathStruct["Firm_DTD_Regression_FS"] = PathStruct["Firm_Data"]*"DTD_Regression\\Econs_"*strSmeEconCodes*"\\FS\\"
    PathStruct["Firm_DTD_Regression_FxRate"] = PathStruct["Firm_Data"]*"DTD_Regression\\Econs_"*strSmeEconCodes*"\\FxRate\\"
    PathStruct["Firm_DTD_Regression_Parameter"] = PathStruct["Firm_Data"]*"DTD_Regression\\Econs_"*strSmeEconCodes*"\\Parameter\\"
    PathStruct["FullPeriodPD"] = PathStruct["Firm_Data"]*"FullPeriodPD\\"
    PathStruct["CRI_Calibration_Parameter"] = PathStruct["Firm_Data"]*"PrivatePD_Calculation_Econ"*strSmeEconCodes*"\\CRI_Calibration_Parameter\\"
    PathStruct["SMEPD_Input"] = PathStruct["Firm_Data"]*"PrivatePD_Calculation_Econ"*strSmeEconCodes*"\\Input\\"
    PathStruct["SMEPD_Output"] = PathStruct["Firm_Data"]*"PrivatePD_Calculation_Econ"*strSmeEconCodes*"\\Output\\"

    Sub_Key = Array(["Industry_Data", "Industry_Factor", "forwardPDFolder", "SMEinfoFolder", "Industry_FactorModel",
                    "Industry_Results", "Firm_DTD_Regression_CriRiskFactor", "Firm_DTD_Regression_FS",
                    "Firm_DTD_Regression_FxRate", "Firm_DTD_Regression_Parameter", "Firm_Data",
                    "FullPeriodPD", "CRI_Calibration_Parameter", "SMEPD_Input", "SMEPD_Output"])
    n = length(Sub_Key)
    for i = 1:n
        if ~isdir(PathStruct[Sub_Key[i]])
            mkpath(PathStruct[Sub_Key[i]])
        end
    end

    return PathStruct, Econs
end
