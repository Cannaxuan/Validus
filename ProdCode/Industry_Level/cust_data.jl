function cust_data(data, dataEndMth, custMth, dateVctr = [])
    # data, dataEndMth, custMth = dataMtrxPD, endMth, options["startMth"]
     dataendmth = Dict()
     dataendmth["year"] =  fld(dataEndMth, 100)
     dataendmth["month"] =  dataEndMth - dataendmth["year"]*100

     custMth_year = fld(custMth, 100)
     custMth_month = custMth - custMth_year*100

     validMth = Int((dataendmth["year"] - custMth_year)*12 + dataendmth["month"] - custMth_month + 1)

     totalMth = size(data, 1)
     data = data[(totalMth - validMth + 1):end, :, :]
     dateVctr = dateVctr[(totalMth - validMth + 1):end, :]
     return data, dateVctr
end
