function missing2NaN!(df::DataFrame; onlyfloats=false)
   for (name, col) in eachcol(df,true)
       (onlyfloats && !(eltype(col) <: Union{Missing,AbstractFloat})) && continue
       df[name]= Missings.coalesce.( col, NaN )
   end
   return df
end
