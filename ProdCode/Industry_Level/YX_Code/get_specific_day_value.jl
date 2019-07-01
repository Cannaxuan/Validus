function get_specific_day_value(data, specificDay)
    # data, specificDay = fxRate["Data"][idxRate][1], dateThisCurrency
    # get_specific_day_value(data, specificDay, traceLength, traceUnit = "day")
    #=
     Given a time series data and an array of specific days, e.g., month-end day, the function tries to return the data on these specific days.
     If there is any specific day that can not be found in the data, we replace the day and the value with most recent data.
     If the specific day is outside the time series, we set the whole row as NaN except the date column as NaN.
     The trace back length is specified by traceLength and traceUnit if provided.
     Input:
         data: Column 1:     dates in number format (yyyymmdd) in ascending order;
               Column 2-end: values as specificed by the struct Data.
         Data: The struct associtated to data which contains the column names and some other information.
         specificDay: a column of dates in number format (yyyymmdd). Though the order doesn't matter, it will be better if it is sorted.
         By default, the traceLength is in unit of day.
    =#
    nValue = size(data, 2)
    nDay = size(specificDay, 1)
    specificData = fill(NaN, nDay, nValue)
    specificData[:, 1] = specificDay

    data = Matrix(sort(DataFrame(data), :x1))
    #  If the specific day is one of the days in the data:
    isDate = in.(specificDay, [data[:, 1]])
    idx = indexin(specificDay, data[:, 1])
    idx = idx[idx .!= nothing]
    specificData[isDate,2:end] = data[idx,2:end]

    # If specific day is not one the trading days in data, we will replace the day and the value to the closest historical day and value.
    dayToShift = findall(.!isDate)
    if isempty(dayToShift)
        dayReplaced = []
        return specificData, dayReplaced
    end
    dayReplaced = fill(NaN, size(dayToShift, 1), 2)
    dayReplaced[:,1] = specificDay[.!isDate]
    for i = 1:size(dayToShift, 1)
        idxDay = findlast(data[:, 1] .<= specificDay[dayToShift[i]])
        if idxDay !== nothing
            specificData[dayToShift[i], 2:end] = data[idxDay, 2:end]
            # Record the dates that are replaced.
            dayReplaced[i, 2] = data[idxDay, 1]
        end
    end

    dayReplaced = dayReplaced[.!isnan.(dayReplaced[:,2]),:]
    return specificData, dayReplaced
end
