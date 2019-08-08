function datacombine_sub_v1(firmsales, mthendfxrate, compAll, tempdata)
    # firmsales, mthendfxrate, compAll, tempdata = MeFirms, Fx_Combined, FS_Raw_Combined, FS_Original_Combined
    firmsraw = firmsales[:, [:CompNo, :monthDate, :industryID, :econID, :Sales]]
    compAll  = compAll[:,[:CompNo, :monthDate, :CL, :LTB, :TL, :TA]]
    firmsraw = join(firmsraw, compAll, on = [:CompNo, :monthDate], kind = :left)
    tempdata = tempdata[:, [:CompNo, :monthDate, :rfr, :stkrtn, :NI2TA, :Cash]]
    firmsraw = join(firmsraw, tempdata, on = [:CompNo, :monthDate], kind = :left)
    firmsraw = join(firmsraw, mthendfxrate, on = [:monthDate, :econID], kind = :left)
    missing2NaN!(firmsraw)
    return firmsraw
end
