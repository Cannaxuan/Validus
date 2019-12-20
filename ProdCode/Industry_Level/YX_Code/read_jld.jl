

using JLD, MAT


function read_jld(readpath::String, variablename::String)
    @assert(readpath[end-3 : end] == ".jld");
    if isfile(readpath)
        data = jldopen(readpath, "r") do file
            read(file, variablename);
        end
    else
        readpath = replace(readpath, ".jld" => ".mat")
        data = matread(readpath)[variablename]
        @warn "Only found $readpath while .jld file is provided. Used matread instead."
    end

    return data;
end

function read_jld(readpath::String)
    @assert(readpath[end-3 : end] == ".jld");
    if isfile(readpath)
    data = jldopen(readpath, "r") do file
        read(file);
    end
    else
        readpath = replace(readpath, ".jld" => ".mat")
        data = matread(readpath)
        @warn "Only found $readpath while .jld file is provided. Used matread instead."
    end
    return data;
end
