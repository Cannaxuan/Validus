function  extract_industry_factors(transDataMtrxPD, firmInfo, industryCodes, qtIndustryFac)
     ## This function to to equentially extract the industry PD factors of
     ## the transformed  PD-quantile (standardized)

     nMths = size(transDataMtrxPD, 1)
     nIndus = length(industryCodes)
     industryFacsPD = fill(NaN,(nMths, nIndus,60))

     ## Take the median PD of all firms in each industry of each month for each horizon
     for iIndu = 1:nIndus
         iInduFirmIdx = in.(industryCodes[:, iIndu], firmInfo[:, 5])
         for iMths = 1: nMths
             for iHorizon = 1:60
                 PDtemp = transDataMtrxPD[iMths, iInduFirmIdx, iHorizon]
                 industryFacsPD[iMths, iIndu, iHorizon] = quantile(PDtemp[.!isnan.(PDtemp)], qtIndustryFac)
             end
         end
     end
     return industryFacsPD
end
