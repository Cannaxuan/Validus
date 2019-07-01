function pivot(df::AbstractDataFrame, rowFields, colField::Symbol, valuesField::Symbol; ops=sum, filter::Dict=Dict(), sort=[])

    for (k,v) in filter
      df = df[ [i in v for i in df[k]], :]
    end

    sortv = []
    sortOptions = []
    if(isa(sort, Array))
        sortv = sort
    else
        push!(sortv,sort)
    end
    for i in sortv
        if(isa(i, Tuple))
            if (isa(i[2], Array)) # The second option is a custom order
                orderArray = Array(collect(union(    OrderedSet(i[2]),  OrderedSet(unique(df[i[1]]))        )))
                push!(sortOptions, order(i[1], by = x->Dict(x => i for (i,x) in enumerate(orderArray))[x] ))
            else                  # The second option is a reverse direction flag
                push!(sortOptions, order(i[1], rev = i[2]))
            end
        else
          push!(sortOptions, order(i))
        end
    end

    catFields::AbstractVector{Symbol} = cat(rowFields, colField, dims=1)

    dfs  = DataFrame[]
    opsv =[]
    if(isa(ops, Array))
        opsv = ops
    else
        push!(opsv,ops)
    end

    for op in opsv
        dft = by(df, catFields) do df2
            a = DataFrame()
            a[valuesField] = op(df2[valuesField])
            if(length(opsv)>1)
                a[:op] = string(op)
            end
            a
        end
        push!(dfs,dft)
    end

    df = vcat(dfs...)
    df = DataFrames.unstack(df,colField,valuesField)
    sort!(df, sortOptions)
    return df
end

# exam = DataFrame(financialStatementDat)
# result = pivot(exam, :x1, :x2, :x3 , ops = nanMean)
# String(names(result)[2])
# parse(Float64, String(names(result)[2]))
