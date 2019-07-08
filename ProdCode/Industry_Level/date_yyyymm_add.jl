function date_yyyymm_add(dateVctr, mthAdd)
    ## This function is to add the date (yyyymm) by 'mthAdd' month.
    ## (Allow for adding negative month, i.e., substract months.)

    yyyy = fld(dateVctr, 100)
    mm = dateVctr-yyyy*100

    mm += mthAdd
    yyyyAdd = fld((mm-0.5), 12)

    yyyy += yyyyAdd
    mm -= yyyyAdd*12

    dateVctr = Int(yyyy*100+mm)

    return dateVctr
end
