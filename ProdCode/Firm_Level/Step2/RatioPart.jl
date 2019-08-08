function RatioPart(IncreTable)
# :CompNo, :monthDate, :econID, :NI2TA, :Sales2TA, :BE2TA, :CL2TA, :TL2TA, :Cash2TA, :Cash2CL, :CL2TL, :LTB2TL, :BE2TL, :BE2CL
    RatioM = IncreTable[:, [:CompNo, :monthDate, :econID, :NI2TA, :Sales2TA]]
    RatioM.TL2TA    = IncreTable.TL   ./ IncreTable.TA
    RatioM.Cash2TA  = IncreTable.Cash ./ IncreTable.TA
    RatioM.Cash2CL  = IncreTable.Cash ./ IncreTable.CL
    RatioM.CL2TL    = IncreTable.CL   ./ IncreTable.TL
    RatioM.LTB2TL   = IncreTable.LTB  ./ IncreTable.TL
    RatioM.BE2TL    = IncreTable.BE   ./ IncreTable.TL
    RatioM.BE2CL    = IncreTable.BE   ./ IncreTable.CL

    return RatioM
end
