function global_constants_extra(dateEnd)
    ## This function adds extra global constants to GC. This will merge with global_constant_definition_current later.
    global GC

    ## The BBG_ID of companies that are excluded in CRI system.
    ## Swiss Reinsurance Co Ltd (115745)
    GC["COMPANY_EXCLUDED"] = 115745

    ## Countries whose stock index shall be scaled. Bangladesh(22), Cyprus(31), Kuwait(51),
    ## Luxembourg(55),Morocco(61) and Romania(72).
    GC["STKIDX_COUNTRY_CHANGE"] = [22,31,51,55,61,72]

    ## Countries whose risk free rates shall be forward filled:
    ## Cyprus(31), Estonia(35), Luxembourg(55), Malta(58), Bosnia(26), Montenegro(60), Serbia(75) and Tunisia(84)
    GC["RFR_FORWARD_FILL_COUNTRY"] = [31, 35, 55, 58, 26, 60, 75, 84]

    ## Return region indicator for each economy

    GC["REGION_OF_ECON"] = Int64.(zeros(163))
    for nRegion = 1:4
        for j = GC["ECONSREGION"][nRegion]
            GC["REGION_OF_ECON"][j] = nRegion
        end
    end

    ##BBG_ID of Australia banks which only use annual financial statement.
    GC["AUSTRALIA_BANK"]=[101034; 101650; 112620; 112699; 148581; 148582]

    ## Financial statement types used in CRI: Balance Sheet(1),Income
    ## Statement(3),SARD_BS(6) and nan.
    ##
    GC["FS_TYPE"]=[1;3;6;NaN]
    GC["FS_TYPE_NI"]=[1;3]

    GC["FS_DATA"] = [8,10,16,19,27,32,33,37,38,117,159,160,185,249,294,394,510,911]
    GC["FS_DATA_SPECIAL"]=[32,117] ## BS_SH_OUT (32) and NET_INCOME(117) requires special priority sorting.
    GC["FS_DATA_NI"] = 117
    GC["FS_DATA_TEJ"]=[8,10,16,19,32,37,38,117]

    str = "$(GC["FS_DATA"])"
    sql = "SELECT Field_Mnemonic FROM [Tier2].[REF].BBG_FIELD_DEFINITION WHERE ID IN ($(str[2:end-1]))"
    cnt = connectDB()
    GC["FS_FIELD_NAME"] = dropdims(convert(Array, get_data_from_DMTdatabase(sql, cnt)), dims = 2)

    GC["FS_DATA_FINAL"] = [10,16,38,37,117,8,19]
    GC["FS_FIELD_FINAL"] = ["BS_CUR_LIAB","BS_LT_BORROW","BS_TOT_LIAB2","BS_TOT_ASSET","NET_INCOME","BS_CASH_NEAR_CASH_ITEM","BS_MKT_SEC_OTHER_ST_INVEST"]

    GC["EVENT_DEFAULT"] = setdiff(vcat(203,100:199,300:399),[116,117,304,309,310,312:316,318:321,324,329,332,333])
    GC["EVENT_EXIT"] = setdiff(vcat(74, 200:299, 400:499),[203,206,207,218,227,229,230,231,232])
    GC["HARD_DEFAULT"] = setdiff(vcat(203,100:199,301),[116,117])
    GC["EVENT_CHANGE_SECTOR"] = collect(401:414)


    GC["FS_ENTRY"] = ["BBG_ID","Period_End","Is_Consolidated","Fiscal_Period","Filing_Status","Accounting_STD","Currency",
                    "Time_Release","Time_Available_CRI","Time_Update","FS_ID","Source","FS_Type"]

    GC["FISCAL_PERIOD"] = hcat(vcat(1,11,12,21:24,31:34,101:121),vcat(12,6,6,3,3,3,3,3,6,9,12,1:21))

    GC["DATA_RETRIEVAL_SEGMENT"] = 100
    GC["PENDING_EVENT"] = [74,201]
    GC["PENDING_LENGTH"] = 180
    GC["PERIOD_END"] = dateEnd
    return GC
end
