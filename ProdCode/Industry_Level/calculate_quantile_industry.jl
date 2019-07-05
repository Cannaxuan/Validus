function calculate_quantile_industry(dataEndDate, folders, smeEconCodes)
     # dataEndDate, folders, smeEconCodes = dataEndDate, PathStruct, smeEcon

     ## Read full period data
     ## Julia cannot read large mat file, need to resave it by adding '-v7.3' through matlab
     ## therefore, the read path is changed, later all files would be transfered to jld.
     IncrementalPD = matread(raw"C:\Users\e0375379\Downloads\DT\Validus\Validus"*"\\pd60hUpToMostRecent_bk.mat")["dataUpToMostRecent"]

     ## Load Total FirmHistory
     CompanyInformationIncremental = Array{Float64, 2}(undef, 0, 2)
     for i = 1:length(smeEconCodes)
         Firmhistory = matread(folders["CompanyInformationFolder"]*"FirmHistory_"*string(smeEconCodes[i])*".mat")
         firmHistory = Firmhistory["firmHistory"]
         FirmHistory = Firmhistory["FirmHistory"]
         CompanyInformationIncremental = vcat(CompanyInformationIncremental, firmHistory[:,[1,8]])
     end

     haha = in.(Int64.(IncrementalPD[:, 1]), [floor.(Int, CompanyInformationIncremental[:, 1]/1000)])
     indexInformation = indexin(Int64.(IncrementalPD[:, 1]), floor.(Int, CompanyInformationIncremental[:, 1]/1000))
     IncrementalPD = IncrementalPD[haha, :]
     IncrementalPD = cat(CompanyInformationIncremental[indexInformation[indexInformation .!= nothing], 2], IncrementalPD, dims = 2)
     IncrementalPD[:, 2] = IncrementalPD[:, 2] * 1000
     # 1. It does not matter using mapping number or company ID, it is just a quantile
     # 2. The most recent one should end with 000
     IncrementalPD[:, 15] .= 0

     CombineMonthEndForPeriod = IncrementalPD
     CombineMonthEndForPeriod = Matrix(sort(DataFrame(CombineMonthEndForPeriod), (:x1, :x2, :x3, :x4)))

     ##  Continue the following steps
     temp_month = (floor.(Int, dataEndDate/10000) - 1988) *12 + parse(Int64, folders["dataSource"][end-1:end])
     temp = fill(NaN, temp_month, 1)
     PDAll = Array{Float64, 2}(undef, temp_month, 0)
     for m = unique(CombineMonthEndForPeriod[:,2])
         #  Need change once the logic for PD was settled
         temp_month = (floor.(Int, dataEndDate/10000) - 1988) *12 + parse(Int64, folders["dataSource"][end-1:end])
         temp = fill(NaN, temp_month, 1)
         tempCompYearMonth = CombineMonthEndForPeriod[CombineMonthEndForPeriod[:, 2] .== m, :]
         tempCompYearMonth[:, 1] = (tempCompYearMonth[:, 3] .- 1988) * 12 .+ tempCompYearMonth[:, 4]
         tempCompYearMonth = tempCompYearMonth[tempCompYearMonth[:,1] .<= temp_month,:]
         temp[Int.(tempCompYearMonth[:, 1]), 1] = tempCompYearMonth[:, 17]  ## Extract 1 year PDs
         PDAll = cat(PDAll, temp, dims = 2)
     end

     ## load smeInfo and smeModel
     resultFolder = folders["Industry_FactorModel"]
     SMEinfoFolder = folders["SMEinfoFolder"]
     smeModelResult_indSize = load(resultFolder*"smeModel.jld")["smeModelResult_indSize"]
     PDSME = smeModelResult_indSize["PDest"]
     SmeInfo = load(SMEinfoFolder*"smeInfo.jld")
     nIndSizeFirms = smeInfo["smeIndSizeCount"]
     nIndFirms = smeInfo["smeIndCount"]
     nInd = size(nIndFirms,2)
     nSize = Int(size(nIndSizeFirms, 2) / nInd)
     nHorizons = 60
     PDSME_CombineSize = Array{Float64,3}(undef, size(nIndFirms, 1), nInd, nHorizons)
     PDSME_CombineAll =  Array{Float64,2}(undef, size(nIndFirms, 1), nHorizons)
     PDSME_CombineIndustry = Array{Float64,3}(undef, size(nIndFirms, 1), nSize, nHorizons)

     for iHorizon = 1:nHorizons
         PDSME_thisHorizon = PDSME[:, :, iHorizon]
         for iInd = 1:nInd
             PDSME_CombineSize[:, iInd, iHorizon] =
             sum(PDSME_thisHorizon[:,((iInd - 1) * nSize + 1):iInd * nSize] .* nIndSizeFirms[:, (iInd-1)*nSize+1 : iInd * nSize], dims = 2) ./ nIndFirms[:,iInd]
         end
         PDSME_CombineAll[:,iHorizon] = sum(PDSME_CombineSize[:,:,iHorizon] .* nIndFirms, dims = 2) ./ sum(nIndFirms, dims = 2)
         for iSize = 1:nSize
             PDSME_CombineIndustry[:,iSize,iHorizon] =
             sum(PDSME_thisHorizon[:, iSize:nSize:((nInd-1)*nSize+iSize)] .* nIndSizeFirms[:, iSize:nSize:((nInd-1)*nSize+iSize)], dims = 2) ./
             sum(nIndSizeFirms[:, iSize:nSize:((nInd-1)*nSize+iSize)], dims = 2)
         end
     end
     ## unify dataEndMth
     PDSME_1yr = PDSME[:, :, 12]
     PDSME_CombineSize_1yr = PDSME_CombineSize[:,:,12]
     PDSME_CombineIndustry_1yr = PDSME_CombineIndustry[:,:,12]
     PDSME_CombineAll_1yr = PDSME_CombineAll[:,12]

     nMthSME, nIndustryxSize  = size(PDSME_1yr)
     nMthOverall = size(PDAll, 1)
     nFirmsOverall = sum(isfinite.(PDAll), dims = 2)
     PDAll = PDAll[(nMthOverall - nMthSME + 1):end, :]

     qntGlobal = Array{Float64,2}(undef,size(PDAll, 1), 2)
     for i = 1:size(PDAll, 1)
         qntGlobal[i,:] = quantile(PDAll[i, .!isnan.(PDAll[i, :])], [0.05 0.95])
     end

     rankIndustryxSize = Array{Float64,2}(undef, 0, 10)
     rankIndustry = Array{Float64,2}(undef, nMthSME, size(PDSME_CombineSize_1yr, 2))
     rankSize = Array{Float64,2}(undef, nMthSME, size(PDSME_CombineIndustry_1yr, 2))
     rankAll = Array{Float64,2}(undef, nMthSME, size(PDSME_CombineAll_1yr, 2))
     for i = 1: nMthSME
        invprctile = ecdf(PDAll[i, .!isnan.(PDAll[i,:])])
        temp = invprctile(PDSME_1yr[i,:]) * 100
        rankIndustryxSize = cat(rankIndustryxSize, deepcopy(reshape(temp,nSize,:)), dims = 1)
        rankIndustry[i,:] = invprctile(PDSME_CombineSize_1yr[i,:])' * 100
        rankSize[i,:] = invprctile(PDSME_CombineIndustry_1yr[i,:])' * 100
        rankAll[i,:] = invprctile(PDSME_CombineAll_1yr[i,:])' * 100
     end
     quantileInfo = Dict()
     quantileInfo["rankAll"] = rankAll
     quantileInfo["rankIndustryxSize"] = rankIndustryxSize
     quantileInfo["rankIndustry"] = rankIndustry
     quantileInfo["rankSize"] = rankSize
     quantileInfo["qntGlobal"] = qntGlobal
     quantileInfo["PDSME_CombineIndustry"] = PDSME_CombineIndustry
     quantileInfo["PDSME_CombineSize"] = PDSME_CombineSize
     quantileInfo["PDSME_CombineAll"] = PDSME_CombineAll
     matwrite(resultFolder*"quantileInfo.mat", quantileInfo)

     Data = tuple(rankIndustryxSize, rankIndustry, rankSize, rankAll, qntGlobal*10000)
     file = XLSX.open_empty_template()
     for i = 1:length(Data)
         if i==1
             sheet = file[i]
             #XLSX.rename!(sheet, "Sheet1")
             data = DataFrame(Data[i])
             XLSX.writetable!(sheet, data, split(" "^(size(Data[i], 2) - 1), " "))
         else
             sheet = XLSX.addsheet!(file,"Sheet"*string(i))
             data = DataFrame(Data[i])
             column_names = split(" "^(size(Data[i], 2) - 1), " ")
             XLSX.writetable!(sheet, data, column_names)
         end
     end
     XLSX.writexlsx(folders["Industry_Results"]*"quantile_data.xlsx", file, overwrite=true)

     PDSME_CombineIndustryFlat =  round.(deepcopy(reshape((permutedims(PDSME_CombineIndustry, [2, 1, 3]) * 10000), :, nHorizons)), digits=4)
     PDSME_CombineSizeFlat =  round.(deepcopy(reshape(PDSME_CombineSize, :, nHorizons * nInd) * 10000), digits=4)
     PDSME_CombineAll =  round.(PDSME_CombineAll * 10000, digits=4)

     CombineData = tuple(PDSME_CombineIndustryFlat, PDSME_CombineSizeFlat, PDSME_CombineAll)
     Combinefile = XLSX.open_empty_template()

     sheet1 = Combinefile[1]
     XLSX.rename!(sheet1, "PDSME_CombineIndustryFlat")
     XLSX.writetable!(sheet1, DataFrame(CombineData[1]), split(" "^(size(CombineData[1], 2) - 1), " "))
     sheet2 = XLSX.addsheet!(Combinefile,"PDSME_CombineSizeFlat")
     XLSX.writetable!(sheet2, DataFrame(CombineData[2]), split(" "^(size(CombineData[2], 2) - 1), " "))
     sheet3 = XLSX.addsheet!(Combinefile,"PDSME_CombineAll")
     XLSX.writetable!(sheet3, DataFrame(CombineData[3]),  split(" "^(size(CombineData[3], 2) - 1), " "))

     XLSX.writexlsx(folders["Industry_Results"]*"data_table_combine.xlsx", Combinefile, overwrite=true)

end
