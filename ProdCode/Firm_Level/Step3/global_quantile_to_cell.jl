function  global_quantile_to_cell(Varresult, monthVctr, global_title, selEcons_title, category_title, PathStruct, filename)

    # idx = Int.(ismember_CK(monthVctr, Varresult["global"]["V05"][:, 1])[2])
    idx = Int.(indexin(monthVctr, Varresult["global"]["V05"][:, 1]))
    globalPDquantiles = hcat(fld.(monthVctr, 100), mod.(monthVctr, 100),
        Varresult["global"]["V05"][idx, 2],
        Varresult["global"]["V95"][idx, 2],
        hcat([hcat(Varresult["ind"][i]["V05"][idx, 2], Varresult["ind"][i]["V95"][idx, 2]) for i = 1:10]...))

    global_quantile_report = DataFrame(vcat(global_title, globalPDquantiles))

    selEconsPDquantiles = hcat(fld.(monthVctr, 100), mod.(monthVctr, 100),
        Varresult["econs"]["V05"][idx, 2],
        Varresult["econs"]["V95"][idx, 2],
        hcat([hcat(Varresult["indecon"][i]["V05"][idx, 2], Varresult["indecon"][i]["V95"][idx, 2]) for i = 1:10]...))

    selEcons_quantile_report = DataFrame(vcat(selEcons_title, selEconsPDquantiles))

    categoryPDquantiles =  hcat(fld.(monthVctr, 100), mod.(monthVctr, 100),
        Varresult["medium"]["V05"][idx, 2], Varresult["medium"]["V95"][idx, 2],
        Varresult["small"]["V05"][idx, 2], Varresult["small"]["V95"][idx, 2],
        Varresult["micro"]["V05"][idx, 2], Varresult["micro"]["V95"][idx, 2])

    category_quantile_report = DataFrame(vcat(category_title, categoryPDquantiles))

    # file = XLSX.open_empty_template()
    # sheet1 = file[1]
    # XLSX.rename!(sheet1, "Global")
    # XLSX.writetable!(sheet1, global_quantile_report, fill(Symbol(" "), size(global_quantile_report, 2)))
    #
    # sheet2 = XLSX.addsheet!(file,"Selected Econs")
    # XLSX.writetable!(sheet2, selEcons_quantile_report, fill(Symbol(" "), size(selEcons_quantile_report, 2)))
    #
    # sheet3 = XLSX.addsheet!(file,"Categories in Selected Econs")
    # XLSX.writetable!(sheet3, category_quantile_report, fill(Symbol(" "), size(category_quantile_report, 2)))
    # XLSX.writexlsx(PathStruct["SMEPD_Output"]*filename, file, overwrite = true)


    ## three sheets
    XLSX.writetable(PathStruct["SMEPD_Output"]*filename,
       Global = (collect(eachcol(global_quantile_report)),
            fill(Symbol(" "), size(global_quantile_report, 2))),
       Selected_Econs =  (collect(eachcol(selEcons_quantile_report)),
            fill(Symbol(" "), size(selEcons_quantile_report, 2))),
       Categories_in_Selected_Econs = (collect(eachcol(category_quantile_report)),
            fill(Symbol(" "), size(category_quantile_report, 2))), overwrite = true)


end
