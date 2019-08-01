function data_preparation_main(PathStruct, DataDate, DataMonth, smeEcon)
    nyear = 10
    println("Start DTDinput retrieve")
    DTDinput(PathStruct, DataDate, smeEcon, nyear, DataMonth)

    println("Start Forex retrieve")
    forex(PathStruct, smeEcon, DataMonth)

    println("Start DTD retrieve")
    DTD(PathStruct, smeEcon, DataMonth)

    println("Start Original Data retrieve")
    OriginalData(PathStruct, DataDate, smeEcon, nyear, DataMonth)

    println("Start Sales Data retrieve")
    sales(PathStruct, DataDate, smeEcon, nyear)

    println("Start Catogrize")
    selectSME(PathStruct, smeEcon, DataMonth)

    println("Start Combination")
    datacombine(PathStruct, smeEcon, DataMonth)

    println("Done")
end
