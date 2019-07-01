function filter_financial_statement(fsEntry, FsEntry, dateEnd)
    # fsEntry, FsEntry, dateEnd = financialStatement, FinancialStatement, dateEnd

    ## This function throws away financial statements that we don't cover.
    global GC

    ## Only consolidated or nonconsolidated FS will be considered meaningful
    ## Unknown consolidate status will be discarded.
    if ~isempty(fsEntry)
        idx = in.(fsEntry[:,FsEntry["Is_Consolidated"]],[[0, 1]])
        fsEntry = fsEntry[idx, :]
        ## If period end is beyond 1988-01-01 and dateEnd, we set it to NaN.
        ## The reason we don't throw away FS with period end ealier than 1988-01-01
        ## is that the data from Bloomberg has outliers that the period end is
        ## set as 1900-01-01 even though it may actually be, say, 2005-12-31.
        ## Such situation is similar for announcement day and CRI available day.
        idx = (fsEntry[:, FsEntry["Period_End"]].<GC["DATE_START_DATA"]).|(fsEntry[:,FsEntry["Period_End"]].>= dateEnd)
        fsEntry[idx, FsEntry["Period_End"]] .= NaN

        ## find missing value, and set it to NaN
        fsEntry[findall(ismissing.(fsEntry[:,FsEntry["Time_Release"]])), FsEntry["Time_Release"]] .= NaN
        ## If announcement day is beyond 1988-01-01 and dateEnd or it is earlier than period end, we set it to NaN.
        idx = (fsEntry[:,FsEntry["Time_Release"]].<GC["DATE_START_DATA"]).|(fsEntry[:,FsEntry["Time_Release"]].>dateEnd).|(fsEntry[:,FsEntry["Time_Release"]].<fsEntry[:,FsEntry["Period_End"]]).|(fsEntry[:,FsEntry["Time_Release"]].>fsEntry[:,FsEntry["Time_Available_CRI"]])
        fsEntry[idx, FsEntry["Time_Release"]] .= NaN


        ## If CRI available day is beyond 2011-03-01, we set it to NaN.
        ## This is because CRI started to import data after 2011-02-15.
        ## Choosing 2011-03-01 as the starting time to use CRI available date is just to be more conservative.
        ## If the available date is before the period end, we also set it to NaN.
        ## find missing value, and set it to NaN
        fsEntry[findall(ismissing.(fsEntry[:,FsEntry["Time_Available_CRI"]])), FsEntry["Time_Available_CRI"]] .= NaN
        idx = (fsEntry[:,FsEntry["Time_Available_CRI"]].<20110301).|(fsEntry[:,FsEntry["Time_Available_CRI"]].>dateEnd).|(fsEntry[:,FsEntry["Time_Available_CRI"]].<fsEntry[:,FsEntry["Period_End"]])
        fsEntry[idx, FsEntry["Time_Available_CRI"]] .= NaN
    end
    return fsEntry
end
