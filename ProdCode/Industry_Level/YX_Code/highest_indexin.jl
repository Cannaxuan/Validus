"""
highest_indexin(a::Array, b::Array)

Returns a vector containing the highest index in b for each value in a that is a member of b . The output
vector contains 0 wherever a is not a member of b.

This works identical to indexin(a, b) in julia 0.6

# Examples

```julia-repl
julia> a = ['a', 'b', 'c', 'b', 'd', 'a'];

julia> b = ['a','b','c'];

julia> highest_indexin(a,b)
6-element Array{Int64,1}:

1
2
3
2
0
1

julia> highest_indexin(b,a)
3-element Array{Int64,1}:
6
4
3
```
"""
function highest_indexin(a::AbstractArray, b::AbstractArray)
    ids = []
    for val in a
        found = false
        for i = reverse(1:length(b))
            if b[i] == val
                push!(ids, i)
                found = true
                break
            end
        end
        if !found
            push!(ids, 0)
        end
    end
    return ids
end
