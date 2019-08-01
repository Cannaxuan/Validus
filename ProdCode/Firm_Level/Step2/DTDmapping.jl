function DTDmapping(Table, DTDlist)

    IncreTable = join(Table, DTDlist, on = [:CompNo, :monthDate], kind = :left)
    missing2NaN!(IncreTable)

    return IncreTable
end
