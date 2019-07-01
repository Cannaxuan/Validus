function global_numer_definition_current()
    global GC

    ## market variables
    cell_temp = ["'CUR_MKT_CAP'"; "'PX_VOLUME'"; "'PX_LAST'"]
    GC["MC_IDX"] = Dict()
    GC["FIRMSPECIFIC_MKT_VAR"] = RetrieveFieldEnum_v011(cell_temp, GC["MC_IDX"], 1)[1]

    ## number of firms to download at once for market data, daily update
    GC["FIRMSPECIFIC_MKT_DLY_NFIRMS"] = 1000
    GC["FIRMSPECIFIC_MKT_HIST_NFIRMS"] = 100
    GC["FIRMSPECIFIC_MKT_SUB_HIST_NFIRMS"] = 25

    ## the accounting standards that should be given lower priority
    GC["DNPRIORITY_ACCSTDRD"] = RetrieveDwnAccStdrd_v011()

    # financial statement variables
    cell_temp = ["'BS_CASH_NEAR_CASH_ITEM'"; "'BS_CUR_LIAB'"; "'BS_CUST_ACCPT_LIAB_CUSTDY_SEC'"; "'BS_CUSTOMER_DEPOSITS'";
            "'BS_LT_BORROW'"; "'BS_MKT_SEC_OTHER_ST_INVEST'"; "'BS_OTHER_ST_LIAB'"; "'BS_ST_BORROW'"; "'BS_TOT_ASSET'";
            "'BS_TOT_LIAB2'"; "'NET_INCOME'";" 'ARD_SEC_PURC_UNDER_AGR_TO_RESELL'"; "'ARD_ST_INVEST'"; "'ARD_TOT_ASSETS'";
            "'BS_INTERBANK_ASSET'"; "'BS_SH_OUT'"; "'ST_LIAB_AND_CUST_ACC'"; "'BS_SEC_SOLD_REPO_AGRMNT'"]
    GC["FS_IDX"]= Dict()
    GC["FIRMSPECIFIC_FS_VAR"], GC["FIRMSPECIFIC_FS_TYPES"] = RetrieveFieldEnum_v011(cell_temp, GC["FS_IDX"], 2)

    ## factors and tolerance around factors for adjusting as reported numbers
    GC["AR_FACTORS"]= [0.000001; 0.001; 1; 1000]
    GC["AR_TOL"] = [0.01; 0.01; 0.1; 0.01]

    ## financial statement variables to be taken from annual FS
    cell_temp = ["'NET_INCOME'"; "'BS_TOT_ASSET'"]
    GC["FS_ANN_IDX"] = Dict()
    GC["FIRMSPECIFIC_FS_VAR_ANN"], GC["FIRMSPECIFIC_FS_TYPES_ANN"] = RetrieveFieldEnum_v011(cell_temp, GC["FS_ANN_IDX"], 2)

    ## number of firms to download at once for FS data, daily update
    GC["FIRMSPECIFIC_FS_DLY_NFIRMS"] = 600
    GC["FIRMSPECIFIC_FS_HIST_NFIRMS"] = 200

    ## number of FS to download at once for FS data, daily update
    GC["FIRMSPECIFIC_FS_DLY_NFS"] = 20000
    GC["FIRMSPECIFIC_FS_HIST_NFS"] = 10000

    GC["FIRMSPECIFIC_FS_NVARS_OUT"] = 7

    GC["FIRMSPECIFIC_FS_ANN_NVARS_OUT"] = 2

    return GC
end
