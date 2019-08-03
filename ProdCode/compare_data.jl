financialStatement_temp = deepcopy(financialStatement)
sales_rev_turn_raw_temp = deepcopy(sales_rev_turn_raw)
sales_rev_turn_raw = deepcopy(sales_rev_turn_raw_temp)



data1 =
    matread(raw"C:\Users\e0375379\Downloads\DT\Validus\Validus\firmspecificAll.mat")

data1 =  data1["firmspecificAll"]



data2 = firmspecificAll
    load(raw"C:\Users\e0375379\Downloads\DT\Validus\Validus\ProdData\201905\Firm\FullPeriodPD\PD_all_9.jld")

findall(.!isequal.(data1, data2))

findall(data1 .- data2 .>= 0.1)
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

df1 = DataFrame(data1)
df2 = DataFrame(data2)

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
