function firm_quantile_to_cell(result, PD, Sheetname, vfirmInfo, monthVctr, firm_title, PathStruct, filename)
    # PD, Sheetname, vfirmInfo = PD_all[:,:,i], sheetname[i], VfirmInfo[i,:]

    Diff = length(monthVctr) - length(result["PDiR"])
    firm_quantile_report = vcat(firm_title,
                                hcat([fld.(monthVctr, 100) mod.(monthVctr, 100)],
                                      vcat(fill(NaN, (Diff, 66)),
                                           hcat(result["global"], result["selectedEcons"], result["category"],
                                                result["industry"], result["selectedEconsPlusindustry"], result["PDiR"],
                                                PD[.!isnan.(PD[:, 4]), 4:63] * 10000))))
    file = XLSX.openxlsx(PathStruct["SMEPD_Output"]*filename, mode="rw")
    sheet = XLSX.addsheet!(file, Sheetname)
    XLSX.writetable!(sheet, DataFrame(firm_quantile_report), names(DataFrame(firm_quantile_report)))
    XLSX.writexlsx(PathStruct["SMEPD_Output"]*filename, file, overwrite = true)
end
