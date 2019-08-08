function fs2DTDinput_v3(firminfo, endmonth, firmindex)
# firminfo, endmonth, firmindex = num[i], dateVctr[end], VfirmInfo[i, 1]
    if firminfo[1, 1] == size(firminfo, 2)
        firminfo = firminfo[2:end, :]'
        firminfo = Matrix(sort!(DataFrame(firminfo), (:x1)))

        firstmonth = Int(fld(firminfo[1, 1], 100))
        monthVtr = (Date(string(firstmonth), "yyyymm") + Month(1)):Month(1):Date(string(endmonth), "yyyymm")
        monthVtr = first.(yearmonth.(monthVtr))*100 + last.(yearmonth.(monthVtr))
        curcols = 16
            ####  Col1: NI/TA
            ####  Col2: sales/TA
            ####  Col3: TL/TA
            ####  Col4: cash/TA
            ####  Col5: cash/CL
            ####  Col6: CL/TL
            ####  Col7: LB/TL
            ####  Col8: BE/TL
            ####  Col9: BE/CL
            ####  Col10: log(TA/ median TA)
            ####  Col11: log(TA/TL)
            ####  Col12: rfr
            ####  Col13: stock index return
            ####  Col14: forex rate
            ####  Col15: median DTD
            ####  Col16: median 1/Sigma
        nrows = length(monthVtr)
        ncols = curcols + 2     ## 18 cols
        firmpreDTD = fill(NaN, nrows, ncols)
        BE = fill(NaN, nrows)   ## Size proxy: Book Equity

        firmpreDTD[:, 1] .= firmindex
        firmpreDTD[:, 2]  = monthVtr

        period_end = firminfo[:, 1]
        push!(period_end, 1e10)     ## in matlab, add Inf to
        idxtmp = fill(false, length(monthVtr))
        for i = 1:length(period_end)-1
            # global period_end, idxtmp
            idx = fld(period_end[i], 100) .< monthVtr .<= fld(period_end[i+1], 100)
            testidx = idx .& .!idxtmp
            firmpreDTD[testidx, 3:end-5] = repeat(
                [firminfo[i, 8]/12 ./firminfo[i, 2]        ## 3:NI/TA
                firminfo[i, 9]/12 ./firminfo[i, 2]         ## 4:sales/TA
                firminfo[i, 4]./firminfo[i, 2]             ## 5:TL/TA
                firminfo[i, 7]./firminfo[i, 2]             ## 6:CASH/TA
                firminfo[i, 7]./firminfo[i, 5]             ## 7:CASH/CL
                firminfo[i, 5]./firminfo[i, 4]             ## 8:CL/TL
                firminfo[i, 6]./firminfo[i, 4]             ## 9:LB/TL
                firminfo[i, 10]./firminfo[i, 4]            ## 10:BE/TL
                firminfo[i, 10]./firminfo[i, 5]            ## 11:BE/CL
                firminfo[i, 2]./1e6                        ## 12:TA in million for log(TA/median TA)
                firminfo[i, 2]./firminfo[i, 4]]',          ## 13:TA/TL for log(TA/TL)
                outer = (sum(testidx), 1))
            BE[testidx] = repeat([firminfo[i, 10]/1e6], outer = sum(testidx))

            idxtmp = idx
        end
    else
        println("Error in financial statements!")
    end
    return firmpreDTD, BE
end
