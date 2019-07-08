function construct_mth_data(dataFlat, iEcon, dataEndDate, options, folders)
     # dataFlat, iEcon, dataEndDate, options, folders = sales_rev_turn_clean, iEcon, dataEndDate, options, folders
     ## input
     #### output 3-D demension
     ## 1-D months; 2-D col1:company number, col2: filed update date, col3: field value; 3-D firms

     #### Construct the data
     dataEndMth = fld(dataEndDate, 100)
     dataMthToLoad =  date_yyyymm_add(dataEndMth, 1)
     firmList_withCompNum = matread(folders["Firm_Specific"]*"firmList_withCompNum_"*string(iEcon)*".mat")["firmList_withCompNum"]
     firmMonth = matread(folders["FinalData"]*"firmMonth_"*string(iEcon)*".mat")["firmMonth"]
     firmmonth = firmMonth
     firmlist = firmList_withCompNum
     # firmMonth = nothing ; firmList_withCompNum = nothing

     colCompNum = 1
     colUpdateDate = 3
     colFieldValue = 4
     colUpdateMth = 6
     colUpdateYear = 7
     colPeriodEnd = 5
     mthEnum = convert_date_to_mthEnum(dataFlat[:,colUpdateDate], dataEndDate, firmlist)
     dataFlat = cat(dataFlat, mthEnum .+ 12, dims = 2) ## add one more year to find data more previous
     dataFlat = dataFlat[dataFlat[:,colUpdateMth] .> 0, :]  ## remove the very early data

     nMonths = size(firmmonth, 1)
     nFirms = size(firmmonth, 3)
     dataFlatMth = fill(NaN, (nMonths + 12, 4, nFirms))
     start = time()
     for iFirm = 1:nFirms
         compNum = fld(firmlist[iFirm, 1], 1000)
         tempDataFlat = dataFlat[dataFlat[:,1] .== compNum,:]
         if sum(isnan.(tempDataFlat)) != 0
             tempDataFlat = tempDataFlat[vec(sum(isnan.(tempDataFlat), dims = 2) .== 0),:]
         end
         tempDataFlat = cat(tempDataFlat, fld.(tempDataFlat[:, colUpdateDate], 10000), dims = 2)
         uniqueYear = unique(tempDataFlat[:,colUpdateYear])
         tempYearData = fill(NaN, (length(uniqueYear),1))

         for iYear = 1:length(uniqueYear)
             year = uniqueYear[iYear]
             temp_data = tempDataFlat[tempDataFlat[:, colUpdateYear] .== year, 4]
             tempYearData[iYear, 1] = mean(temp_data[.~isnan.(temp_data)][:])
         end

         tempYearData = cat(uniqueYear, tempYearData, dims = 2)

         rowInTDF = in.(tempDataFlat[:,colUpdateYear], [tempYearData[:, 1]])
         rowInTYD = indexin(tempDataFlat[:,colUpdateYear], tempYearData[:, 1])
         rowInTYD = rowInTYD[rowInTDF[:]]
         rowInTYD = convert(Array{Int64}, rowInTYD)

         tempDataFlat[rowInTDF, colFieldValue] = tempYearData[rowInTYD, 2]
         dataFlatMth[Int64.(tempDataFlat[:, colUpdateMth]), :, iFirm] =
         tempDataFlat[:, [colCompNum, colFieldValue, colUpdateDate, colPeriodEnd]]

         firmStartMth = Int64(firmlist[iFirm, 2] + 12)
         firmEndMth = Int64(firmlist[iFirm, 3] + 12)

         nanRowsToFill = findall(isnan.(dataFlatMth[:, 3, iFirm]))
         for iRow in nanRowsToFill
             if iRow >= firmStartMth && iRow <= firmEndMth
                 rowRefIdx = findlast(x -> x <= iRow, tempDataFlat[:, colUpdateMth])
                 if rowRefIdx != nothing
                     dataFlatMth[iRow, :, iFirm] =
                     tempDataFlat[rowRefIdx, [colCompNum, colFieldValue, colUpdateDate, colPeriodEnd]]
                 end
             end
         end
         dataFlatMth[vcat(collect(1:(firmStartMth - 1)), collect((firmEndMth + 1):size(dataFlatMth,1))), :, iFirm] .= NaN
     end
     dataFlatMth = dataFlatMth[13:end, :, :]
     dataFlatMth = cust_data(dataFlatMth, dataEndMth, options["startMth"])[1]

     ## classify size
     nSize = options["nSize"]
     dataFlatMth = cat(dataFlatMth, zeros(size(dataFlatMth,1), 1, size(dataFlatMth,3)), dims=2)
     for iSize = 1:size(nSize, 1)
          dataFlatMth[:, 5, :] +=
          ((dataFlatMth[:, 2, :] .>= nSize[iSize, 1]) .& (dataFlatMth[:, 2, :] .< nSize[iSize, 2])) .* iSize
     end
     s =  @sprintf "# Elapsed time = %3.2f seconds." (time()-start)
     println(s)
     return dataFlatMth
end
