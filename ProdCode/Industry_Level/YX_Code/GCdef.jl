include("highest_indexin.jl")
include("readConfig.jl")
include("RetrieveFieldEnum_v011.jl")
include("RetrieveDwnAccStdrd_v011.jl")
include("global_numer_definition_current.jl")
include("global_constants_extra.jl")
include("split_data.jl")
include("pivot.jl")
include("convert_currency_financial_statement.jl")
include("get_specific_day_value.jl")


function GCdef(dataDate::Int64)
    ####New GC in dictionary###############################################################
    config = nothing
    if VERSION < v"0.7.0"
        if is_windows()
            config = open(string(@__DIR__, "/Config_win.txt"))
        elseif is_unix()
            config = open(string(@__DIR__, "/Config_unix.txt"))
        else
            warn("This program only supports Windows and Unix OS.")
        end
    else
        if Sys.iswindows()
            config = open(string(@__DIR__, "/Config_win.txt"))
        elseif Sys.isunix()
            config = open(string(@__DIR__, "/Config_unix.txt"))
        else
            warn("This program only supports Windows and Unix OS.")
        end
    end



    if !isfile(config)
        error("$config not found! Please refer to Config_example.txt to specify input and output directory.")
    end

    ####################global Constants########################
    PATH_PREFIX_INPUT, PATH_PREFIX_OUTPUT = readConfig(config)
    CODE_PATH = string(@__DIR__,"/./..")
    # println("\n Input path prefix: $PATH_PREFIX_INPUT")
    # println("\n Output path prefix: $PATH_PREFIX_OUTPUT")
    config = nothing

    #    pathForGC = "//dirac/cri3/OfficialTest_AggDTD_SBChinaNA/ProductionCode_JULIA/yCommonCode/"
    #    pathIdx = searchindex(uppercase(pathForGC), "CODE") - 1;
    #    PATH_PREFIX=pathForGC[1:pathIdx[1]];
    if dataDate == NaN
        dataDate = parse(Float64,"20171229")
    end
    dataMth = fld(dataDate,100)
    #create a date array to contain calibration dates for each group
    CaliDateArray=fill(NaN,(300, 1))
    CaliDateArray[2]=20190103;
    CaliDateArray[4]=20190103;
    CaliDateArray[13]=20190103;
    CaliDateArray[14]=20190103;
    CaliDateArray[200]=20190103;
    CaliDateArray[297]=20190103;
    CaliDateOfNS=20190103;
    AGGREGATE_MONTH=Array{Any}(undef, 2)
    AGGREGATE_MONTH[1]=[4 6 9 12 15 21 27]
    AGGREGATE_MONTH[2]=[4 6 9 15 27 39 63]
    AGGREGATE_HEADER=Array{Any}(undef, 2)
    AGGREGATE_HEADER[1]=[1/12 1/4 1/2 3/4 1 3/2 2]
    AGGREGATE_HEADER[2]=[1/12 1/4 1/2 1 2 3 5]
    PARAMETER_SETS=Array{Any}(undef, 2);
    PARAMETER_SETS[1]="";
    PARAMETER_SETS[2]="smc/"
    GC=Dict();
    ###fill in values####
    GC["PATH_PREFIX"]=PATH_PREFIX_INPUT;
    GC["DATE_START"]="1990-01-01";
    GC["STKIDX_DATE_START"]="1988-12-01";
    GC["DATE_START_DATA"]= 19880101;
    GC["DATE_START_PD"]= 19900101;
    GC["Data_Date"]="20171229";
    GC["HistData_Date"]= "20171130";
    GC["CaliDateArray"]=CaliDateArray;
    GC["CaliDateOfNS"]=CaliDateOfNS;
    GC["AGGREGATE_MONTH"]=AGGREGATE_MONTH;
    GC["AGGREGATE_HEADER"]=AGGREGATE_HEADER;
    GC["Para_Date"]=string(maximum(filter(.!isnan,CaliDateArray)));
    GC["All_Para_Date"]=unique(CaliDateArray[isfinite.(CaliDateArray)]);
    GC["UPPER_WIN"]= 99.9;
    GC["LOWER_WIN"]= 0.1;
    GC["UPPER_STK_RET"]= 1;
    GC["LOWER_STK_RET"]= -0.5;
    GC["MVGAVE"]= 12;
    GC["SIGMA_MTHS"]= 12;
    GC["SIGMA_MIN_MTHS"]= 8;
    GC["HISTJOINLENGTH"]= 24;
    GC["LIMIT_GOOD_DATA"]= 5;
    GC["NPARA_BASE"]= 18;
    GC["MAX_HORIZON"]= 60;
    GC["TEXT_FORMAT"]="%12.12f";
    GC["JMP"]= 0.1;
    GC["MAX_ECON"]= 297;
    GC["MAX_DEFAULTS"]= 15;
    GC["MAX_SECTOR_CHANGES"]= 2;
    GC["CODE_INCREMENT_SECTOR"]= 100;
    GC["CODE_INCREMENT_DEFAULT"]= 1000000000;
    GC["Estimation_Method"]= 1;
    GC["MC_BACKFILL_LAGLENGTH"]= 280;
    GC["ACTUAL_LEVEL"]= 0.05;
    GC["HYPO_LEVEL"]= 0.05;
    GC["MODNUM_MA"]= 1000000000;
    GC["TA_BtoA"]= 0.1;
    GC["TA_CHANGE"]= 0.1;
    GC["MA_MI"]= 0;
    GC["MC_CHANGE"]= 0.05;
    GC["dayNumsBefore_or_AfterT0"]= 5;
    GC["dayNumsBefore_or_AfterT0_forMC"]= 20;
    GC["maScreenDailyOrBoth"]= 0;
    GC["FIN_GROUP_NUMBER"]= 20054;
    GC["VAR_NAMES"]=["intercept","index", "3m_rate","dtd_ave","dtd_trnd","liq_ave(nonFin)", "liq_trnd(nonFin)","ni_ave","ni_trnd","size_ave","size_trnd","mb","sigma","liq_ave(Fin)","liq_trnd(Fin)", "agg_dtd_level(Fin)","agg_dtd_level(nonFin)","intercept_dummy(NAMR_Fin)"];
    GC["CVI_MULTIPLIER"]= 10000;
    GC["CVI_ECONS"]= [1 2 6 9 11 15 16 33 37 38 66 81 89 7 8 12 18 5 36 40 46 82 85];
    GC["CVI_ECONS_EUZ"]= [23 25 31 35 36 37 38 40 45 47 55 58 64 70 76 77 79 52 54];
    GC["CVI_TAIL_LEVEL"]= 95;
    GC["CVI_ID_EUZ"]= 300;
    GC["CVI_ID_SPP"]= 200;
    GC["CVI_ZOOM_DAY"]= 1;
    GC["CVI_ZOOM_WEEK"]= 2;
    GC["CVI_ZOOM_MONTH"]= 3;
    GC["CVI_ZOOM_YEAR"]= 4;
    GC["nSample"]= 1000;
    GC["minNumDefFirstUpdate"]= 50;
    GC["SequentialLength"]= 120;
    GC["isBlkProp"]= 1;
    GC["minBlk"]= 5;
    GC["maxBlk"]= 10;
    GC["FracIndependentProp"]= 0.5;
    GC["RandomWalkAdjFac"]= 0.2;
    GC["ESSStopRate"]= 1000 * 0.75;
    GC["MHAccumAcceptRate"]= 1;
    GC["ifApplyKfold"]= 1;
    GC["KfoldAccumAcceptRate"]= 2;
    GC["KfoldDuplication"]= 1;
    GC["useMLEprior"]= false;
    GC["gpuSwitch"]= true;
    GC["isDpositive"]= true;
    GC["dataPutOnGPU"]= false;
    GC["ESSBound"]=1000*0.25;
    GC["propType"]= 1;
    GC["isZeroOn1stNSParam"]= true;
    GC["priorStd"]= 5;
    GC["varLowerBound"]= 1;
    GC["cutoff"]= 100;
    GC["startNum"]= 20;
    GC["endNum"]= 3;
    GC["numSpeicialMoveBefRecur"]= 100;
    GC["numNormalMoveBefRecur"]= 20;
    GC["stepSize"]= 1;
    GC["startT"]= 1;
    GC["numRunWithRandomInitials"]= 60;
    GC["t90"]= 5.374;
    GC["t95"]= 6.811;
    GC["stdFactor"]= 1.3;
    GC["MAXTRYTIMES"]= 100;
    GC["DISPLAYACCEPT"]= true;
    GC["HORIZON_PRODUCE"]=[24 60];
    GC["HORIZON_histDailyPD"]= [1 3 6 12 24 36 60];
    GC["PARAMETER_IN_USE"]=[2];
    GC["PARAMETER_SETS"]=PARAMETER_SETS;
    #API write step setting
    DTD_APIstep=Array{Int}(undef, 4,1)
    DTD_APIstep[1]=2;
    DTD_APIstep[2]=3;
    DTD_APIstep[3]=4;
    DTD_APIstep[4]=5;
    PDcali_APIstep=Array{Int}(undef, 3,1)
    PDcali_APIstep[1]=6;
    PDcali_APIstep[2]=7;
    PDcali_APIstep[3]=8;
    NS_APIstep=Array{Int}(undef, 1,1)
    NS_APIstep[1]=9
    MAFS_APIstep=Array{Int}(undef, 3,1)
    MAFS_APIstep[1]=10;
    MAFS_APIstep[2]=11;
    MAFS_APIstep[3]=12;
    MADTD_APIstep=Array{Int}(undef, 4,1)
    MADTD_APIstep[1]=13
    MADTD_APIstep[2]=14
    MADTD_APIstep[3]=15
    MADTD_APIstep[4]=16
    PDcal_APIstep=Array{Int}(undef, 4,1)
    PDcal_APIstep[1]=17
    PDcal_APIstep[2]=18
    PDcal_APIstep[3]=19
    GC["DTD_APIstep"]=DTD_APIstep;
    GC["PDcali_APIstep"]=PDcali_APIstep;
    GC["NS_APIstep"]=NS_APIstep;
    GC["MAFS_APIstep"]=MAFS_APIstep;
    GC["MADTD_APIstep"]=MADTD_APIstep;
    GC["PDcal_APIstep"]=PDcal_APIstep;

    ##original data prepared by DMT
    OriginalData_varcol=Dict();
    OriginalData_varcol["Company_Number"]=1;
    OriginalData_varcol["Mapping_Number"]=1;
    OriginalData_varcol["Time"]=2;
    OriginalData_varcol["Event_Type"]=3;
    OriginalData_varcol["TMR"]=4;
    OriginalData_varcol["Stock_Index_Return"]=5
    OriginalData_varcol["DTD"]=6;
    OriginalData_varcol["NITA"]=7
    OriginalData_varcol["BS_TOT_ASSET"]=8
    OriginalData_varcol["BS_TOT_LIAB2"]=9;
    OriginalData_varcol["BS_CASH_NEAR_CASH_ITEM"]=10;
    OriginalData_varcol["BS_MKT_SEC_OTHER_ST_INVEST"]=11;
    OriginalData_varcol["Marketcap_Clean"]=12;
    OriginalData_varcol["Stock_Index"]=13;
    OriginalData_varcol["Marketcap"]=14;
    GC["OriginalData_varcol"]=OriginalData_varcol;
    #original data after add current asset
    # OriginalDataDaily_<ECON>,PMTV1
    pmt_OriginalData_varcol=deepcopy(OriginalData_varcol);
    pmt_OriginalData_varcol["BS_CUR_ASSET_REPORT"]=15;
    pmt_OriginalData_varcol["BS_CUR_LIAB"]=16;
    GC["pmt_OriginalData_varcol"]=pmt_OriginalData_varcol;
    #current asset from DMT
    CurrentAsset_varcol=Dict();
    CurrentAsset_varcol["Company_Number"]=1;
    CurrentAsset_varcol["Mapping_Number"]=1;
    CurrentAsset_varcol["Time"]=2;
    CurrentAsset_varcol["Event_Type"]=3;
    CurrentAsset_varcol["TMR"]=4;
    CurrentAsset_varcol["Stock_Index_Return"]=5
    CurrentAsset_varcol["DTD"]=6;
    CurrentAsset_varcol["BS_CUR_ASSET_REPORT"]=7;
    CurrentAsset_varcol["BS_CUR_LIAB"]=8;
    GC["CurrentAsset_varcol"]=CurrentAsset_varcol;
    #####BELOW ARE VARCOL NAMES FOR CALI PD####
    #firm history from DMT
    FirmHistory_varcol=Dict();
    FirmHistory_varcol["Company_Number"]=1;
    FirmHistory_varcol["Time_Begin"]=2;
    FirmHistory_varcol["Time_Exit"]=3;
    FirmHistory_varcol["Time_End"]=4;
    FirmHistory_varcol["Event_Type"]=5;
    FirmHistory_varcol["Event_Code"]=6;
    FirmHistory_varcol["Exit_Code"]=7;
    FirmHistory_varcol["Country_Exchange"]=8
    FirmHistory_varcol["Country_Domicle"]=9;
    FirmHistory_varcol["Number_Sector"]=10;
    FirmHistory_varcol["Number_Group"]=11;
    FirmHistory_varcol["Number_SubGroup"]=12;
    FirmHistory_varcol["Mapping_Number"]=1;
    FirmHistory_varcol["Status"]=5;
    GC["FirmHistory_varcol"]=FirmHistory_varcol;
    #trasnformation fs bef level and trend:
    # firmSpecific_beforeDemean_<ECON>, PMTV2
    # firmSpecific_afterDemean_beforeNormalize_<ECON>, PMTV3
    # firmSpecific_afterNormalize_beforeAverDiff_<ECON>, PMTV4
    # firmSpecific_afterDemean_beforeAggDTD_<ECON>, PMTV5
    fs_transform_varcol=Dict();
    fs_transform_varcol["Comp_Mapped_Number"]=1;
    fs_transform_varcol["YYYY"]=2;
    fs_transform_varcol["MM"]=3;
    fs_transform_varcol["Three_Month_Rate"]=4;
    fs_transform_varcol["Three_Month_Rate_After_Demean"]=4;
    fs_transform_varcol["Stock_Index_Return"]=5;
    fs_transform_varcol["DTD"]=6;
    fs_transform_varcol["NI_Over_TA"]=7;
    fs_transform_varcol["Total_Asset"]=8;
    fs_transform_varcol["M_Over_B"]=8;
    fs_transform_varcol["Total_Liability"]=9;
    fs_transform_varcol["CA_Over_CL"]=9;
    fs_transform_varcol["Cash"]=10;
    fs_transform_varcol["Size"]=10;
    fs_transform_varcol["Mktable_Securities"]=11;
    fs_transform_varcol["SIGMA"]=11;
    fs_transform_varcol["Market_Cap"]=12;
    fs_transform_varcol["Cash_Over_TA"]=12;
    fs_transform_varcol["Stock_Index"]=13;
    fs_transform_varcol["Aggregate_DTD_Fin"]=13;
    fs_transform_varcol["Current_Asset"]=14;
    fs_transform_varcol["Aggregate_DTD_NonFin"]=14;
    fs_transform_varcol["Current_Liability"]=15;
    GC["fs_transform_varcol"]=fs_transform_varcol;
    ##trasnformation fs aft level and trend
    # firmSpecific_final_<ECON> PMTV6
    fs_final_varcol=Dict();
    fs_final_varcol["Comp_Mapped_Number"]=1;
    fs_final_varcol["YYYY"]=2;
    fs_final_varcol["MM"]=3;
    fs_final_varcol["Stock_Index_Return"]=4
    fs_final_varcol["Three_Month_Rate_After_Demean"]=5;
    fs_final_varcol["DTD_Level"]=6;
    fs_final_varcol["DTD_Trend"]=7;
    fs_final_varcol["CA_Over_CL_Level"]=8;
    fs_final_varcol["CA_Over_CL_Trend"]=9
    fs_final_varcol["NI_Over_TA_Level"]=10
    fs_final_varcol["NI_Over_TA_Trend"]=11
    fs_final_varcol["Size_Level"]=12
    fs_final_varcol["Size_Trend"]=13
    fs_final_varcol["M_Over_B"]=14
    fs_final_varcol["SIGMA"]=15
    fs_final_varcol["Cash_Over_TA_Level"]=16
    fs_final_varcol["Cash_Over_TA_Trend"]=17
    fs_final_varcol["Aggregate_DTD_Fin"]=18
    fs_final_varcol["Aggregate_DTD_NonFin"]=19;
    GC["fs_final_varcol"]=fs_final_varcol;

    #####BELOW ARE VARCOL NAMES FOR HIST PD####
    hist_initial_varcol=Dict();
    hist_initial_varcol["Comp_Mapped_Number"]=1;
    hist_initial_varcol["YYYYMMDD"]=2;
    hist_initial_varcol["Stock_Index_Return"]=3;
    hist_initial_varcol["Three_Month_Rate_After_Demean"]=4;
    hist_initial_varcol["DTD"]=5;
    hist_initial_varcol["NI_Over_TA"]=6;
    hist_initial_varcol["TA"]=7;
    hist_initial_varcol["TL"]=8;
    hist_initial_varcol["Cash"]=9;
    hist_initial_varcol["Mrktable_Securities"]=10;
    hist_initial_varcol["Marketcap_Clean"]=11;
    hist_initial_varcol["Stock_Index"]=12;
    hist_initial_varcol["Marketcap"]=13;
    hist_initial_varcol["Current_Asset"]=14;
    hist_initial_varcol["Current_Liability"]=15;
    hist_initial_varcol["DTD_Median_Fin"]=16;
    hist_initial_varcol["DTD_Median_NonFin"]=17;
    GC["hist_initial_varcol"]=hist_initial_varcol;
    ##########hist fs after normalize###########
    hist_aftnormalize_varcol=Dict();
    hist_aftnormalize_varcol["Comp_Mapped_Number"]=1
    hist_aftnormalize_varcol["YYYYMMDD"]=2
    hist_aftnormalize_varcol["Stock_Index_Return"]=3
    hist_aftnormalize_varcol["Three_Month_Rate_After_Demean"]=4
    hist_aftnormalize_varcol["DTD"]=5
    hist_aftnormalize_varcol["NI_Over_TA"]=6
    hist_aftnormalize_varcol["M_Over_B"]=7
    hist_aftnormalize_varcol["CA_Over_CL"]=8
    hist_aftnormalize_varcol["Size"]=9
    hist_aftnormalize_varcol["Sigma"]=10
    hist_aftnormalize_varcol["Cash_Over_TA"]=11
    hist_aftnormalize_varcol["DTD_Median_Fin"]=12
    hist_aftnormalize_varcol["DTD_Median_NonFin"]=13
    GC["hist_aftnormalize_varcol"]=hist_aftnormalize_varcol;
    #########hist fs final#####################
    hist_finalFS_varcol=Dict();
    hist_finalFS_varcol["Comp_Mapped_Number"]=1
    hist_finalFS_varcol["YYYYMMDD"]=2
    hist_finalFS_varcol["Stock_Index_Return"]=3
    hist_finalFS_varcol["Three_Month_Rate_After_Demean"]=4
    hist_finalFS_varcol["DTD_Level"]=5
    hist_finalFS_varcol["DTD_Trend"]=6
    hist_finalFS_varcol["CA_Over_CL_Level"]=7
    hist_finalFS_varcol["CA_Over_CL_Trend"]=8
    hist_finalFS_varcol["NI_Over_TA_Level"]=9
    hist_finalFS_varcol["NI_Over_TA_Trend"]=10
    hist_finalFS_varcol["Size_Level"]=11
    hist_finalFS_varcol["Size_Trend"]=12
    hist_finalFS_varcol["M_Over_B"]=13
    hist_finalFS_varcol["Sigma"]=14
    hist_finalFS_varcol["Cash_Over_TA_Level"]=15
    hist_finalFS_varcol["Cash_Over_TA_Trend"]=16
    hist_finalFS_varcol["DTD_Median_Fin"]=17
    hist_finalFS_varcol["DTD_Median_NonFin"]=18
    hist_finalFS_varcol["Dummy_For_Group_297_Finance"]=19
    GC["hist_finalFS_varcol"]=hist_finalFS_varcol;
    ##################################################
    ###################global econs define###############################
    ADJUST_RFR_COUNTRY=[23 25 31 35 36 37 45 47 55 58 64 70 76 77 79 40 52 54]
    NO_OTC_ECONS=collect(15:16)';
    ECONNAMES=Array{Any}(undef, 297,1)
    ECONNAMES[1]="Australia";
    ECONNAMES[2]="China"
    ECONNAMES[3]="Hong Kong"
    ECONNAMES[4]="India"
    ECONNAMES[5]="Indonesia"
    ECONNAMES[6]="Japan"
    ECONNAMES[7]="Malaysia"
    ECONNAMES[8]="Philippines"
    ECONNAMES[9]="Singapore"
    ECONNAMES[10]="South Korea"
    ECONNAMES[11]="Taiwan"
    ECONNAMES[12]="Thailand"
    ECONNAMES[15]="US"
    ECONNAMES[16]="Canada"
    ECONNAMES[17]="New Zealand"
    ECONNAMES[18]="Vietnam"
    ECONNAMES[19]="Sri Lanka"
    ECONNAMES[20]="Pakistan"

    ECONNAMES[22]="Bangladesh"
    ECONNAMES[67]="Oman"
    ECONNAMES[100]="Jamaica"

    # Add by rmiwayu for new country:
    ECONNAMES[26]="Bosnia and Herzegovina"
    ECONNAMES[75]="Serbia"
    ECONNAMES[60]="Montenegro"
    ECONNAMES[84]="Tunisia"

    ECONNAMES[23]="Austria"
    ECONNAMES[24]="Bahrain"
    ECONNAMES[25]="Belgium"
    ECONNAMES[29]="Bulgaria"
    ECONNAMES[30]="Croatia"
    ECONNAMES[31]="Cyprus"
    ECONNAMES[32]="Czech Republic"
    ECONNAMES[33]="Denmark"
    ECONNAMES[34]="Egypt"
    ECONNAMES[35]="Estonia"
    ECONNAMES[36]="Finland"
    ECONNAMES[37]="France"
    ECONNAMES[38]="Germany"
    ECONNAMES[40]="Greece"
    ECONNAMES[42]="Hungary"
    ECONNAMES[43]="Iceland"
    ECONNAMES[46]="Israel"
    ECONNAMES[45]="Ireland"
    ECONNAMES[47]="Italy"
    ECONNAMES[48]="Jordan"
    ECONNAMES[49]="Kazakhstan"
    ECONNAMES[51]="Kuwait"
    ECONNAMES[52]="Latvia"
    ECONNAMES[54]="Lithuania"
    ECONNAMES[55]="Luxembourg"
    ECONNAMES[56]="Macedonia"
    ECONNAMES[58]="Malta"
    ECONNAMES[59]="Mauritius"
    ECONNAMES[61]="Morocco"
    ECONNAMES[64]="Netherlands"
    ECONNAMES[65]="Nigeria"
    ECONNAMES[66]="Norway"
    ECONNAMES[69]="Poland"
    ECONNAMES[70]="Portugal"
    ECONNAMES[71]="Qatar"
    ECONNAMES[72]="Romania"
    ECONNAMES[73]="Russian Federation"
    ECONNAMES[74]="Saudi Arabia"
    ECONNAMES[76]="Slovakia"
    ECONNAMES[77]="Slovenia"
    ECONNAMES[78]="South Africa"
    ECONNAMES[79]="Spain"
    ECONNAMES[81]="Sweden"
    ECONNAMES[82]="Switzerland"
    ECONNAMES[85]="Turkey"
    ECONNAMES[87]="Ukraine"
    ECONNAMES[88]="United Arab Emirates"
    ECONNAMES[89]="UK"

    ECONNAMES[92]="Argentina"
    ECONNAMES[95]="Brazil"
    ECONNAMES[96]="Colombia"
    ECONNAMES[97]="Chile"
    ECONNAMES[102]="Mexico"
    ECONNAMES[103]="Peru"
    ECONNAMES[107]="Venezuela"
    # added by rmiyany on 20171009
    ECONNAMES[27]="Botswana"
    ECONNAMES[39]="Ghana"
    ECONNAMES[50]="Kenya"
    ECONNAMES[57]="Malawi"
    ECONNAMES[63]="Namibia"
    ECONNAMES[163]="Rwanda"
    ECONNAMES[83]="Tanzania"
    ECONNAMES[86]="Uganda"
    # # # # # # # # # # # # # # # # # # #
    # Three month rates for each economy #
    # # # # # # # # # # # # # # # # # # #
    TMR_VAR=[];TMR_SOURCE=[];TMR_KEYDATE=[];TMR_ADJDATE=[];
    #1 AUSTRALIA DEALER BILL 90 DAY	ADBR090
    push!(TMR_VAR,28);
    push!(TMR_SOURCE,"DS");
    push!(TMR_KEYDATE,0);
    push!(TMR_ADJDATE,0);

    #2 CHINA TIME DEPOSIT RATE, 3M	CHSRW3M
    push!( TMR_VAR,154);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #3 HONG KONG EXCHANGE FUND BILL 3 MTH	HKEFB3M
    push!( TMR_VAR,310);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #4 INDIA  TREASURY BILL 3 MONTH  INDTB3M //INDIA T-BILL SECONDARY 91 DAY	INTB91D
    push!( TMR_VAR,[1078 367]);
    push!( TMR_SOURCE,["DS" "DS"]);
    push!( TMR_KEYDATE,[20130520 0]);
    push!( TMR_ADJDATE,0);  #newly revised on 2014-11-07



    # Added in 1/30/2016, change from IDSB90. to  IDIBK3M and the change date is also from 20030710
    #5 Reuters Indonesian 3M interbank rate   IDIBK3M  // INDONESIA SBI/DISC 90 DAY"DEAD"  IDSBI90
    push!( TMR_VAR,[1091 386]);
    push!( TMR_SOURCE,["DS" "DS"]);
    push!( TMR_KEYDATE,[20130710 0]);
    push!( TMR_ADJDATE,0);

    #6 Japan Treasury Discount Bills 3 Month	GJTB3MO Index
    push!( TMR_VAR,[307 1]);
    push!( TMR_SOURCE,["BBG" "OT"]);
    push!( TMR_KEYDATE,[19920710 0]);
    push!( TMR_ADJDATE,0);

    #7 MALAYSIA DEPOSIT 3 MONTH	MYDEP3M
    push!( TMR_VAR,555);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #8 PHILIPPINE TREASURY BILL 91D	PHTBL3M
    push!( TMR_VAR,620);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #9 MONETARY AUTHORITY OF SINGAPORE BENCHMARK GOVT BILL YIELD 3 MONTH	MASB3M Index // SINGAPORE T-BILL 3 MONTH SNGTB3M
    push!( TMR_VAR,[353 731]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[20130920 0]);
    push!( TMR_ADJDATE,0);

    #10 KOREA COMMERCIAL PAPER 91D	KOCP91D
    push!( TMR_VAR,535);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #11 TAIWAN MONEY MARKET 90 DAY	TAMM90D
    push!( TMR_VAR,775);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #12 THAILAND BILOR FIXINGS 3 MONTH BOFX3M Index // THAILAND REPO 3 MTH (BOT)"DEAD"	THBTRP3
    push!( TMR_VAR,[856 879]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[20020530 0]);
    push!( TMR_ADJDATE,0);

    #13&14
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);

    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);

    #15 US Generic Govt 3 Month Yield	USGG3M Index
    push!( TMR_VAR,402);
    push!( TMR_SOURCE,"BBG");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #16 CANADA TREASURY BILL 3 MONTH	CNTBL3M
    push!( TMR_VAR,931);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #17 New Zealand Dollar Deposit 3 Month   GSNZD3M
    push!( TMR_VAR,1053);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #18 VIETNAM INTERBANK 3 MONTH           VNIBK3M
    push!( TMR_VAR,1052);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #19 SRI Lanka Treasury Bill 3 Month        SRTBL3M
    push!( TMR_VAR,1069);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #20 PKR 3 Month Repo         PRRPC Index
    push!( TMR_VAR,[1560 1468]);
    push!( TMR_SOURCE,["DS" "BBG"]);
    push!( TMR_KEYDATE,[20020102 0]);
    push!( TMR_ADJDATE,0);

    #21
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);

    #22 Bangladesh 3 Month Bill Auction Cut Off Yield        BDTB91AY Index
    push!( TMR_VAR,1486);
    push!( TMR_SOURCE,"BBG");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #23 AUSTRIA VIBOR 3 MONTH                 ASVIB3M
    push!( TMR_VAR,[1232 958]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[19990101, 0]);
    push!( TMR_ADJDATE,[19990101, 0]);

    #24 Bahrain Ibor 3 Month             BHIBK3M
    push!( TMR_VAR,1062);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #25 BELGIUM TREASURY BILL 3 MONTH         BGTBL3M
    push!( TMR_VAR,[1232 960]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[19990101, 0]);
    push!( TMR_ADJDATE,[19990101, 0]);

    #26 BP INTEREST RATES: LENDING RATE NADJ     BPI60P..
    push!( TMR_VAR,1079);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #27 Botswana, Treasury Bills, Nominal Yield, 3 Month, Average
    push!( TMR_VAR,1099);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);
    #28
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);

    #29 BULGARIA INTERBANK 3 MONTH         BLIBK3M
    push!( TMR_VAR,1042);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #30 Croatia Zibor Rate 3 Month         CTZIB3M
    push!( TMR_VAR,1056);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #31 Cyprus, TREASURY BILL RATE - 13 WEEK         CPGBILL3
    push!( TMR_VAR,[1232 1050]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[20080101, 0]);
    push!( TMR_ADJDATE,[20080101, 0]);

    #32 CZECH REPUBLIC INTERBANK 3 MTH         PRIBK3M
    push!( TMR_VAR,1024);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #33 DENMARK INTERBANK 3 MONTH             CIBOR3M
    push!( TMR_VAR,962);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #34 EGYPT 91 DAY T-BILL      EYTBL3M
    push!( TMR_VAR,1017);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #35 Estonia, Interest Rates, Prices, Production, & Labour, Interest Rates, DEPOSIT RATE         EOI60L..
    push!( TMR_VAR,[1232 1048]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[20110101, 0]);
    push!( TMR_ADJDATE,[20110101, 0]);

    #36 FINLAND INTERBANK CLOSE 3 MONTH       FNIBC3M
    push!( TMR_VAR,[1232 964]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[19990101, 0]);
    push!( TMR_ADJDATE,[19990101, 0]);

    #37 France Treasury Bills 3 Month Intraday        GBTF3MO Index
    push!( TMR_VAR,[1232 1234]);
    push!( TMR_SOURCE,["BBG" "BBG"]);
    push!( TMR_KEYDATE,[19990101, 0]);
    push!( TMR_ADJDATE,[19990101, 0]);

    #38 Germany 3 Month Bubill Maturing in 3 Month    GETB1 Index // GERMANY INTERBANK 3 MONTH FIBOR3M
    push!( TMR_VAR,[1232 966]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[19990101, 0]);
    push!( TMR_ADJDATE,[19990101, 0]);

    #39
    push!( TMR_VAR,1523);
    push!( TMR_SOURCE,"BBG");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #40 GREECE TREASURY BILL 3 MONTH          GDTBL3M
    push!( TMR_VAR,[1232 968]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[20010101, 0]);
    push!( TMR_ADJDATE,[20010101, 0]);
    #41
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);

    #42 HUNGARY INTERBANK 3 MONTH          HNIBK3M
    push!( TMR_VAR,1030);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #43 ICELAND INTERBANK 3 - MONTH      ICIBK3M// ICELAND 90- DAY CB NOTES IC90CBN
    push!( TMR_VAR,[943 948]);
    push!( TMR_SOURCE,["DS" "DS"]);
    push!( TMR_KEYDATE,[19980804, 0]);
    push!( TMR_ADJDATE,0);

    #44
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);

    #45 IRELAND INTERBANK 3 MONTH             EIRED3M
    push!( TMR_VAR,[1232 970]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[19990101, 0]);
    push!( TMR_ADJDATE,[19990101, 0]);

    #46 ISRAEL T-BILL SECONDARY 3 MNTH        IS3MTBL
    push!( TMR_VAR,1012);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #47 Italy Bots Treasury Bill 3 Month Intraday Gross Yields    GBOTG3M Index // ITALY T-BILL AUCT GROSS 3 MONTH ITBT03G
    push!( TMR_VAR,[1232 1237 988]);
    push!( TMR_SOURCE,["BBG"  "BBG" "DS"]);
    push!( TMR_KEYDATE,[19990101 19940905 0]);
    push!( TMR_ADJDATE,[19990101, 0,0]);



    #48 Jordanian Dinar Interbank Offered Rate 3 Months        JDIBOR3M Index
    push!( TMR_VAR,1507);
    push!( TMR_SOURCE,"BBG");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);


    #49 Kazakhstan KIBOR/KIBID 90 Days Interbank    KZDR90D Index
    push!( TMR_VAR,1455);
    push!( TMR_SOURCE,"BBG");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #50
    push!( TMR_VAR,1092);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #51 KUWAIT INTERBANK 3 MONTH   KWIBK3M
    push!( TMR_VAR,1007);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #52 TREASURY BILL RATE 3 MONTH	LVTBL3M
    push!( TMR_VAR,[1232 1033]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[20140101, 0]);
    push!( TMR_ADJDATE,[20140101, 0]);
    #53
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);

    #54 VILNIUS INTERBANK THREE MONTH	LNIBK3M
    push!( TMR_VAR,[1232 1057]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[20150101, 0]);
    push!( TMR_ADJDATE,[20150101, 0]);

    #55 LONG TERM GOVERNMENT BOND YIELDS - MAASTRICHT DEFINITION (AVG.)             LXESEFIGR
    push!( TMR_VAR,[1232 1044]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[19990101, 0]);
    push!( TMR_ADJDATE,[19990101, 0]);

    #56 Macedonia Skibor 3 Months          MKSKI3M
    push!( TMR_VAR,1076);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #57
    push!( TMR_VAR,1524);
    push!( TMR_SOURCE,"BBG");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #58 LONG TERM GOVERNMENT BOND YIELDS - MAASTRICHT DEFINITION (AVG.)  LXESEFIGR
    push!( TMR_VAR,[1232 1044]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[20080101, 0]);
    push!( TMR_ADJDATE,[20080101, 0]);

    #59 TR MAURITIUS GVT BMK BID YLD 1Y
    push!( TMR_VAR,1095);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #60 TREASURY BILL RATE - 91 -DAY(EP)         MNTB91D
    push!( TMR_VAR,1060);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #61 Morocco Deposit Rate 3 Month            MCDEP3M
    push!( TMR_VAR,1073);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #62
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);
    #63
    push!( TMR_VAR,1100);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #64 Netherlands Interbank 3 Month  HOLIB3M
    push!( TMR_VAR,[1232 1084]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[19990101, 0]);
    push!( TMR_ADJDATE,[19990101, 0]);

    #65 Nigeria Interbank Offered Rate 3 Month         NRBO3M Index
    push!( TMR_VAR,1467);
    push!( TMR_SOURCE,"BBG");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #66 Norway Govt Treasury Bills 3 Month   GNGT3M Index//NORWAY INTERBANK 3MTH(EFFECTIVE) NWIBE3M
    push!( TMR_VAR,[1147 974]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[19950627, 0]);
    push!( TMR_ADJDATE,0);

    #67 OMR 3 Month Deposit ORDRC Index
    push!( TMR_VAR,1488);
    push!( TMR_SOURCE,"BBG");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #68
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);

    #69 POLAND INTERBANK 3 MONTH (EOD)	POIBK3M
    push!( TMR_VAR,1008);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #70 PORTUGAL LISBOR 3 MONTH               LISBO3M
    push!( TMR_VAR,[1232 5]);
    push!( TMR_SOURCE,["BBG" "OT"]);
    push!( TMR_KEYDATE,[19990101, 0]);
    push!( TMR_ADJDATE,[19990101,0]);

    #71 Qatar Qatar 3 Month T-Bill Auction Average Yield  QTBL3Y Index
    push!( TMR_VAR,1557);
    push!( TMR_SOURCE,"BBG");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #72 ROMANIAN INTERBANK 3 MONTH	RMIBK3M
    push!( TMR_VAR,1022);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #73 MosPime 3 Months Rate    MOSKP3 INDEX // RUSSIA MOSCOW INTERBANK NON CO     MOIB31/9 INDEX // RUSSIAN INTERBANK 31 TO 90 DAY    RSIBK90
    push!( TMR_VAR,[1483 1443 1005]);
    push!( TMR_SOURCE,["BBG" "BBG" "DS"]);
    push!( TMR_KEYDATE,[20050418 20000814 0]);
    push!( TMR_ADJDATE,0);

    #74 Saudi Interbank 3 Month     SAIBK3M
    push!( TMR_VAR,1067);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #75 National Bank of Serbia BELIBOR 3M Rate (Interbank rate)      BELI3M Index
    push!( TMR_VAR,1500);
    push!( TMR_SOURCE,"BBG");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #76 SLOVAK REP. INTERBANK 3 MTH             SXIBK3M
    push!( TMR_VAR,[1232 1037]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[20090101, 0]);
    push!( TMR_ADJDATE,[20090101,0]);

    #77 SLOVENIA TREASURY BILL 3 MONTH"DEAD"    SJTBL3M
    push!( TMR_VAR,[1232 1019]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[20070101,0]);
    push!( TMR_ADJDATE,[20070101,0]);

    #78 SOUTH AFRICA T-BILL 91 DAYS (TENDER RATES)          SATBL3M
    push!( TMR_VAR,1013);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #79 Spain 3 Month Treasury Bill Yield       GSGLT3MO Index// SPAIN INTERBANK 3 MONTH   ESMIB3M
    push!( TMR_VAR,[1232 1243 980]);
    push!( TMR_SOURCE,["BBG" "BBG" "DS"]);
    push!( TMR_KEYDATE,[19990101, 19921130, 0]);
    push!( TMR_ADJDATE,[19990101, 19921130, 0]);

    #80
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);

    #81 Sweden T Bill 3 Month       GSGT3M Index  // SWEDEN TREASURY BILL 90 DAY   SDTB90D
    push!( TMR_VAR,[1145 982]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[19930525, 0]);
    push!( TMR_ADJDATE,0);

    #82 SWISS INTERBANK 3M (ZRC:SNB)          SWIBK3M
    push!( TMR_VAR,990);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #83
    push!( TMR_VAR,1527);
    push!( TMR_SOURCE,"BBG");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #84 Tunisia TU POLICY RATES: TMM (AVG.)     TUMSHORT
    push!( TMR_VAR,1081);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #85 TURKISH INTERBANK 3 MONTH	TKIBK3M
    push!( TMR_VAR,1040);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #86
    push!( TMR_VAR,1528);
    push!( TMR_SOURCE,"BBG");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #87 UKRAINE INTERBANK 3 MONTHS	UAHIB3M
    push!( TMR_VAR,1015);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #88 UAE Ibor 3 Month   	AEIBK3M
    push!( TMR_VAR,1071);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #89 UK TREASURY BILL TENDER 3M            UKTBTND
    push!( TMR_VAR,935);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #90
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);
    #91
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);

    #92 ARGENTINA DEPOSIT 90 DAY (PA.)            AG90DPP
    push!( TMR_VAR,1001);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #93
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);
    #94
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);

    #95 ANDIMA BRAZIL GOVT BOND FIXED RATE 3 MONTHS     BZAD3M INDEX  // BRAZIL CDB (UP TO 30 DAYS) BRCDBIR
    push!( TMR_VAR,[1395 995]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[20000403, 0]);
    push!( TMR_ADJDATE,0);

    #96 COLOMBIA CD RATE 90-DAY            CB90CDR
    push!( TMR_VAR,1002);
    push!( TMR_SOURCE,"DS");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    #97 Chile TAB UF Interbank Rate 90 Days  PCRR90D Index
    push!( TMR_VAR,[1558 1402]);
    push!( TMR_SOURCE,["DS" "BBG"]);
    push!( TMR_KEYDATE,[19950529 0]);
    push!( TMR_ADJDATE,[19950529 0]);
    #98
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);
    #99
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);


    #100 Jamaica  3 Months repo rate  JARGCGC Currency
    push!( TMR_VAR,[1484 1496]);
    push!( TMR_SOURCE,["BBG" "BBG"]);
    push!( TMR_KEYDATE,[20101130 0]);
    push!( TMR_ADJDATE,[20101130 0]);

    #101
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);

    #102 MEXICO CETES 2ND MKT. 90 DAY    MXCSM90 // MEXICO CETES 91 DAY AVG.RET.AT AUC.	MXCTA91
    push!( TMR_VAR,[999 997]);
    push!( TMR_SOURCE,["DS" "DS"]);
    push!( TMR_KEYDATE,[19960626 0]);
    push!( TMR_ADJDATE,0);

    #103 PERU SAVINGS RATE            PSTAMNN
    push!( TMR_VAR,[1570 1000]);
    push!( TMR_SOURCE,["BBG" "DS"]);
    push!( TMR_KEYDATE,[20020930 0]);
    push!( TMR_ADJDATE,[20020930 0]);

    #104
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);
    #105
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);
    #106
    push!( TMR_VAR,NaN);
    push!( TMR_SOURCE,NaN);
    push!( TMR_KEYDATE,NaN);
    push!( TMR_ADJDATE,NaN);

    #107
    # Venezuela 90 Day Deposit Rate  VEDP90D// VENEZUELA OVERNIGHT   VENOVER
    push!( TMR_VAR,[1088 996]);
    push!( TMR_SOURCE,["DS" "DS"]);
    push!( TMR_KEYDATE,[19970110 0]);
    push!( TMR_ADJDATE,0);


    for i=108:162
        push!( TMR_VAR,NaN);
        push!( TMR_SOURCE,NaN);
        push!( TMR_KEYDATE,NaN);
        push!( TMR_ADJDATE,NaN);
    end

    #163
    push!( TMR_VAR,1525);
    push!( TMR_SOURCE,"BBG");
    push!( TMR_KEYDATE,0);
    push!( TMR_ADJDATE,0);

    GC["TMR_VAR"]=TMR_VAR;
    GC["TMR_SOURCE"]=TMR_SOURCE;
    GC["TMR_KEYDATE"]=TMR_KEYDATE
    GC["TMR_ADJDATE"]=TMR_ADJDATE;
    GC["ADJUST_RFR_COUNTRY"]=ADJUST_RFR_COUNTRY;
    GC["NO_OTC_ECONS"]=NO_OTC_ECONS
    GC["ECONNAMES"]=ECONNAMES;

    ########################################################################
    ########################global path define############################
    ##.DMT
    GC["FIRM_HISTORY_PATH"]=string(PATH_PREFIX_INPUT, "Data/ModelCalibration/", dataMth, "/IDMTData/SmartData/FirmHistory/");
    GC["CLEAN_DATA_PATH"]=string(PATH_PREFIX_INPUT, "Data/ModelCalibration/" ,dataMth, "/IDMTData/CleanData/");
    GC["DTDINPUT_CALCULATION_BEFORE_MA_PATH"]=string(PATH_PREFIX_INPUT, "Data/ModelCalibration/" ,dataMth, "/IDMTData/SmartData/DTDCalculation/Input/Before_MA/");
    GC["IMPORTANT_MA_TABLE_PATH"]=string(PATH_PREFIX_INPUT, "Data/ModelCalibration/" ,dataMth, "/IDMTData/CleanData/GlobalInformation/Temp_MA/");
    GC["DTDINPUT_WHOLE_CALIBRATION_PATH"]=string(PATH_PREFIX_INPUT, "Data/ModelCalibration/" ,dataMth, "/IDMTData/SmartData/DTDCalibration/Input/Input_In_Whole/");
    GC["CALI_ORIGINAL_PATH_IDMT"]=string(PATH_PREFIX_INPUT, "Data/ModelCalibration/" ,dataMth, "/IDMTData/SmartData/PDCalibration/Input/OriginalData/");
    GC["HIST_DAILY_ORIGINAL_BEFORE_MA_PATH"]=string(PATH_PREFIX_INPUT, "Data/Historical/" ,dataMth, "/Daily/IDMTData/SmartData/PDCalculation/Input/OriginalData/Before_MA/");

    #PATH_PREFIX = "D:/Local_Julia_test_0642/Production"
    #.PMT CODE file
    GC["GENERATE_HYPO_INPUT_CODE_PATH"]=string(CODE_PATH, "/generateHypoInput");
    GC["NSparaDefForSB"]=string(CODE_PATH, "/yCommonCode/Group");
    GC["CALI_CODE_PATH"]=string(CODE_PATH, "/bCalibration/");
    GC["PYTHON_AS_UPLOADER"]=string(CODE_PATH,"/dDaily/websiteDailyUpdate/uploaderForCdsCalculator/");
    #### Please do modify the following path if launch or test!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    #PMT_DTDforPDCALI = string(PATH_PREFIX, "Data_JULIATEST/");
    #PMT_PDCALI = string(PATH_PREFIX, "Data_JULIATEST/");
    #PMT_PDCALU = string(PATH_PREFIX, "Data_JULIATEST/");
    #PMT_PDIR = string(PATH_PREFIX, "Data_JULIATEST/");
    #PMT_AS = string(PATH_PREFIX, "Data_JULIATEST/");
    #PMT_CVI = string(PATH_PREFIX, "Data_JULIATEST/");
    #PMT_DAILY = string(PATH_PREFIX, "Data_JULIATEST/");

    #.PMT LOG file
    GC["forAPIcheck"]=string(PATH_PREFIX_OUTPUT, "Log_JULIA1.0.3/for_api_checking/",dataMth,".csv");
    GC["forAPIcheck_tmp"]=string(PATH_PREFIX_OUTPUT, "Log_JULIA1.0.3/for_api_checking/templete_monthly.csv");
    GC["CALI_LOG_PATH"]=string(PATH_PREFIX_OUTPUT, "Log_JULIA1.0.3/Calibration/");
    GC["DTD_LOG_PATH"]=string(PATH_PREFIX_OUTPUT, "Log_JULIA1.0.3/DTD/");
    GC["HIST_DAILY_PD_LOG_PATH"]=string(PATH_PREFIX_OUTPUT, "Log_JULIA1.0.3/histDailyPD/");
    GC["DEBUG_LOG_PATH"]=string(PATH_PREFIX_OUTPUT, "Log_JULIA1.0.3/Debug/");

    # PATH_PREFIX = "D:/JuliaTestMonthly/Production"
    # PATH_PREFIX = "//cri-hpc13/JuliaTestMonthly/Production"
    # PATH_PREFIX = "//cri-pc29/JuliaTestMonthly/Production"  # todo: change to local file for testing

    PMT_DTDforPDCALI = string(PATH_PREFIX_OUTPUT, "Data/");
    PMT_PDCALI = string(PATH_PREFIX_OUTPUT, "Data/");
    PMT_PDCALU = string(PATH_PREFIX_OUTPUT, "Data/");
    PMT_PDIR = string(PATH_PREFIX_OUTPUT, "Data/");
    PMT_AS = string(PATH_PREFIX_OUTPUT, "Data/");
    PMT_CVI = string(PATH_PREFIX_OUTPUT, "Data/");
    PMT_DAILY = string(PATH_PREFIX_OUTPUT, "Data/");

    GC["PMT_PDCALI"] = PMT_PDCALI;

    #. PMT DTD FOR PD CALIBRATION
    GC["DTDINPUT_SEGMENTS_CALIBRATION_PATH"]=string(PMT_DTDforPDCALI,"ModelCalibration/" ,dataMth, "/Processing/M1_Dtd/DTDForPDCalibration/Input/Input_In_Segments/")
    GC["DTD_PARAMETERS_CALIBRATION_PATH"]=string(PMT_DTDforPDCALI,"ModelCalibration/" ,dataMth, "/Products/M1_Dtd/DTDForPDCalibration/Parameters/")

    #. PMT FOR PD CALIBRATION
    GC["CALI_ORIGINAL_PATH_PMT"]=string(PMT_PDCALI, "ModelCalibration/" ,dataMth, "/Processing/M2_Pd/OriginalData/");
    GC["CALI_TRANSFORM_PATH"]=string(PMT_PDCALI, "ModelCalibration/" ,dataMth, "/Processing/M2_Pd/FSTransformed/");
    GC["CALI_DATA_PATH"]=string(PMT_PDCALI, "ModelCalibration/" ,dataMth, "/Processing/M2_Pd/FinalDataForCalibration/")
    GC["CALI_OUTPUT_PARA_PATH"]=string(PMT_PDCALI, "ModelCalibration/" ,dataMth, "/Products/M2_Pd/current/")
    GC["CALI_SMC_PATH"]=string(PMT_PDCALI, "ModelCalibration/" ,dataMth, "/Products/M2_Pd/current_smc/")
    GC["CALI_COMPARE_PATH"]=string(PMT_PDCALI, "ModelCalibration/" ,dataMth, "/Validation/ARResults/Comparison/")
    GC["AR_OUTPUT"]=string(PMT_PDCALI, "ModelCalibration/" ,dataMth, "/Validation/ARResults/AR/")
    GC["AR_OUTPUT_SMC"]=string(PMT_PDCALI, "ModelCalibration/" ,dataMth, "/Validation/ARResults/AR_SMC/")

    #. PMT FOR PD CALCULATION AND HYPO FS
    GC["DTDINPUT_CALCULATION_AFTER_MA_PATH"]=string(PMT_PDCALU, "ModelCalibration/" ,dataMth, "/Processing/M1_Dtd/DTDForPDCalculation/Input/After_MA/")
    GC["DTD_PARAMETERS_CALCULATION_PATH"]=string(PMT_PDCALU, "ModelCalibration/" ,dataMth, "/Products/M1_Dtd/DTDForPDCalculation/Parameters/")
    GC["DTDINPUT_HYPO_MA_FIRMS_PATH"]=string(PMT_PDCALU, "ModelCalibration/" ,dataMth, "/Processing/M1_Dtd/DTDForPDCalculation/Input/MAFirms/")
    GC["DTDOUTPUT_HYPO_MA_FIRMS_PATH"]=string(PMT_PDCALU, "ModelCalibration/" ,dataMth, "/Products/M1_Dtd/DTDForPDCalculation/Parameters/MAFirms/")
    GC["IMPORTANT_MA_TABLE_DTD_PATH"]=string(PMT_PDCALU, "ModelCalibration/",dataMth,"/Processing/M1_Dtd/DTDForPDCalculation/Input/");
    GC["IMPORTANT_MA_TABLE_FS_PATH"]=string(PMT_PDCALU, "Historical/",dataMth,"/Daily/Processing/P2_Pd/OriginalData/")
    GC["HIST_DAILY_DTD_AGGDATA"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Daily/Processing/P2_Pd/AggDTDHistDaily/")
    GC["HIST_DAILY_PD_INTER_DATA"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Daily/Processing/P2_Pd/")
    GC["HIST_DAILY_PD_OUTPUT_DATA"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Daily/Products/P2_Pd/")
    GC["HIST_DAILY_PD_INTER_AGGDATA"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Daily/Processing/P3_PdAgg/")
    GC["HIST_DAILY_PD_OUTPUT_AGGDATA"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Daily/Products/P3_PdAgg/")
    GC["HIST_DAILY_PD_UPLOAD_PATH_TR"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Daily/Products/P109_ThomsonReuters/")
    GC["HIST_DAILY_PD_OUTPUT"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Daily/Products/")
    GC["HIST_MONTHLY_PD_OUTPUT"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Monthly/Products/")
    GC["HIST_MONTHLY_PD_INTER_DATA"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Monthly/Processing/P2_Pd/")
    GC["HIST_MONTHLY_PD_OUTPUT_DATA"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Monthly/Products/P2_Pd/")
    GC["HIST_MONTHLY_PD_INTER_AGGDATA"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Monthly/Processing/P3_PdAgg/")
    GC["HIST_MONTHLY_PD_OUTPUT_AGGDATA"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Monthly/Products/P3_PdAgg/")
    GC["HIST_MONTHLY_PD_UPLOAD_PATH_WEB"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Monthly/Products/P101_WebDisplay/")
    GC["HIST_MONTHLY_PD_UPLOAD_PATH_TR"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Monthly/Products/P109_ThomsonReuters/")
    GC["HIST_DAILY_ORIGINAL_BEFORE_MA_PATH_PMT"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Daily/Processing/P2_Pd/OriginalData/Before_MA/")
    GC["HIST_DAILY_ORIGINAL_MA_FIRMS_PATH"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Daily/Processing/P2_Pd/OriginalData/MAFirms/")
    GC["HIST_DAILY_ORIGINAL_AFTER_MA_PATH"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Daily/Processing/P2_Pd/OriginalData/After_MA/")
    GC["CALCU_COMPARE_PATH"]=string(PMT_PDCALI, "Historical/" ,dataMth, "/Validation/IndividualPD/")
    #. PMT for historical CONPD
    GC["CONPD_PATH_PRODUCT"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Monthly/Products/P4_CondiProb/")
    GC["CONPD_DAILY_PATH_PRODUCT"]=string(PMT_PDCALU, "Historical/" ,dataMth, "/Daily/Products/P4_CondiProb/")

    ## for historical PDiR
    GC["PDIR_PATH_BOUNDARY_PROCESSING"]=string(PMT_PDIR, "ModelCalibration/" ,dataMth, "/Processing/M5_Pdir/")
    GC["PDIR_PATH_BOUNDARY_PRODUCT"]=string(PMT_PDIR, "ModelCalibration/" ,dataMth, "/Products/M5_Pdir/")
    GC["HIST_PDIR_PATH"]=string(PMT_PDIR, "Historical/" ,dataMth, "/Daily/Products/P5_Pdir/")

    ##. PMT for historical CVI
    GC["HIST_CVI_PATH_PROCESSING"]=string(PMT_CVI, "Historical/" ,dataMth, "/Daily/Processing/P6_Cvi/")
    GC["HIST_CVI_PATH_PRODUCT"]=string(PMT_CVI, "Historical/" ,dataMth, "/Daily/Products/P6_Cvi/")
    GC["HIST_CVI_PATH_PRODUCTWEB"]=string(PMT_CVI, "Historical/" ,dataMth, "/Daily/Products/P101_WebDisplay/Cvi/")

    ## for AS path files
    GC["CDS_RESOURCE_PATH"]=string(PMT_AS, "Historical/" ,dataMth, "/Daily/Processing/P7_As/CDS_Resource/CpnyList/")
    GC["HIST_DAILY_AS_INTER_AGGDATA"]=string(PMT_AS, "Historical/" ,dataMth, "/Daily/Processing/P8_AsAgg/")
    GC["HIST_DAILY_AS_OUTPUT_DATA"]=string(PMT_AS, "Historical/" ,dataMth, "/Daily/Products/P7_As/")
    GC["HIST_DAILY_AS_OUTPUT_AGGDATA"]=string(PMT_AS, "Historical/" ,dataMth, "/Daily/Products/P8_AsAgg/")
    GC["HIST_MONTHLY_AS_OUTPUT_DATA"]=string(PMT_AS, "Historical/" ,dataMth, "/Monthly/Products/P7_As/")
    GC["HIST_MONTHLY_AS_INTER_AGGDATA"]=string(PMT_AS, "Historical/" ,dataMth, "/Monthly/Processing/P8_AsAgg/")
    GC["HIST_MONTHLY_AS_OUTPUT_AGGDATA"]=string(PMT_AS, "Historical/" ,dataMth, "/Monthly/Products/P8_AsAgg/")
    GC["HIST_MONTHLY_AS_UPLOAD_PATH_WEB"]=string(PMT_AS, "Historical/" ,dataMth, "/Monthly/Products/P101_WebDisplay/As")
    GC["HIST_MONTHLY_AS_UPLOAD_PATH_TR"]=string(PMT_AS, "Historical/" ,dataMth, "/Monthly/Products/P109_ThomsonReuters/As")

    #. PMT DAILY
    GC["DAILY_DATA_PATH_INTERMEDIATE"]=string(PMT_DAILY, "Recent/Daily/")
    GC["DAILY_OUTPUT_PATH"]=string(PMT_DAILY, "Recent/Daily/")

    ###################################################################################
    ##########################global groups define#######################################
    ##for write API checking csv
    GrpAPICol=fill(NaN,(GC["MAX_ECON"], 1))
    GrpAPICol[2]=3
    GrpAPICol[4]=4
    GrpAPICol[13]=5
    GrpAPICol[14]=6
    GrpAPICol[200]=7
    GrpAPICol[297]=8
    # define calibratin groups' economies, calibration method, dummy variables
    # Redefined 'GROUPS' as a 1D array instead of a 2D array
    #GROUPS = fill(NaN,(GC["MAX_ECON"], 1))
    GROUPS = fill(NaN,(GC["MAX_ECON"], 1))
    GROUPS[1]= 13
    GROUPS[2]= 2
    GROUPS[3]= 13
    GROUPS[4]= 4
    GROUPS[5]= 14
    GROUPS[6]= 13
    GROUPS[7]= 14
    GROUPS[8]= 14
    GROUPS[9]= 13
    GROUPS[10]= 13
    GROUPS[11]= 13
    GROUPS[12]= 14
    GROUPS[15]= 297
    GROUPS[16]= 297
    GROUPS[17]= 13
    GROUPS[18]= 14
    GROUPS[19]= 14
    GROUPS[20]= 14
    GROUPS[22]= 14
    GROUPS[23]= 200
    GROUPS[24]= 14
    GROUPS[25]= 200
    GROUPS[26]= 200
    GROUPS[27]= 14
    GROUPS[29]= 200
    GROUPS[30]= 200
    GROUPS[31]= 200
    GROUPS[32]= 200
    GROUPS[33]= 200
    GROUPS[34]= 14
    GROUPS[35]= 200
    GROUPS[36]= 200
    GROUPS[37]= 200
    GROUPS[38]= 200
    GROUPS[39]= 14
    GROUPS[40]= 200
    GROUPS[42]= 200
    GROUPS[43]= 200
    GROUPS[45]= 200
    GROUPS[46]= 200
    GROUPS[47]= 200
    GROUPS[48]= 14
    GROUPS[49]= 14
    GROUPS[50]= 14
    GROUPS[51]= 14
    GROUPS[52]= 200
    GROUPS[54]= 200
    GROUPS[55]= 200
    GROUPS[56]= 200
    GROUPS[57]= 14
    GROUPS[58]= 200
    GROUPS[59]= 14
    GROUPS[60]= 200
    GROUPS[61]= 14
    GROUPS[63]= 14
    GROUPS[64]= 200
    GROUPS[65]= 14
    GROUPS[66]= 200
    GROUPS[67]= 14
    GROUPS[69]= 200
    GROUPS[70]= 200
    GROUPS[71]= 14
    GROUPS[72]= 200
    GROUPS[73]= 200
    GROUPS[74]= 14
    GROUPS[75]= 200
    GROUPS[76]= 200
    GROUPS[77]= 200
    GROUPS[78]= 14
    GROUPS[79]= 200
    GROUPS[81]= 200
    GROUPS[82]= 200
    GROUPS[83]= 14
    GROUPS[84]= 14
    GROUPS[85]= 200
    GROUPS[86]= 14
    GROUPS[87]= 200
    GROUPS[88]= 14
    GROUPS[89]= 200
    GROUPS[92]= 14
    GROUPS[95]= 14
    GROUPS[96]= 14
    GROUPS[97]= 14
    GROUPS[100]= 14
    GROUPS[102]= 14
    GROUPS[103]= 14
    GROUPS[107]= 14
    GROUPS[163]= 14

    MULTI_ECON_GROUPS = [13 14 297 200];
    NUM_SUB_GROUPS = [5 5 1 5]; # within each group, how many sub-groups (aside from base)
    # initialize SUB_GROUPS and SUB_GROUP_DUMMYS
    ECONS_IN_GROUPS, SUB_GROUPS, SUB_GROUP_DUMMYS = dummy_sub_group_init_v011(GROUPS, MULTI_ECON_GROUPS,NUM_SUB_GROUPS)

    # Asia Developed
    SUB_GROUPS[1,1][1]= 1
    SUB_GROUPS[1,1][2]= 3
    SUB_GROUPS[1,1][3]= 9
    SUB_GROUPS[1,1][4]= 10
    SUB_GROUPS[1,1][5]= 11

    SUB_GROUP_DUMMYS[1,1][3,1] = 1  # 3mr AUS
    SUB_GROUP_DUMMYS[1,1][3,2] = 1  # 3mr HK
    SUB_GROUP_DUMMYS[1,1][3,3] = 1  # 3mr SG
    SUB_GROUP_DUMMYS[1,1][3,4] = 1  # 3mr KR
    SUB_GROUP_DUMMYS[1,1][3,5] = 1  # 3mr TW

    # Emerging Econs
    SUB_GROUPS[2,1][1] = 5
    SUB_GROUPS[2,1][2] = 7
    SUB_GROUPS[2,1][3] = 8
    SUB_GROUPS[2,1][4] = [92 95 96 97 100 102 103 107]
    SUB_GROUPS[2,1][5] = 12

    SUB_GROUP_DUMMYS[2,1][3,1] = 1  # Size ave Indonesia
    SUB_GROUP_DUMMYS[2,1][10,1] = 1  # Size ave Indonesia
    SUB_GROUP_DUMMYS[2,1][3,2] = 1 # 3mr Malaysia
    SUB_GROUP_DUMMYS[2,1][3,3] = 1 # 3mr Philippines
    SUB_GROUP_DUMMYS[2,1][3,4] = 1 # 3mr LAMR
    SUB_GROUP_DUMMYS[2,1][3,5] = 1  # 3mr Thailand

    # North America
    SUB_GROUPS[3,1][1] = 16
    SUB_GROUP_DUMMYS[3,1][3,1] = 1  # 3mr CA

    # Europe
    SUB_GROUPS[4,1][1] = 33
    SUB_GROUPS[4,1][2] = 66
    SUB_GROUPS[4,1][3] = 81
    SUB_GROUPS[4,1][4] = 89
    SUB_GROUPS[4,1][5] = [26 75 60  29 30 32 42 56 69 72 85 87 43 82 73 59] # If they not euromember and they need dummy, they are put here.

    SUB_GROUP_DUMMYS[4,1][3,1] = 1  # 3mr DK
    SUB_GROUP_DUMMYS[4,1][3,2] = 1  # 3mr NO
    SUB_GROUP_DUMMYS[4,1][3,3] = 1  # 3mr SE
    SUB_GROUP_DUMMYS[4,1][3,4] = 1  # 3mr UK
    SUB_GROUP_DUMMYS[4,1][3,5] = 1  # 3mr
    A = highest_indexin(GROUPS, MULTI_ECON_GROUPS);
    CountriesDeMeanTMR = findall(x->x!=0, A)
    A = nothing
    #    CountriesDeMeanTMR = find(indexin(GROUPS, MULTI_ECON_GROUPS))' # 3mr of Countries in Asia Developed, US, and Europe need to be demeaned

    NPARA_GROUP, SUBGROUP_COLS, ECON_COLS = dummy_group_npara_v011(GROUPS, MULTI_ECON_GROUPS, SUB_GROUP_DUMMYS, NUM_SUB_GROUPS, GC["NPARA_BASE"],SUB_GROUPS,ECONS_IN_GROUPS)
    # count number of parameters for each group and designate columns for each economy
    # Lucy: Initialize GC.NPARA_GROUP  GC.SUBGROUP_COLS  GC.ECON_COLS

    # iso code for each country
    ISOCODE = Array{Any}(undef, GC["MAX_ECON"],2)  ####
    ISOCODE[1,1] = "AU"   # Australia   ##!GC.ISOCODE{1}{1} = "AU";  before, ignoring the second D
    ISOCODE[2,1] = "CN"   # China
    ISOCODE[3,1] = "HK"  # Hong Kong
    ISOCODE[4,1] = "IN"   # India
    ISOCODE[5,1] = "ID"  # Indonesia
    ISOCODE[6,1] = "JP"   # Japan
    ISOCODE[7,1] = "MY"  # Malaysia
    ISOCODE[8,1] = "PH"  # Philippines
    ISOCODE[9,1] = "SG"  # Singapore
    ISOCODE[10,1] = "KR" # South Korea
    ISOCODE[11,1] = "TW" # Taiwan
    ISOCODE[12,1] = "TH" # Thailand
    ISOCODE[15,1] = "US" # US
    ISOCODE[16,1] = "CA" # Canada
    ISOCODE[17,1] = "NZ" # "New Zealand"
    ISOCODE[18,1] = "VN" # "Vietnam"
    ISOCODE[19,1] = "LK" # "Sri Lanka"
    ISOCODE[20,1] = "PK" # Pakistan
    ISOCODE[22,1] = "BD" # Bangladesh
    ISOCODE[23,1] = "AT" # Austria
    ISOCODE[24,1] = "BH" # Bahrain
    ISOCODE[25,1] = "BE" # Belgium
    ISOCODE[26,1] = "BA" # Bosnia and Herzegovina
    ISOCODE[29,1] = "BG" # Bulgaria
    ISOCODE[30,1] = "HR" # Croatia
    ISOCODE[31,1] = "CY" # Cyprus
    ISOCODE[32,1] = "CZ" # Czech Republic
    ISOCODE[33,1] = "DK" # "Denmark"
    ISOCODE[34,1] = "EG" # "Egypt"
    ISOCODE[35,1] = "EE" # "Estonia"
    ISOCODE[36,1] = "FI" # "Finland"
    ISOCODE[37,1] = "FR" # "France"
    ISOCODE[38,1] = "DE" # "Germany"
    ISOCODE[40,1] = "GR" # "Greece"
    ISOCODE[42,1] = "HU" # "Hungary"
    ISOCODE[43,1] = "IS" # "Iceland"
    ISOCODE[45,1] = "IE" # "Ireland"
    ISOCODE[46,1] = "IL" # "Israel"
    ISOCODE[47,1] = "IT" # "Italy"
    ISOCODE[48,1] = "JO" # "Jordan"
    ISOCODE[49,1] = "KZ" # "Kazakhstan"
    ISOCODE[51,1] = "KW" # "Kuwait"
    ISOCODE[52,1] = "LV" # "Latvia"
    ISOCODE[54,1] = "LT" # "Lithuania"
    ISOCODE[55,1] = "LU" # "Luxembourg"
    ISOCODE[56,1] = "MK" # "Macedonia"
    ISOCODE[58,1] = "MT" # "Malta"
    ISOCODE[59,1] = "MU" # "Mauritius"
    ISOCODE[60,1] = "ME" # "Montenegro"
    ISOCODE[61,1] = "MA" # "Morocco"
    ISOCODE[64,1] = "NL" # "Netherlands"
    ISOCODE[65,1] = "NG" # "Nigeria"
    ISOCODE[66,1] = "NO" # "Norway"
    ISOCODE[67,1] = "OM" # "Oman"
    ISOCODE[69,1] = "PL" # "Poland"
    ISOCODE[70,1] = "PT" # "Portugal"
    ISOCODE[72,1] = "RO" # "Romania"
    ISOCODE[73,1] = "RU" # "Russian Federation"
    ISOCODE[74,1] = "SA" # "Saudi Arabia"
    ISOCODE[75,1] = "RS" # "Serbia"
    ISOCODE[76,1] = "SK" # "Slovakia"
    ISOCODE[77,1] = "SI" # "Slovenia"
    ISOCODE[78,1] = "ZA" # "South Africa"
    ISOCODE[79,1] = "ES" # "Spain"
    ISOCODE[81,1] = "SE" # "Sweden"
    ISOCODE[82,1] = "CH" # "Switzerland"
    ISOCODE[84,1] = "TN" # "Tunisia"
    ISOCODE[85,1] = "TR" # "Turkey"
    ISOCODE[87,1] = "UA" # "Ukraine"
    ISOCODE[88,1] = "AE" # "U.A.E"
    ISOCODE[89,1] = "GB" # "UK"
    ISOCODE[92,1] = "AR" # "Argentina"
    ISOCODE[95,1] = "BR" # "Brazil"
    ISOCODE[96,1] = "CO" # "Colombia"
    ISOCODE[97,1] = "CL" # "Chile"
    ISOCODE[100,1] = "JM" # "Jamaica"
    ISOCODE[102,1] = "MX" # "Mexico"
    ISOCODE[103,1] = "PE" # "Peru"
    ISOCODE[107,1] = "VE" # "Venezuela"

    ISOCODE[27,1] = "BW"   #"Botswana"
    ISOCODE[39,1] = "GH"   # "Ghana"
    ISOCODE[50,1] = "KE"   # "Kenya"
    ISOCODE[57,1] = "MW"   # "Malawi"
    ISOCODE[63,1] = "NA"   # "Namibia"
    ISOCODE[163,1] = "RW"   #"Rwanda"
    ISOCODE[83,1] = "TZ"   #"Tanzania"
    ISOCODE[86,1] = "UG"   # "Uganda"

    ISOCODE[13,1] = "Asia Developed Group"#"ASEAN Group"
    ISOCODE[14,1] = "Emerging Group" # ASEAN ex-SG
    ISOCODE[297,1] = "NA Group" # NAMR
    ISOCODE[200,1] = "Euro Group"
    ISOCODE[201,1] = "East European Group"

    ISO3CODE = Array{Any}(undef, GC["MAX_ECON"],1)
    ISO3CODE[1] = "AUS"
    ISO3CODE[2] = "CHN"
    ISO3CODE[3] = "HKG"
    ISO3CODE[4] = "IND"
    ISO3CODE[5] = "IDN"
    ISO3CODE[6] = "JPN"
    ISO3CODE[7] = "MYS"
    ISO3CODE[8] = "PHL"
    ISO3CODE[9] = "SGP"
    ISO3CODE[10] = "KOR"
    ISO3CODE[11] = "TWN"
    ISO3CODE[12] = "THA"
    ISO3CODE[15] = "USA"
    ISO3CODE[16] = "CAN"
    ISO3CODE[17] = "NZL"
    ISO3CODE[18] = "VNM"
    ISO3CODE[19] = "LKA"
    ISO3CODE[20] = "PAK"
    ISO3CODE[21] = "FJI"
    ISO3CODE[22] = "BGD"
    ISO3CODE[23] = "AUT"
    ISO3CODE[24] = "BHR"
    ISO3CODE[25] = "BEL"
    ISO3CODE[26] = "BIH"
    ISO3CODE[27] = "BWA"
    ISO3CODE[28] = "NULL"
    ISO3CODE[29] = "BGR"
    ISO3CODE[30] = "HRV"
    ISO3CODE[31] = "CYP"
    ISO3CODE[32] = "CZE"
    ISO3CODE[33] = "DNK"
    ISO3CODE[34] = "EGY"
    ISO3CODE[35] = "EST"
    ISO3CODE[36] = "FIN"
    ISO3CODE[37] = "FRA"
    ISO3CODE[38] = "DEU"
    ISO3CODE[39] = "GHA"
    ISO3CODE[40] = "GRC"
    ISO3CODE[41] = "GGY"
    ISO3CODE[42] = "HUN"
    ISO3CODE[43] = "ISL"
    ISO3CODE[44] = "IRQ"
    ISO3CODE[45] = "IRL"
    ISO3CODE[46] = "ISR"
    ISO3CODE[47] = "ITA"
    ISO3CODE[48] = "JOR"
    ISO3CODE[49] = "KAZ"
    ISO3CODE[50] = "KEN"
    ISO3CODE[51] = "KWT"
    ISO3CODE[52] = "LVA"
    ISO3CODE[53] = "LBN"
    ISO3CODE[54] = "LTU"
    ISO3CODE[55] = "LUX"
    ISO3CODE[56] = "MKD"
    ISO3CODE[57] = "MWI"
    ISO3CODE[58] = "MLT"
    ISO3CODE[59] = "MUS"
    ISO3CODE[60] = "MNE"
    ISO3CODE[61] = "MAR"
    ISO3CODE[62] = "MOZ"
    ISO3CODE[63] = "NAM"
    ISO3CODE[64] = "NLD"
    ISO3CODE[65] = "NGA"
    ISO3CODE[66] = "NOR"
    ISO3CODE[67] = "OMN"
    ISO3CODE[68] = "PSE"
    ISO3CODE[69] = "POL"
    ISO3CODE[70] = "PRT"
    ISO3CODE[71] = "QAT"
    ISO3CODE[72] = "ROM"
    ISO3CODE[73] = "RUS"
    ISO3CODE[74] = "SAU"
    ISO3CODE[75] = "SRB"
    ISO3CODE[76] = "SVK"
    ISO3CODE[77] = "SVN"
    ISO3CODE[78] = "ZAF"
    ISO3CODE[79] = "ESP"
    ISO3CODE[80] = "SWZ"
    ISO3CODE[81] = "SWE"
    ISO3CODE[82] = "CHE"
    ISO3CODE[83] = "TZA"
    ISO3CODE[84] = "TUN"
    ISO3CODE[85] = "TUR"
    ISO3CODE[86] = "UGA"
    ISO3CODE[87] = "UKR"
    ISO3CODE[88] = "ARE"
    ISO3CODE[89] = "GBR"
    ISO3CODE[90] = "ZMB"
    ISO3CODE[91] = "ZWE"
    ISO3CODE[92] = "ARG"
    ISO3CODE[93] = "BRB"
    ISO3CODE[94] = "BHS"
    ISO3CODE[95] = "BRA"
    ISO3CODE[96] = "COL"
    ISO3CODE[97] = "CHL"
    ISO3CODE[98] = "CRI"
    ISO3CODE[99] = "ECU"
    ISO3CODE[100] = "JAM"
    ISO3CODE[101] = "CYM"
    ISO3CODE[102] = "MEX"
    ISO3CODE[103] = "PER"
    ISO3CODE[104] = "PAN"
    ISO3CODE[105] = "TTO"
    ISO3CODE[106] = "URY"
    ISO3CODE[107] = "VEN"
    ISO3CODE[108] = "VGB"
    ISO3CODE[109] = "ANT"
    ISO3CODE[110] = "PRY"
    ISO3CODE[111] = "BOL"
    ISO3CODE[112] = "BMU"
    ISO3CODE[113] = "DMA"
    ISO3CODE[114] = "NIC"
    ISO3CODE[115] = "AIA"
    ISO3CODE[116] = "AGO"
    ISO3CODE[117] = "AZE"
    ISO3CODE[118] = "BFA"
    ISO3CODE[119] = "BEN"
    ISO3CODE[120] = "BLZ"
    ISO3CODE[121] = "COD"
    ISO3CODE[122] = "CIV"
    ISO3CODE[123] = "CUW"
    ISO3CODE[124] = "DOM"
    ISO3CODE[125] = "FLK"
    ISO3CODE[126] = "FRO"
    ISO3CODE[127] = "GAB"
    ISO3CODE[128] = "GUF"
    ISO3CODE[129] = "GIB"
    ISO3CODE[130] = "IMN"
    ISO3CODE[131] = "JEY"
    ISO3CODE[132] = "KHM"
    ISO3CODE[133] = "LIE"
    ISO3CODE[134] = "MCO"
    ISO3CODE[136] = "MAC"
    ISO3CODE[137] = "NER"
    ISO3CODE[138] = "PNG"
    ISO3CODE[139] = "PRI"
    ISO3CODE[140] = "REU"
    ISO3CODE[141] = "SDN"
    ISO3CODE[142] = "SJM"
    ISO3CODE[143] = "SLE"
    ISO3CODE[144] = "SEN"
    ISO3CODE[145] = "SLV"
    ISO3CODE[146] = "TCA"
    ISO3CODE[147] = "TGO"
    ISO3CODE[148] = "UZB"
    ISO3CODE[149] = "VIR"
    ISO3CODE[150] = "MNG"
    ISO3CODE[151] = "MHL"
    ISO3CODE[152] = "LAO"
    ISO3CODE[153] = "ARM"
    ISO3CODE[154] = "NPL"
    ISO3CODE[155] = "CPV"
    ISO3CODE[156] = "CMR"
    ISO3CODE[157] = "GTM"
    ISO3CODE[158] = "ATG"
    ISO3CODE[159] = "KNA"
    ISO3CODE[160] = "GRD"
    ISO3CODE[161] = "LCA"
    ISO3CODE[162] = "MDA"
    ISO3CODE[163] = "RWA"
    ISO3CODE[164] = "SYR"
    ISO3CODE[165] = "GEO"
    ISO3CODE[167] = "MDG"
    ISO3CODE[168] = "GRL"
    ISO3CODE[169] = "GUM"
    ISO3CODE[171] = "CUB"
    ISO3CODE[172] = "SYC"
    ISO3CODE[173] = "MMR"
    ISO3CODE[174] = "IRN"

    EurozZoneDate =  fill(NaN,(GC["MAX_ECON"], 1))
    EurozZoneDate[23] =  19990101  # Austria
    EurozZoneDate[25] =  19990101  # Belgium
    EurozZoneDate[31] =  20080101  # Cyprus
    EurozZoneDate[33] =  30000101  # "Denmark")
    EurozZoneDate[35] =  20110101  # "Estonia")
    EurozZoneDate[36] =  19990101  # "Finland")
    EurozZoneDate[37] =  19990101  # "France")
    EurozZoneDate[38] =  19990101  # "Germany")
    EurozZoneDate[40] =  20010101  # "Greece")
    EurozZoneDate[43] =  30000101  # "Iceland")
    EurozZoneDate[45] =  19990101  # "Ireland")
    EurozZoneDate[47] =  19990101  # "Italy")
    EurozZoneDate[52] =  20140101  # "Latvia")
    EurozZoneDate[54] =  20150101  # "Lithuania")
    EurozZoneDate[55] =  19990101  # "Luxembourg")
    EurozZoneDate[58] =  20080101  # "Malta")
    EurozZoneDate[64] =  19990101  # "Netherlands")
    EurozZoneDate[66] =  30000101  # "Norway")
    EurozZoneDate[70] =  19990101  # "Portugal")
    EurozZoneDate[76] =  20090101  # "Slovakia")
    EurozZoneDate[77] =  20070101  # "Slovenia")
    EurozZoneDate[79] =  19990101  # "Spain")
    EurozZoneDate[81] =  30000101  # "Sweden")
    EurozZoneDate[82] =  30000101  # "Switzerland")
    EurozZoneDate[89] =  30000101  # "UK"

    # record calibration date for each country
    for i = unique(GROUPS[isfinite.(GROUPS)]')
        if i != 0
            for j = (LinearIndices(GROUPS))[findall(GROUPS.==i)]'
                ISOCODE[j,2] = string(GC["CaliDateArray"][Int(i)])
            end
        end
    end

    ## TimeVariant
    CovIdxOfCtry = Array{Any}(undef, 297)
    #2
    TimeVariant = [1 4]
    TimeInvariant = setdiff(1: GC["NPARA_BASE"], TimeVariant)
    CovIdxOfCtry[2] = Dict("NoOfCovariates"=>GC["NPARA_BASE"],"TimeVariant"=>TimeVariant,"TimeInvariates"=>TimeInvariant,
                           "FirstMonth"=>198801,"HistMonth4Cut"=>204,"isOldStepResponse"=>0,"isNewStepResponse" =>1,"isImpulseResponse"=>0,"SBmethod"=>2) # step response with different rates before/after t0

    #297
    TimeVariant = [18]
    TimeInvariant = setdiff(1: GC["NPARA_BASE"], TimeVariant)
    CovIdxOfCtry[297] = Dict("NoOfCovariates"=>GC["NPARA_BASE"],"TimeVariant"=>TimeVariant,"TimeInvariates"=>TimeInvariant,
                             "FirstMonth"=>198801,"HistMonth4Cut"=>249,"isOldStepResponse"=>0,"isNewStepResponse" =>0,"isImpulseResponse"=>1,"SBmethod"=>3) # # impulse response

    TimeVariantOfPara_COUNTRY = [2, 297]
    TimeVariantStartPoint =  12 # start computation after 6 months from break point
    GC["GROUPS"] = GROUPS
    GC["MULTI_ECON_GROUPS"] = MULTI_ECON_GROUPS
    GC["NUM_SUB_GROUPS"] = NUM_SUB_GROUPS
    GC["CountriesDeMeanTMR"] = CountriesDeMeanTMR
    GC["ECONS_IN_GROUPS"] = ECONS_IN_GROUPS
    GC["SUB_GROUPS"] = SUB_GROUPS
    GC["SUB_GROUP_DUMMYS"] = SUB_GROUP_DUMMYS
    GC["NPARA_GROUP"] = NPARA_GROUP
    GC["SUBGROUP_COLS"] = SUBGROUP_COLS
    GC["ECON_COLS"] = ECON_COLS
    GC["ISOCODE"] = ISOCODE
    GC["ISO3CODE"] = ISO3CODE
    GC["EurozZoneDate"] = EurozZoneDate
    GC["CovIdxOfCtry"] = CovIdxOfCtry
    GC["TimeVariantOfPara_COUNTRY"] = TimeVariantOfPara_COUNTRY
    GC["TimeVariantStartPoint"] = TimeVariantStartPoint
    GC["GrpAPICol"]=GrpAPICol;
    ######################################################################
    ####################global regions define##############################
    # economies within each region in the daily updating
    GC["ECONSREGION"]=Array{Any}(undef, 4);
    GC["ECONSREGION"][1] = [(1:12)' (17:20)' 22]' #Australia, China, Hong Kong India, Indonesia, Japan, Malaysia, Philippines, Singapore, South Korea, Taiwan, Thailand, New Zealand, Vietnam
    GC["ECONSREGION"][2] = [15,16] # US, Canada
    GC["ECONSREGION"][3] = [26 60 75 84 23 24 25 31 33 34 35 36 37 38 40 43 (45:49)' 51 55 56 58 61 64 65 66 67 70 71 73 74 76 77 78 79 81 82 88 89 29 30 32 42 52 54 69 72 85 87 59 27 39 50 57 63 83 86 163]'
    GC["ECONSREGION"][4] = [92,95,96,97,100,102,103,107]
    # region's name in the daily updating
    GC["REGIONS"]=Array{Any}(undef, 4)
    GC["REGIONS"][1] = "ASIAN"
    GC["REGIONS"][2] = "NORTH AMERICAN"
    GC["REGIONS"][3] = "EUROPEAN"
    GC["REGIONS"][4] = "LATIN AMERICAN"
    # global aggregation group id
    GC["GLOBALCODE"]=Array{Any}(undef, 1)
    GC["GLOBALCODE"][1] = 99

    GC["REGIONLIST"] = Array{Any}(undef, 4)
    GC["REGIONLIST"][1] = ["RMI5000_ASIA"]
    GC["REGIONLIST"][2] = ["RMI5000_NAMR"]
    GC["REGIONLIST"][3] = ["RMI5000_EURO"]
    GC["REGIONLIST"][4] = ["RMI5000_LAMR"]

    GC["REGIONTIMEZONE"] = Array{Any}(undef, 4)
    GC["REGIONTIMEZONE"][1] = "Tokyo"
    GC["REGIONTIMEZONE"][2] = "New York"
    GC["REGIONTIMEZONE"][3] = "London"
    GC["REGIONTIMEZONE"][4] = "New York"

    #= EQY_CONSOLIDATED

    Indicates if the data returned is for the parent company or the consolidated company.
    This field applies to and provides a meaningful result for companies in the following markets:
    Japan, India, Russia, Brazil, South Korea and Taiwan.
    If the field is populated with 'Y' the data presented is for the consolidated company.
    If populated with 'N', the data presented is for the parent company.
    Returns are based on the user's personal defaults which can be changed using the FPDF function.

    CRI: Most firms in these economies issue unconsolidated financial statements
    more frequently than consolidated ones, so these are given higher priority.}

    =#
    GC["EQY_CONSOLIDATED"] = [4 6 10 11 73 95]

    GC["REGIONCONSOLIDATED"] = Array{Any}(undef, 4)
    GC["REGIONCONSOLIDATED"][1] = [1; 0]
    GC["REGIONCONSOLIDATED"][2] = [1; 0]
    GC["REGIONCONSOLIDATED"][3] = [1; 0]
    GC["REGIONCONSOLIDATED"][4] = [1; 0]

    GC["REGION_CONSOLIDATED_PRIORITY"] = Array{Any}(undef, 4)
    GC["REGION_CONSOLIDATED_PRIORITY"][1] = "DESC"
    GC["REGION_CONSOLIDATED_PRIORITY"][2] = "ASC"
    GC["REGION_CONSOLIDATED_PRIORITY"][3] = "ASC"
    GC["REGION_CONSOLIDATED_PRIORITY"][4] = "ASC"

    # aggregation group id and economy list for each aggregate group id
    GC["AGGREGATION_GROUP"]=Array{Any}(undef, 7)
    GC["AGGREGATION_GROUP"][1] = [1, 3, 6, 9, 10, 11, 17] # Asia Pacific (Developed)
    GC["AGGREGATION_GROUP"][2] = [2, 4, 5, 7, 8, 12, 18, 19, 20, 22, 132, 136, 138, 150, 152,173] # Asia Pacific (Emerging)
    GC["AGGREGATION_GROUP"][3] = [15, 16, 112, 168] # North America
    GC["AGGREGATION_GROUP"][4] = [23, 25, 26, 29, 30, 31, 32, 33, 35, 36, 37, 38, 40, 41, 42, 43, 45, 47, 52, 54, 55, 56, 58, 60, 64, 66, 69, 70,
                                  72, 73, 75, 76, 77, 79, 81, 82, 85, 87, 89, 117, 126, 129, 130, 131, 133, 134, 140, 165, 162] # Europe
    GC["AGGREGATION_GROUP"][5] = [92, 94, 95, 96, 97, 100, 101, 102, 103, 104, 106, 107, 108, 120, 123, 124, 125, 139, 149, 146, 98] # Latin America & Caribbean
    GC["AGGREGATION_GROUP"][6] = [27, 39, 50, 57, 59, 62, 63, 65, 78, 83, 86, 90, 116, 127, 137, 141, 143, 147, 156, 163, 167] # Sub-Saharan Africa
    GC["AGGREGATION_GROUP"][7] = [24, 34, 44, 46, 48, 49, 51, 61, 67, 71, 74, 84, 88] # Middle East, North Africa & Central Asia

    # aggregation Sub-group id and economy list for each aggregate Sub-group id
    GC["AGGREGATION_SUBGROUP"]=Array{Any}(undef, 7)
    GC["AGGREGATION_SUBGROUP"][1] = [23, 25, 31, 35, 36, 37, 38, 40, 45, 47, 52, 54, 55, 58, 64, 70, 76, 77, 79] # Eurozone
    GC["AGGREGATION_SUBGROUP"][2] = [26, 29, 30, 32, 33, 41, 42, 43, 56, 60, 66, 69, 72, 73, 75, 81, 82, 85, 87, 89, 117, 126, 129, 130, 131, 133, 134, 140, 165, 162] # Non-Eurozone
    GC["AGGREGATION_SUBGROUP"][3] = [92, 95, 96, 97, 102, 103, 104, 106, 107, 120, 125, 98] # Latin America
    GC["AGGREGATION_SUBGROUP"][4] = [94, 100, 101, 108, 123, 124, 139, 149, 146] # Caribbean
    GC["AGGREGATION_SUBGROUP"][5] = [24, 34, 44, 46, 48, 51, 67, 71, 74, 88] # Middle East
    GC["AGGREGATION_SUBGROUP"][6] = [61, 84] # North Africa
    GC["AGGREGATION_SUBGROUP"][7] = [49] # Central Asia

    # groups
    GC["AGGREGATION_GROUP_CODE"]=Array{Any}(undef, 7)
    GC["AGGREGATION_GROUP_CODE"][1]  = 501
    GC["AGGREGATION_GROUP_CODE"][2]  = 502
    GC["AGGREGATION_GROUP_CODE"][3]  = 503
    GC["AGGREGATION_GROUP_CODE"][4]  = 504
    GC["AGGREGATION_GROUP_CODE"][5]  = 505
    GC["AGGREGATION_GROUP_CODE"][6]  = 506
    GC["AGGREGATION_GROUP_CODE"][7]  = 507

    # subgroups
    GC["AGGREGATION_SUBGROUP_CODE"]=Array{Any}(undef, 7)
    GC["AGGREGATION_SUBGROUP_CODE"][1] = 541
    GC["AGGREGATION_SUBGROUP_CODE"][2] = 542
    GC["AGGREGATION_SUBGROUP_CODE"][3] = 551
    GC["AGGREGATION_SUBGROUP_CODE"][4] = 552
    GC["AGGREGATION_SUBGROUP_CODE"][5] = 571
    GC["AGGREGATION_SUBGROUP_CODE"][6] = 572
    GC["AGGREGATION_SUBGROUP_CODE"][7] = 573

    GC["DTD_REGION_GROUP"]=Array{Any}(undef, 4)
    GC["DTD_REGION_GROUP"][1] = [2,4,13,14]
    GC["DTD_REGION_GROUP"][2] = [297]
    GC["DTD_REGION_GROUP"][3] = [14,200]
    GC["DTD_REGION_GROUP"][4] = [14]


    GC["MinFirmForEconDtdMedian"] = 30   ## minimum amount of firms in econ to using econ Agg DTD instead of group Agg DTD
    ## define the DB numerations of variables
    GC = global_numer_definition_current()

    ## define the paths
    ## global_paths_definition_current(GC["PATH_PREFIX"], dataMth)

    ## definitions associated to economies (including macro variable source)
    ## global_economies_definition_current()

    ## definitions associated to regions
    ## GC = global_regions_definition_current()

    ## definitions associated to groups
    ## global_groups_definition_current()

    ## Extra global constants
    GC = global_constants_extra(dataDate)

    return GC
end


function dummy_sub_group_init_v011(GROUPS, MULTI_ECON_GROUPS,NUM_SUB_GROUPS)
    #set dummy variable for sub groups
    num_multi = length(MULTI_ECON_GROUPS)

    ECONS_IN_GROUPS = Array{Any}(undef, num_multi, 1)  #% economies in each group
    SUB_GROUPS =  Array{Any}(undef, num_multi, 1)      #% economies in each sub-group
    SUB_GROUP_DUMMYS = Array{Any}(undef, num_multi, 1)  #% variables that are dummys in each sub-group

    for i = 1:num_multi
        A = highest_indexin(GROUPS, [Float64(MULTI_ECON_GROUPS[i])])
        ECONS_IN_GROUPS[i] = (LinearIndices(A))[findall(x->x!=0, A)]
        SUB_GROUPS[i] = Array{Any}(undef, NUM_SUB_GROUPS[i], 1)
        SUB_GROUP_DUMMYS[i] = zeros(13, NUM_SUB_GROUPS[i])
    end
    ECONS_IN_GROUPS, SUB_GROUPS, SUB_GROUP_DUMMYS
end
#1

function dummy_group_npara_v011(GROUPS, MULTI_ECON_GROUPS,
                                SUB_GROUP_DUMMYS, NUM_SUB_GROUPS,
                                NPARA_BASE, SUB_GROUPS, ECONS_IN_GROUPS)

    num_multi = length(MULTI_ECON_GROUPS)

    NPARA_GROUP = fill(NaN,(num_multi, 1))    # number of parameters in group
    SUBGROUP_COLS = Array{Any}(undef, num_multi, 1)  #% configuration of added columns for sub-groups
    ECON_COLS = Array{Any}(undef, num_multi, 1)      #% configuration of added columns for economies in a multi-economy group

    for i = 1:num_multi
        num_econ = sum(GROUPS.== MULTI_ECON_GROUPS[i])
        added_cols = sum(sum(SUB_GROUP_DUMMYS[i]))   # dims = 1
        NPARA_GROUP[i] = NPARA_BASE + added_cols
        SUBGROUP_COLS[i] = zeros(Float64, Int(NUM_SUB_GROUPS[i]), Int(added_cols))
        ECON_COLS[i] = zeros(Float64, Int(num_econ), Int(added_cols))

        counter = 1
        for k in (1:NUM_SUB_GROUPS[i])
            num_dummy = Int(sum(SUB_GROUP_DUMMYS[i][:,k]))
            x = SUB_GROUP_DUMMYS[i][:,k]
            dummy_idx = findall(!iszero, x)
            SUBGROUP_COLS[i][k, counter:counter+num_dummy-1] = dummy_idx
            for j in 1:num_econ
                if any(x->x==ECONS_IN_GROUPS[i][j], SUB_GROUPS[i][k])
                    ECON_COLS[i][j, counter:counter+num_dummy-1] = dummy_idx
                end
            end
            counter = counter + num_dummy
        end
    end

    return NPARA_GROUP, SUBGROUP_COLS, ECON_COLS
end
