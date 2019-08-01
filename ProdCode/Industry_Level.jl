using Distributed
# using Pkg, PyCall, Printf, Statistics, MAT, JLD, DataFrames, GLMNet, GLM, StatsBase, Random, LinearAlgebra, XLSX, CSV, Dates, ZipFile
addprocs(5)
# @everywhere push!(LOAD_PATH, "C:\\Users\\e0375379\\.juliapro\\JuliaPro_v1.0.3.2\\environments\\v1.0\\Project.toml")
@everywhere using Pkg
for i in ["PyCall","MAT", "Statistics", "Printf", "JLD", "DataFrames", "GLMNet", "GLM", "StatsBase", "Random",
        "XLSX", "CSV", "Dates", "ZipFile"]
        @everywhere i = $i
        println(i)
        @everywhere Pkg.add("$i")
end
@everywhere using Pkg, PyCall, Printf, Statistics, MAT, JLD, DataFrames, GLMNet, GLM, StatsBase,
                Random, XLSX, CSV, Dates, ZipFile
using LinearAlgebra
@everywhere prePath = raw"C:\Users\e0375379\Downloads\DT\Validus\Validus\ProdCode"
@everywhere include("$prePath/Industry_Level/date_yyyymm_add.jl")
@everywhere include("$prePath/Industry_Level/cal_country_PD_forward.jl")
@everywhere include("$prePath/Industry_Level/get_country_param.jl")
@everywhere include("$prePath/Industry_Level/get_country_PD_forward.jl")
@everywhere Ycom = raw"C:\Users\e0375379\Downloads\DT\Validus\Validus\ProdCode\Industry_Level\YX_Code"
@everywhere include(Ycom*"\\split_data.jl")

include("$prePath/Industry_Level/load_data_PD.jl")
include("$prePath/Industry_Level/generate_data_PD.jl")
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
include("$prePath/validus_path_define.jl")
include("$prePath/Industry_Level/get_country_PD_forward_specific.jl")
include("$prePath/Industry_Level/cust_data.jl")
include("$prePath/Industry_Level/trans_func.jl")
include("$prePath/Industry_Level/extract_industry_factors.jl")
include("$prePath/Industry_Level/generate_factors.jl")
include("$prePath/Industry_Level/caleEonStartYYYYmm.jl")
include("$prePath/Industry_Level/convert_date_to_mthEnum.jl")
include("$prePath/Industry_Level/uniqueidx.jl")
include("$prePath/Industry_Level/clean_sales_rev_turn.jl")
include("$prePath/Industry_Level/construct_mth_data.jl")
include("$prePath/Industry_Level/get_country_sizeInfo.jl")
include("$prePath/Industry_Level/generate_SME_info.jl")
include("$prePath/Industry_Level/Adaptive lasso/AdaptiveLasso_Genuine.jl")
include("$prePath/Industry_Level/Adaptive lasso/nanMean.jl")
include("$prePath/Industry_Level/Adaptive lasso/nanSum.jl")
include("$prePath/Industry_Level/regression_factor.jl")
include("$prePath/Industry_Level/regress_portfolio_factors.jl")
include("$prePath/Industry_Level/calculate_quantile_industry.jl")
include("$prePath/Industry_Level/saveDataInExcel.jl")
include("$prePath/Industry_Level/main_Validus.jl")
include("$prePath/Industry_Level/retrieve_financial_statement_raw.jl")
include("$prePath/Industry_Level/retrieve_sales_rev_turn_raw.jl")
include("$prePath/Industry_Level/generate_PDfile.jl")



function Industry_Level(DataDate, smeEcon = [1 3 9 10], PDEcon = 9)
 #=

     ## Production Procedure (Validus production code should be run shortly after monthly calibration without revision.)
     ## As Full Period data must be ready before the monthly production, please execute 1 and 2 first.
         ## 1.  Run CombineData_Main(DataMonth) under \\dirac\cri3\OfficialTest_AggDTD_SBChinaNA\ProductionCode\FullPeriodData
         ## 2.  Change Folder name DataMonth_withoutRevision e.g. 201806_withoutRevision
         ## 3.  Run Industry_Level(DataDate) for Validus
         ##         Industry_Level(DataDate,[1 3 10 15]) for other Econ portfolios
         ##  e.g DataDate = 20180629- The last trading date of the month
     ## The results will be saved in ProdData/DataMonth/Industry {DataPreparation/FactorModel/Products}
     ## by Yao Xuan 20190601
 =#

     # DataDate = 20190531
     DataMonth = fld(DataDate, 100)

     ## Initial path
     PathStruct = validus_path_define(DataMonth, smeEcon, PDEcon)
     main_Validus(DataDate, PathStruct, smeEcon)
end
