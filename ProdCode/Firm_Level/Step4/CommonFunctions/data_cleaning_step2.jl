function data_cleaning_step2!(fulldata::Array{Float64,2})

    #*****************************************************************
    # input():    n by 7 matrix with the following variables:
    #           1. firm id
    #           2. date()
    #           3. market cap
    #           4. current liability
    #           5. long term borrowing
    #           6. total liability
    #           7. total asset
    #           8. risk-free rate
    # note:     market cap jump criteria is removed on Oct 19 2010
    #*****************************************************************


    #**************************************************************************
    #           Rule 1: detect negative values
    #**************************************************************************

    DTDInput = Dict([("Company_Number",1),("Mapping_Number",1),("Time",2),("CUR_MKT_CAP",3),("BS_CUR_LIAB",4),("BS_LT_BORROW",5),("BS_TOT_LIAB2",6), ("BS_TOT_ASSET",7),("Risk_Free_Rate",8)]);


    fulldata[:,DTDInput["CUR_MKT_CAP"]] = map(f1,fulldata[:,DTDInput["CUR_MKT_CAP"]])
    fulldata[:,DTDInput["BS_CUR_LIAB"]] = map(f2,fulldata[:,DTDInput["BS_CUR_LIAB"]])
    fulldata[:,DTDInput["BS_LT_BORROW"]] = map(f2,fulldata[:,DTDInput["BS_LT_BORROW"]])
    fulldata[:,DTDInput["BS_TOT_LIAB2"]] = map(f1,fulldata[:,DTDInput["BS_TOT_LIAB2"]])
    fulldata[:,DTDInput["BS_TOT_ASSET"]] = map(f1,fulldata[:,DTDInput["BS_TOT_ASSET"]])
    otherLiab = fulldata[:,DTDInput["BS_TOT_LIAB2"]]-fulldata[:,DTDInput["BS_CUR_LIAB"]]-fulldata[:,DTDInput["BS_LT_BORROW"]]
    idx1 = otherLiab./fulldata[:,DTDInput["BS_TOT_LIAB2"]].<-0.01
    idx2 = otherLiab.<0.0
    fulldata[idx1,DTDInput["BS_TOT_LIAB2"]] .= NaN
    fulldata[.!idx1 .& idx2,DTDInput["BS_TOT_LIAB2"]] = fulldata[.!idx1 .& idx2,DTDInput["BS_CUR_LIAB"]]+fulldata[.!idx1 .& idx2,DTDInput["BS_LT_BORROW"]]

    return fulldata
end

f1(x) = x.<=0.0 ? NaN : x
f2(x) = x.<0.0 ? NaN : x
