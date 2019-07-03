using Printf, MAT, ToolCK, Statistics, JLD, DataFrames, GLMNet, GLM, StatsBase, Random, LinearAlgebra, XLSX, CSV, Dates, ZipFile
include("./Industry_Level/load_data_PD.jl")
include("./Industry_Level/generate_data_PD.jl")
include("./Industry_Level/date_yyyymm_add.jl")
include("./Industry_Level/get_country_param.jl")
include("./Industry_Level/cal_country_PD_forward.jl")
include("./validus_path_define.jl")
include("./Industry_Level/get_country_PD_forward.jl")
include("./Industry_Level/cust_data.jl")
include("./Industry_Level/trans_func.jl")
include("./Industry_Level/extract_industry_factors.jl")
include("./Industry_Level/generate_factors.jl")
include("./Industry_Level/caleEonStartYYYYmm.jl")
include("./Industry_Level/convert_date_to_mthEnum.jl")
include("./Industry_Level/uniqueidx.jl")
include("./Industry_Level/clean_sales_rev_turn.jl")
include("./Industry_Level/construct_mth_data.jl")
include("./Industry_Level/get_country_sizeInfo.jl")
include("./Industry_Level/generate_SME_info.jl")
include("./Industry_Level/Adaptive lasso/AdaptiveLasso_Genuine.jl")
include("./Industry_Level/Adaptive lasso/nanMean.jl")
include("./Industry_Level/Adaptive lasso/nanSum.jl")
include("./Industry_Level/regression_factor.jl")
include("./Industry_Level/regress_portfolio_factors.jl")
include("./Industry_Level/calculate_quantile_industry.jl")
include("./Industry_Level/main_Validus.jl")
include("./Industry_Level/retrieve_financial_statement_raw.jl")
include("./Industry_Level/retrieve_sales_rev_turn_raw.jl")




function Industry_Level(DataDate, smeEcon = [1 3 9 10])
 #=

     ## Production Procedure (Validus production code should be run shortly after monthly calibration without revision.)
     ## As Full Period data must be ready before the monthly production, please execute 1 and 2 first.
         ## 1.  Run CombineData_Main(DataMonth) under \\dirac\cri3\OfficialTest_AggDTD_SBChinaNA\ProductionCode\FullPeriodData
         ## 2.  Change Folder name DataMonth_withoutRevision e.g. 201806_withoutRevision
         ## 3.  Run Industry_Level(DataDate) for Validus
         ##         Industry_Level(DataDate,[1 3 10 15]) for other Econ portfolios
         ##  e.g DataDate=20180629- The last trading date of the month
     ## The results will be saved in ProdData/DataMonth/Industry {DataPreparation/FactorModel/Products}
     ## by Yao Xuan 20190531
 =#

     ## Add Paths
     # DataDate = 20190430
     mpath = pwd()
     idx = findfirst("ProdCode", mpath)
     prepath = mpath[1:idx[1]-1]
     DataMonth = floor(Int, DataDate/100)

     ## Initial path
     PathStruct = validus_path_define(DataMonth, smeEcon)
     main_Validus(DataDate, PathStruct, smeEcon)
end
