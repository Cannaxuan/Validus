function retrieve_company_information(iEcon)
    iregion = GConst["REGION_OF_ECON"][iEcon]
    SpotForex = GConst["REGIONTIMEZONE"][iregion]
    sql = "SELECT * FROM [Test].[DBO].[FUN_RETRIV_HIST_COMP_INFO_ZF_3]('$SpotForex','$iEcon')"
    cnt = connectDB()
    companyInformation = get_data_from_DMTdatabase(sql, cnt)

    mappingsql = "select U4_COMPANY_ID,U3_COMPANY_NUMBER from [tier2].[PROD].[FUN_RETRIV_Mapping_SecurityToOldCompany]() order by U4_COMPANY_ID"
    mappingtable = get_data_from_DMTdatabase(mappingsql, cnt)

    mappindex = indexin(companyInformation.COMPANY_ID, mappingtable.U4_COMPANY_ID)
    compindex = indexin(mappingtable.U4_COMPANY_ID, companyInformation.COMPANY_ID)

    index = Int.(compindex[compindex .!= nothing])

    ## Remove company number which cannot be found in U3-U4 mapping table for testing purpose.
    companyInformation = companyInformation[index, :]

    ## change U4 compNo. to U3 compNo.
    companyInformation.COMPANY_ID = mappingtable.U3_COMPANY_NUMBER[mappindex[mappindex .!= nothing]]

    ## Remove Funds companies.
    if !isempty(companyInformation)
        companyInformation = companyInformation[companyInformation.Sector_number .!== 10009, :]
    end
    ## Remove Swiss Reinsurance Co Ltd.
    if !isempty(companyInformation)
        companyInformation = companyInformation[companyInformation.ID_BB_COMPANY .!== GConst["COMPANY_EXCLUDED"], :]
    end
    ## sortrows
    if !isempty(companyInformation)
        companyInformation = Matrix(missing2NaN!(sort(companyInformation, (:Exchange_country_ID, :COMPANY_ID))))
    end
    CompanyInformation = Dict("Company_Number" => 1, "BBG_ID" => 2, "Country_Exchange" => 3,
                        "Currency_Exchange" => 4, "Country_Domicile" => 5, "Currency_Equity" => 6,
                        "Number_Sector" => 7, "Number_Group" => 8, "Number_SubGroup" => 9)

    return companyInformation, CompanyInformation
end
