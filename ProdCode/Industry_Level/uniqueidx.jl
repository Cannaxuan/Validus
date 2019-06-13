function uniqueidx(A)
     ## This is used in Julia 1.0.3.
     ## C = unique(A); IA, IC = uniqueidx(A).
     ## IA: the index of the first occurrece of each repeated value in A for C, eg.A[IA]=C
     ## IC: the index in C for C, eg.C[IC]=A.
     ## uniqueset = Set{T}()
     uniqueset = Set{typeof(A[1,:])}()
     IA = Vector{Int64}()
     IC = Vector{Int64}()
     tempic= 0
     for i in eachindex(A[:,1])
         Ai = A[i, :]
         if !(Ai in uniqueset)
             push!(IA, i)
             push!(uniqueset, Ai)
             tempic = tempic + 1
         end
         push!(IC, tempic)
     end
     return IA, IC
end
