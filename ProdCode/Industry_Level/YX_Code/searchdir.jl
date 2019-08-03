function searchdir(path, key)
    files = filter(x->occursin(key,x), readdir(path))
    return files
end
