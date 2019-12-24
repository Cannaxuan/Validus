using Distributed
using Pkg, Printf, Statistics, MAT, JLD, DataFrames, GLMNet, GLM, StatsBase, Random,
    LinearAlgebra, XLSX, CSV, Dates, Missings, ZipFile, PyCall, ToolCK, SharedArrays
addprocs(7)
prePath = raw"\\unicorn6\TeamData\VT_DT\Validus\ProdCode"
include("$prePath/validus_path_define.jl")
Ycom = raw"\\unicorn6\TeamData\VT_DT\Validus\ProdCode\Industry_Level\YX_Code"
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
include("$prePath/Industry_Level/YX_Code/read_jld.jl")
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
try
    @everywhere using MAT, JLD
catch
    @everywhere using Pkg
    @everywhere Pkg.add("MAT")
    @everywhere Pkg.add("JLD")
    @everywhere using MAT, JLD
end

include(prePath*"\\Firm_Level\\Step2\\step2_II_PDpreparation.jl")


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
