include("./impvalue_loop_bound_single.jl")
function  firm_dtd_daily(data, sig, weight, dtd_switch)
    # Calculate dtd
    daysInYear=250;
    nobs=size(data,1);
    nRows = size(data,1);

    data[:,6]=data[:,6]./daysInYear./100; #risk free rate
    data[:,4]=data[:,4]-data[:,3]-data[:,2];#other liability
    exitflag=NaN;
    fval=NaN;
    mu=NaN;
    liability=data[:,2]+0.5*data[:,3]+weight*data[:,4];

    #asset=impvalue_v011(data[:,1],liability,data[:,6],sig,daysInYear,av_ini);
    asset= zeros(nobs,1);

    for ieval = 1:nobs
        # asset[ieval,1] = impvalue_v011(data[ieval,1],liability[ieval],data[ieval,6],sig,daysInYear,av_ini);
        asset[ieval,1], Nd1 = impvalue_loop_bound_single(data[ieval,1],
                                                         liability[ieval],
                                                         data[ieval,6],
                                                         sig,
                                                         daysInYear);
    end
    if dtd_switch==1
        result=(log.(asset[:,1]./liability[:,1]))/(sig*sqrt(daysInYear));
    else
        result=(log.(asset[nrows,1]/liability[nRows,1])+mu*daysInYear)/(sig*sqrt(daysInYear));
    end
    return result
end
