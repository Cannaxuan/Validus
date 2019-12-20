
financialStatement_temp = deepcopy(financialStatement)
sales_rev_turn_raw_temp = deepcopy(sales_rev_turn_raw)
sales_rev_turn_raw = deepcopy(sales_rev_turn_raw_temp)
using MAT
using JLD
Com = datamat["Sales_Rev_Turn_Raw"]

datamat =
    matread(raw"\\unicorn6\TeamData\VT_DT\Validus\ProdData\201906\Firm\SMEPD_Calculation_Econ9\Input\sampleMatrices.mat")["finalSmX"]
datamat = reshape(datamat, size(datamat, 2), 1)
datamat = datamat[:,1,:]
CSV.write(PathStruct["SMEPD_Input"]*"datamat.csv", DataFrame(datamat[1, :][1]["V05"]))
firminfomat=
            matread(raw"\\unicorn6\TeamData\VT_DT\Validus\ProdData\201906\Firm\FullPeriodPD\firminfo.mat")["firmInfo"]
datamat = datamat["finalMeX"]
datajld=
    load(raw"\\unicorn6\TeamData\VT_DT\Validus\ProdData\201906\Firm\SMEPD_Calculation_Econ9\Input\sampleMatrices.jld")["finalSmX"]
    datajld= datajld[:,1,:]
firminfojld= firmInfo
        load(raw"\\unicorn6\TeamData\VT_DT\Validus\ProdData\201906\Firm\SMEPD_Calculation_Econ9\Input\sampleMatrices.jld")["finalSmX"]
datajld = datajld[1]["V05"]
CSV.write(PathStruct["SMEPD_Input"]*"datajld.csv", DataFrame(datajld))

df1 = DataFrame(firminfomat)
df2 = DataFrame(firminfojld)
Vec = collect(1:size(firminfojld, 1))
df1 = DataFrame([Vec firminfomat])
df2 = DataFrame([Vec firminfojld])

df1 = sort(df1, names(df1)[2:end], rev = false)
df2 = sort(df2, names(df2)[2:end], rev = false)

idx1 = Int.(df1[:, 1])
idx2 = Int.(df2[:, 1])
datamat[:, idx1]
datajld[:, idx2]

index = findall(.!isequal.(Matrix{Float32}(df1[:,vcat(1:9,11:13,15:19)]), Matrix{Float32}(df2[:,vcat(1:9,11:13,15:19)])))
names(IncreMetable)[14]

index = findall(.!isequal.(Matrix{Float32}(datamat[:, idx1]), Matrix{Float32}(datajld[:, idx2])))
Matrix(df1)[index]

lia, locb = ismember_CK(Matrix(df1), Matrix(df2), "rows")
findall(lia .== false)
df1[36191:36195, :]
merge = join(df1,df2,on = [:x1, :x2, :x3], kind = :left)

join(RatioM, LogRatioM, on = [:CompNo, :monthDate, :econID], kind = :left)
df1[120:130,:]

df1[1:10, 10]
df2[1:10, 10]
names(df2)[14]
df1[1:10, 59279]

index[80][2]
col = Vector{Int64}(undef, length(index))
for i = 1:length(index)
    col[i] = index[i][2]
end
unique(col)










data1 = data1[309:end,4:end]

findfirst(isfinite.(data2[:,1]))
data1[idx]
data2 = data2[309:end,4:end]

data2 = PD_all[:,:,1]
    load(raw"C:\Users\e0375379\Downloads\DT\Validus\Validus\ProdData\201905\Firm\FullPeriodPD\PD_all_9.jld")

idx = findall(.!isequal.(data1, data2))

data3 =
    matread(raw"\\unicorn6\TeamData\VT_DT\Validus_SMECombined\ProdData\201906\Firm\SMEPD_Calculation_Econ9\Input\Varresult.mat")["Varresult"]
data3["ind"][1]["V05"]
data4 =
    load(raw"\\unicorn6\TeamData\VT_DT\Validus\ProdData\201906\Firm\SMEPD_Calculation_Econ9\Input\Varresult.jld")["Varresult"]
data4["ind"][1]["V05"]

data3["indecon"][1]["V05"]
data4["indecon"][1]["V05"]

idx3 = nanSum(data3[:, 2, :], 1) .!= 0
data5 = data3[:,1,idx3]








idx4 = nanSum(data4[:, 2, :], 1) .!= 0
data6 = data4[:,1,idx4]







idx = findall(abs.(data1 .- data2) .>= 0.001)
deepcopy(dataFlatMth)
res = []
for i = 1:3642
    df1 = DataFrame(data1[:, :, i])
    df2 = DataFrame(data2[:,:, i])

    df1 = sort(df1, names(df1), rev = false)
    df2 = sort(df2, names(df2), rev = false)

    l = length(findall(.!isequal.(Matrix(df1), Matrix(df2))))
    if l != 0
        push!(res, i)
    end
end

df1 = DataFrame(datamat)
df2 = DataFrame(datajld)

df1 = sort(df1, names(df1), rev = false)




df2 = sort(df2, names(df2), rev = false)

findall(.!isequal.(Matrix{Float16}(df1), Matrix{Float16}(df2)))
# ismember_CK(Matrix(df2), Matrix(df1), "rows")


(Matrix(df1))[712, 3]
(Matrix(df2))[712, 3]
df1[2422:2426,:]
df2[2422:2426,:]

dataFlat_jld = Dict()
dataFlat_jld["dataFlat"] = dataFlat
SalesData2D = load(raw"")
SalesData2D=load(raw"C:\Users\e0375379\Downloads\DT\Validus\Validus\ProdData\201905\Firm\Data\DTD_Regression\Econs_1_3_9_10\FS\SalesData2D_1.jld")

matwrite(raw"C:\Users\e0375379\Downloads\DT\Validus\Validus\ProdData\201905\Firm\Data\DTD_Regression\Econs_1_3_9_10\FS\SalesData2D_1.mat", SalesData2D)

Float16(0.057153849393044014)
