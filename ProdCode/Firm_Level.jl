function Firm_Level(DataDate, smeEcon = [1 3 9 10])
    ## Firm_Level can be run right after validation request for Industry Level.
    ## As Validation team does not validate firm_level results,
    ## you should compare previous month betaMe, betaSm, betaMi with
    ## the current  betaMe, betaSm, betaMi to check any significant changes.
    ## Some of Industry Level outputs will be used as inputs for Firm_Level.
    ## e.g. Firm_Level(20180629) for Validus
    ##      Firm_Level(20180629,[1 3 15]) for other Econ portfolios

    mpath = pwd()
    idx = find(mpath, "ProdCode")




end
