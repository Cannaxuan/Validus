function convert_date_to_mthEnum(date, dataEndDate, firmlist)
    # date, dataEndDate, firmlist = dataFlat[:,colUpdateDate], dataEndDate, firmlist

    maxMonthEnumInEcon = maximum(firmlist[:, 3])
    econStartYYYYmm = caleEonStartYYYYmm(maxMonthEnumInEcon, dataEndDate)

    MthEnum = Vector{Float64}(undef, size(date, 1))
    for i = 1:size(date, 1)
        yyyy, MM = fldmod(date[i], 10000)
        MM = fld(MM, 100)
        MthEnum[i] = (yyyy - econStartYYYYmm["YYYY"])*12 + MM - econStartYYYYmm["mm"] + 1
    end

    return MthEnum
end
