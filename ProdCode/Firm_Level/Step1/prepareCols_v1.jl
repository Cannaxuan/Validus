function prepareCols_v1(Firms)
    # Firms = MeFirms
    X = Firms
    nSample    = nrow(Firms)
    X.tmr      = fill(NaN, nSample)
    X.Sales2TA = Firms.Sales ./ Firms.TA / 12
    X.CA       = fill(NaN, nSample)
    X.NI       = fill(NaN, nSample)
    X.BE       = Firms.TA - Firms.TL
    return X
end
## 'CompNo', 'monthDate', 'industryID', 'econID', 'Sales', 'CL', 'LTB', 'TL', 'TA', 'rfr',
## 'stkrtn', 'NI2TA', 'Cash', 'fxrate', 'tme', 'Sales2TA', 'CA', 'NI', 'BE'
