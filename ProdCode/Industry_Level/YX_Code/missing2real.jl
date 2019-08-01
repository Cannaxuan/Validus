function missing2real!(df::DataFrame, real; onlyfloats=false)
   for (name, col) in eachcol(df,true)
       (onlyfloats && !(eltype(col) <: Union{Missing,AbstractFloat})) && continue
       df[name]= Missings.coalesce.( col, real)
   end
   return df
end
