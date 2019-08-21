using Distributed
addprocs(7)
using Pkg, Printf, Statistics, MAT, JLD, DataFrames, GLMNet, GLM, StatsBase, Random,
    LinearAlgebra, XLSX, CSV, Dates, Missings, ToolCK, ZipFile, PyCall, SharedArrays

prePath = raw"C:\Users\e0375379\Downloads\DT\Validus\Validus\ProdCode"
include("$prePath/validus_path_define.jl")
Ycom = raw"C:\Users\e0375379\Downloads\DT\Validus\Validus\ProdCode\Industry_Level\YX_Code"
include(Ycom*"\\connectDB.jl")
include(Ycom*"\\get_data_from_DMTdatabase.jl")
include(Ycom*"\\highest_indexin.jl")
include(Ycom*"\\readConfig.jl")
include(Ycom*"\\RetrieveFieldEnum_v011.jl")
include(Ycom*"\\RetrieveDwnAccStdrd_v011.jl")
include(Ycom*"\\global_numer_definition_current.jl")
include(Ycom*"\\global_constants_extra.jl")
include(Ycom*"\\pivot.jl")
include(Ycom*"\\convert_currency_financial_statement.jl")
include(Ycom*"\\get_specific_day_value.jl")
include(Ycom*"\\get_individual_first_use_time.jl")
include(Ycom*"\\filter_financial_statement.jl")
include(Ycom*"\\convert_currencyID_to_FXID.jl")
include(Ycom*"\\GCdef.jl")
include("$prePath/Industry_Level/Adaptive lasso/nanSum.jl")
include("$prePath/Industry_Level/Adaptive lasso/nanMean.jl")
include("$prePath/Industry_Level/Adaptive lasso/nanMedian.jl")
include("$prePath/Industry_Level/YX_Code/missing2NaN.jl")
include("$prePath/Industry_Level/YX_Code/missing2real.jl")
include("$prePath/Industry_Level/YX_Code/quantiledims.jl")
include("$prePath/Industry_Level/YX_Code/searchdir.jl")
include(prePath*"\\Firm_Level\\Step1\\data_preparation_main.jl")
include(prePath*"\\Firm_Level\\Step1\\DTDinput.jl")
include(prePath*"\\Firm_Level\\Step1\\forex.jl")
include(prePath*"\\Firm_Level\\Step1\\DTD.jl")
include(prePath*"\\Firm_Level\\Step1\\OriginalData.jl")
include(prePath*"\\Firm_Level\\Step1\\sales.jl")
include(prePath*"\\Firm_Level\\Step1\\selectSME.jl")
include(prePath*"\\Firm_Level\\Step1\\datacombine_sub_v1.jl")
include(prePath*"\\Firm_Level\\Step1\\prepareCols_v1.jl")
include(prePath*"\\Firm_Level\\Step1\\datacombine.jl")
include(prePath*"\\Firm_Level\\Step1\\data_preparation_main.jl")
include(prePath*"\\Firm_Level\\Step2\\DTDmapping.jl")
include(prePath*"\\Firm_Level\\Step2\\globalMedianVctr.jl")
include(prePath*"\\Firm_Level\\Step2\\RatioPart.jl")
include(prePath*"\\Firm_Level\\Step2\\LogRatioPart.jl")
include(prePath*"\\Firm_Level\\Step2\\MacroPart.jl")
include(prePath*"\\Firm_Level\\Step2\\formalizeRegressionM.jl")
include(prePath*"\\Industry_Level\\Adaptive lasso\\AdaptiveLasso_Genuine.jl")
include(prePath*"\\Firm_Level\\Step2\\LassoRegression.jl")
include(prePath*"\\Firm_Level\\Step2\\datacleanforRegression_main.jl")
include(prePath*"\\Firm_Level\\Step2\\handlepdall.jl")
include(prePath*"\\Firm_Level\\Step2\\compute_Var_quantile.jl")
@everywhere using MAT, JLD
include(prePath*"\\Firm_Level\\Step2\\step2_II_PDpreparation.jl")
include(prePath*"\\Firm_Level\\Step3\\read_fs_xls_V2.jl")
include(prePath*"\\Firm_Level\\Step3\\fs2DTDinput_v3.jl")
include(prePath*"\\Firm_Level\\Step3\\fs2DTDinput_v4.jl")
include(prePath*"\\Firm_Level\\Step3\\fs2PDinput_v2.jl")
include(prePath*"\\Firm_Level\\Step3\\compute_level_trend.jl")
include(prePath*"\\Firm_Level\\Step3\\computePD_Validus.jl")
include(prePath*"\\Firm_Level\\Step3\\Cal_CountryPD_v011.jl")
include(prePath*"\\Firm_Level\\Step3\\global_quantile_to_cell.jl")
include(prePath*"\\Firm_Level\\Step3\\compute_firm_quantile.jl")
include(prePath*"\\Firm_Level\\Step3\\firm_quantile_to_cell.jl")
include(prePath*"\\Firm_Level\\Step3\\step3_generate_report.jl")

function Firm_Level(DataDate, smeEcon = [1 3 9 10], PDEcon = 9)
    # DataDate = 20190630
    #= Firm_Level can be run right after validation request for Industry Level.
      As Validation team does not validate firm_level results,
      you should compare previous month betaMe, betaSm, betaMi with
      the current  betaMe, betaSm, betaMi to check any significant changes.
      Some of Industry Level outputs will be used as inputs for Firm_Level.
      e.g. Firm_Level(20180629) for Validus
           Firm_Level(20180629,[1 3 15]) for other Econ portfolios
    =#
    DataMonth = fld(DataDate, 100)

    ## Initial options and path
    PathStruct = validus_path_define(DataMonth, smeEcon, PDEcon)

    data_preparation_main(PathStruct, DataDate, DataMonth, smeEcon)

    datacleanforRegression_main(PathStruct, DataMonth, smeEcon, PDEcon)

    step2_II_PDpreparation(PathStruct, DataMonth, smeEcon)

end
