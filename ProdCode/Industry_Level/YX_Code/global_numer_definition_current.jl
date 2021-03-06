function global_numer_definition_current(GConst)
    # global GConst

    ## market variables
    cell_temp = ["'CUR_MKT_CAP'"; "'PX_VOLUME'"; "'PX_LAST'"]
    GConst["MC_IDX"] = Dict()
    GConst["FIRMSPECIFIC_MKT_VAR"] = RetrieveFieldEnum_v011(cell_temp, GConst["MC_IDX"], 1)[1]

    ## number of firms to download at once for market data, daily update
    GConst["FIRMSPECIFIC_MKT_DLY_NFIRMS"] = 1000
    GConst["FIRMSPECIFIC_MKT_HIST_NFIRMS"] = 100
    GConst["FIRMSPECIFIC_MKT_SUB_HIST_NFIRMS"] = 25

    ## the accounting standards that should be given lower priority
    GConst["DNPRIORITY_ACCSTDRD"] = RetrieveDwnAccStdrd_v011()

    # financial statement variables
    cell_temp = ["'BS_CASH_NEAR_CASH_ITEM'"; "'BS_CUR_LIAB'"; "'BS_CUST_ACCPT_LIAB_CUSTDY_SEC'"; "'BS_CUSTOMER_DEPOSITS'";
            "'BS_LT_BORROW'"; "'BS_MKT_SEC_OTHER_ST_INVEST'"; "'BS_OTHER_ST_LIAB'"; "'BS_ST_BORROW'"; "'BS_TOT_ASSET'";
            "'BS_TOT_LIAB2'"; "'NET_INCOME'";" 'ARD_SEC_PURC_UNDER_AGR_TO_RESELL'"; "'ARD_ST_INVEST'"; "'ARD_TOT_ASSETS'";
            "'BS_INTERBANK_ASSET'"; "'BS_SH_OUT'"; "'ST_LIAB_AND_CUST_ACC'"; "'BS_SEC_SOLD_REPO_AGRMNT'"]
    GConst["FS_IDX"]= Dict()
    GConst["FIRMSPECIFIC_FS_VAR"], GConst["FIRMSPECIFIC_FS_TYPES"] = RetrieveFieldEnum_v011(cell_temp, GConst["FS_IDX"], 2)

    ## factors and tolerance around factors for adjusting as reported numbers
    GConst["AR_FACTORS"]= [0.000001; 0.001; 1; 1000]
    GConst["AR_TOL"] = [0.01; 0.01; 0.1; 0.01]

    ## financial statement variables to be taken from annual FS
    cell_temp = ["'NET_INCOME'"; "'BS_TOT_ASSET'"]
    GConst["FS_ANN_IDX"] = Dict()
    GConst["FIRMSPECIFIC_FS_VAR_ANN"], GConst["FIRMSPECIFIC_FS_TYPES_ANN"] = RetrieveFieldEnum_v011(cell_temp, GConst["FS_ANN_IDX"], 2)

    ## number of firms to download at once for FS data, daily update
    GConst["FIRMSPECIFIC_FS_DLY_NFIRMS"] = 600
    GConst["FIRMSPECIFIC_FS_HIST_NFIRMS"] = 200

    ## number of FS to download at once for FS data, daily update
    GConst["FIRMSPECIFIC_FS_DLY_NFS"] = 20000
    GConst["FIRMSPECIFIC_FS_HIST_NFS"] = 10000

    GConst["FIRMSPECIFIC_FS_NVARS_OUT"] = 7

    GConst["FIRMSPECIFIC_FS_ANN_NVARS_OUT"] = 2

    return GConst
end
