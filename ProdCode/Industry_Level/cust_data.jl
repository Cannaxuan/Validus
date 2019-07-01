function cust_data(data, dataEndMth, custMth, dateVctr = [])
    # data, dataEndMth, custMth = dataFlatMth, dataEndMth, options["startMth"]
     dataendmth = Dict()
     dataendmth["year"] =  Int64(floor(dataEndMth/100))
     dataendmth["month"] =  Int64(dataEndMth - dataendmth["year"]*100)

     custMth_year = Int64(floor(custMth/100))
     custMth_month = Int64(custMth - custMth_year*100)

     validMth = (dataendmth["year"] - custMth_year)*12 + dataendmth["month"] - custMth_month + 1

     totalMth = size(data, 1)
     data = data[(totalMth - validMth + 1):end, :, :]
     dateVctr = dateVctr[(totalMth - validMth + 1):end, :]
     return data, dateVctr
end
