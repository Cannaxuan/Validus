function caleEonStartYYYYmm(maxMonthEnumInEcon, dataEndDate)

     dateEndYear, dateEndMonth = fldmod(dataEndDate, 10000)
     dateEndMonth, dateEndDay = fldmod(dateEndMonth, 100)

     dateNum = dateEndYear * 12 + dateEndMonth
     dateNumEconStart = dateNum - maxMonthEnumInEcon

     econStartYYYYmm = Dict()
     econStartYYYYmm["YYYY"], econStartYYYYmm["mm"] = fldmod(dateNumEconStart, 12)
     econStartYYYYmm["mm"] = econStartYYYYmm["mm"] + 1

     return econStartYYYYmm
end
