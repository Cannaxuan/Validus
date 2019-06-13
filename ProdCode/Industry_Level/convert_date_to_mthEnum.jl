function convert_date_to_mthEnum(date, dataEndDate, firmlist)
    yyyyMM = Dict()
    yyyyMM["yyyy"] = floor.(Int, date/10000)
    yyyyMM["MM"] = floor.(Int, date/100) - yyyyMM["yyyy"]*100

    maxMonthEnumInEcon = maximum(firmlist[:,3])
    econStartYYYYmm = caleEonStartYYYYmm(maxMonthEnumInEcon, dataEndDate)
    MthEnum = (yyyyMM["yyyy"] .- econStartYYYYmm["YYYY"])*12 + yyyyMM["MM"] .- econStartYYYYmm["mm"] .+ 1

    return MthEnum
end
