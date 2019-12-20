using JldTools
function DP_country_abnml_v011(countrycode::Int64, firmlist::Array{Float64,2}, Jmp::Int64, inputDir::String, inputDPDir::String, CALIBRATION_DATE::Int64)

    mth = 12

    DPlimit = 1/100
    diffDPlimit = 1/1000

    file = string(inputDir, "RplmntRcd_", countrycode, ".jld")
    RplmntRcd = JldTools.cri_read_jld(file)["RplmntRcd"]

    RplmntRcd[isnan(RplmntRcd)] = 0

    file = string(inputDPDir, "DP_all_beforeHandling_", countrycode, "_", CALIBRATION_DATE, ".jld")
    DP_all = JldTools.cri_read_jld(file)["PD_all"]

    TmVct = DP_all[:,2:3,1]

    DP_mth = reshape(DP_all[:,3+mth,:],size(DP_all,1),size(DP_all,3))
    DP_rtn = abs(diff(DP_mth)./DP_mth[1:end-1,:])
    DP_diff = abs(diff(DP_mth))
    Idr = diff(RplmntRcd)
    Mrk = fill!(Array(Float64,1+size(Idr,1),2+size(Idr,2)),NaN)

    for i = 1:size(Idr,2)
        Mrk[1,2+i]  =firmlist[i,1]
        RpS=NaN
        for t = 1:size(Idr,1)
            if Idr[t,i]==1&&((DP_rtn[t,i]>Jmp&&DP_mth[t+1,i]>=DPlimit)||(DP_diff[t,i]>diffDPlimit&&DP_mth[t+1,i]<DPlimit))
                RpS=1
            elseif Idr[t,i]==-1&&RpS==1
                RpS=0
            end
            Mrk[t+1,2+i]=RpS
        end
    end
    Mrk[2:end,1:2] = TmVct[1:end-1,:]
    Mrk[1,1:2] = NaN

    return Mrk


end
