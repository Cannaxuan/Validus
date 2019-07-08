function global_constants_extra(GConst, dateEnd)
    ## This function adds extra global constants to GConst. This will merge with global_constant_definition_current later.
    #global GConst

    ## The BBG_ID of companies that are excluded in CRI system.
    ## Swiss Reinsurance Co Ltd (115745)
    GConst["COMPANY_EXCLUDED"] = 115745

    ## Countries whose stock index shall be scaled. Bangladesh(22), Cyprus(31), Kuwait(51),
    ## Luxembourg(55),Morocco(61) and Romania(72).
    GConst["STKIDX_COUNTRY_CHANGE"] = [22,31,51,55,61,72]

    ## Countries whose risk free rates shall be forward filled:
    ## Cyprus(31), Estonia(35), Luxembourg(55), Malta(58), Bosnia(26), Montenegro(60), Serbia(75) and Tunisia(84)
    GConst["RFR_FORWARD_FILL_COUNTRY"] = [31, 35, 55, 58, 26, 60, 75, 84]

    ## Return region indicator for each economy

    GConst["REGION_OF_ECON"] = Int64.(zeros(163))
    for nRegion = 1:4
        for j = GConst["ECONSREGION"][nRegion]
            GConst["REGION_OF_ECON"][j] = nRegion
        end
    end

    ##BBG_ID of Australia banks which only use annual financial statement.
    GConst["AUSTRALIA_BANK"]=[101034; 101650; 112620; 112699; 148581; 148582]

    ## Financial statement types used in CRI: Balance Sheet(1),Income
    ## Statement(3),SARD_BS(6) and nan.
    ##
    GConst["FS_TYPE"]=[1;3;6;NaN]
    GConst["FS_TYPE_NI"]=[1;3]

    GConst["FS_DATA"] = [8,10,16,19,27,32,33,37,38,117,159,160,185,249,294,394,510,911]
    GConst["FS_DATA_SPECIAL"]=[32,117] ## BS_SH_OUT (32) and NET_INCOME(117) requires special priority sorting.
    GConst["FS_DATA_NI"] = 117
    GConst["FS_DATA_TEJ"]=[8,10,16,19,32,37,38,117]

    str = "$(GConst["FS_DATA"])"
    sql = "SELECT Field_Mnemonic FROM [Tier2].[REF].BBG_FIELD_DEFINITION WHERE ID IN ($(str[2:end-1]))"
    cnt = connectDB()
    GConst["FS_FIELD_NAME"] = dropdims(convert(Matrix, get_data_from_DMTdatabase(sql, cnt)), dims = 2)

    GConst["FS_DATA_FINAL"] = [10,16,38,37,117,8,19]
    GConst["FS_FIELD_FINAL"] = ["BS_CUR_LIAB","BS_LT_BORROW","BS_TOT_LIAB2","BS_TOT_ASSET","NET_INCOME","BS_CASH_NEAR_CASH_ITEM","BS_MKT_SEC_OTHER_ST_INVEST"]

    GConst["EVENT_DEFAULT"] = setdiff(vcat(203,100:199,300:399),[116,117,304,309,310,312:316,318:321,324,329,332,333])
    GConst["EVENT_EXIT"] = setdiff(vcat(74, 200:299, 400:499),[203,206,207,218,227,229,230,231,232])
    GConst["HARD_DEFAULT"] = setdiff(vcat(203,100:199,301),[116,117])
    GConst["EVENT_CHANGE_SECTOR"] = collect(401:414)


    GConst["FS_ENTRY"] = ["BBG_ID","Period_End","Is_Consolidated","Fiscal_Period","Filing_Status","Accounting_STD","Currency",
                    "Time_Release","Time_Available_CRI","Time_Update","FS_ID","Source","FS_Type"]

    GConst["FISCAL_PERIOD"] = hcat(vcat(1,11,12,21:24,31:34,101:121),vcat(12,6,6,3,3,3,3,3,6,9,12,1:21))

    GConst["DATA_RETRIEVAL_SEGMENT"] = 100
    GConst["PENDING_EVENT"] = [74,201]
    GConst["PENDING_LENGTH"] = 180
    GConst["PERIOD_END"] = dateEnd
    return GConst
end
