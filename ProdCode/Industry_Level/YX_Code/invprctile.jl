function invprctile(x, q)
    invpr = ecdf(x)
    p = invpr(q)
    return p
end
#
# function invprctile(x, q, dims)
#     x= PDsamplevalue, q = PD_value[idx]
#     if dims == 1
#         p = Vector{Float64}(undef, size(x, 1))
#         for i = 1:size(x, 1)
#             invpr = ecdf(x[i, :])
#             p[i] = invpr(q)
#         end
#     elseif dims == 2
#         p = Vector{Float64}(undef, size(x, 1))
#         for i = 1:size(x, 2)
#             invpr = ecdf(x[:, i])
#             p[i] = invpr(q)
#         end
#     end
#     return p
# end
