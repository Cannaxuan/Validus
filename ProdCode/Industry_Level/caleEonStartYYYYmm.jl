function caleEonStartYYYYmm(maxMonthEnumInEcon, dataEndDate)

     dateEndYear = floor(Int, dataEndDate/10000)
     dateEndMonth = floor(Int, dataEndDate/100) - dateEndYear*100

     dateNum = dateEndYear * 12 + dateEndMonth
     dateNumEconStart = dateNum - maxMonthEnumInEcon

     econStartYYYYmm = Dict()
     econStartYYYYmm["YYYY"] = floor(Int, dateNumEconStart/12)
     econStartYYYYmm["mm"] = mod(dateNumEconStart, 12) + 1

     return econStartYYYYmm
end
