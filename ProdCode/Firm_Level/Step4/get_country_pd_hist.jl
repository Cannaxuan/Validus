using JldTools
using ProgressMeter
function get_country_pd_hist(G_CONST::Dict{Any,Any}, countrycode::Int64, PARAM_PATH::String,
                             firmspecific::Array{Float64,3}, firmlist::Array{Float64,2},
                             firmmonth::Array{Float64,3}, INPUT_DATA_PATH::String,
                             OUTPUT_DATA_PATH::String, nhorizon::Int64, fileprefix::String,
                             Jmp::Int64, CALIBRATION_DATE::Int64)

    countrycode = Int(countrycode)
    CALIBRATION_DATE = Int(CALIBRATION_DATE)
    nhorizon = Int(nhorizon)

    countryPARA = get_country_para(G_CONST, countrycode, PARAM_PATH, CALIBRATION_DATE, nhorizon)
    para_def = countryPARA[1]
    para_other = countryPARA[2]
    CountryFromFile = countryPARA[3]
    DateOfFile = countryPARA[4]

    #if countrycode ~= CountryFromFile || DateOfFile ~= CALIBRATION_DATE
    #error("myApp:argChk", "either you are using wrong parameters for the wrong country or your input of calibration date is not consistent with this set of parameters")
    #end


    Ntmp= size(firmspecific)
    nobs = Ntmp[1]
    nfirm = Ntmp[3]

    # PD_all = fill!(Array{Float64}(nobs,3+nhorizon,nfirm),NaN)
    PD_all = fill(NaN, (nobs,3+nhorizon,nfirm))

    PD_all[:,1:3,:] = firmmonth

    for ifirm = 1:nfirm
        data = firmspecific[:,:,ifirm]

        # adjust interest rate units
        data[:, 2, :] = data[:, 2, :] / 100

        PDtmp = Cal_CountryPD_v012(G_CONST, para_def, para_other, data, nhorizon, countrycode)
        PD_all[:, 4:end, ifirm]= PDtmp
    end

    if ~isempty(OUTPUT_DATA_PATH)
        file = string(OUTPUT_DATA_PATH, fileprefix, countrycode, "_", DateOfFile, ".jld")
        JldTools.cri_write_jld(file, "PD_all", PD_all)
    end



    if Jmp > 0
        ## rmixj 20151214
        # Clear PD_all first, then load the same data again. I don"t know
        # whether this trick is for saving memory(). I removed those 2 lines
        # of commands.
        ##
        #         clear PD_all

        Mrk = DP_country_abnml_v011(countrycode, firmlist, Jmp, INPUT_DATA_PATH, OUTPUT_DATA_PATH, CALIBRATION_DATE)

        ToBeMsg0 = convert(Array{Int,2},(Mrk[:,3:end].==1))
        if countrycode==4||countrycode==6||countrycode==15
            ToBeMsg1_1 = kron(ToBeMsg0[1:Int(round(size(ToBeMsg0,1)/3)),:],ones(1,nhorizon))
            ToBeMsg1 = ToBeMsg1_1
            ToBeMsg1_2 = kron(ToBeMsg0[Int(round(size(ToBeMsg0,1)/3))+1:Int(round(size(ToBeMsg0,1)*2/3)),:],ones(1,nhorizon))
            ToBeMsg1 = [ToBeMsg1,ToBeMsg1_2]
            ToBeMsg1_3 = kron(ToBeMsg0[Int(round(size(ToBeMsg0,1)*2/3))+1:end,:],ones(1,nhorizon))
            ToBeMsg1 = [ToBeMsg1,ToBeMsg1_3]
        else
            ToBeMsg1 = kron(ToBeMsg0,ones(1,nhorizon))
        end
        ToBeMsg = cat(zeros(size(ToBeMsg0,1),3,size(ToBeMsg0,2)),
                      reshape(ToBeMsg1,size(ToBeMsg0,1),nhorizon,size(ToBeMsg0,2)), dims = 2)
        ToBeMsg = convert(Array{Bool,2},ToBeMsg)
        PD_all[ToBeMsg] = NaN
    end

    return PD_all,CountryFromFile,DateOfFile
end
