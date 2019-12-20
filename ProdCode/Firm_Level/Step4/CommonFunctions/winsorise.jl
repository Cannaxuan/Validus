function winsorise(firmspecific::Array{Float64,3}, lower::Array{Float64,1}, upper::Array{Float64,1})
    vrbls = firmspecific[:,4:end,:];
    nObs=size(vrbls,1);
    nVrbl=size(vrbls,2);
    nFirm=size(vrbls,3);
    #set inf and -inf to be missing
    vrbls[isinf.(vrbls)] .= NaN;
    lower_cap = lower';
    upper_cap = upper';
    lowerMatrix_cap=reshape(kron(ones(1,nFirm),lower_cap[(floor.(Int,ones(nObs,1)))[1:end],:]),nObs,nVrbl,nFirm);
    upperMatrix_cap=reshape(kron(ones(1,nFirm),upper_cap[(floor.(Int,ones(nObs,1)))[1:end],:]),nObs,nVrbl,nFirm);
    if sum(sum(sum(vrbls.<lowerMatrix_cap, dims = 3),dims = 2),dims = 1)!=0
        vrbls[vrbls.<lowerMatrix_cap] = lowerMatrix_cap[vrbls.<lowerMatrix_cap];
    end
    if sum(sum(sum(vrbls.>upperMatrix_cap,dims = 3),dims = 2),dims = 1)!=0
        vrbls[vrbls.>upperMatrix_cap] = upperMatrix_cap[vrbls.>upperMatrix_cap];
    end
    firmspecific[:,4:end,:] = vrbls;
    return firmspecific
end
