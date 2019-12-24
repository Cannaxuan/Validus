function read_fs_xls_V2(fxrate, path_to_input_file, countrycode = 9)

    IndVtr = [10008, 10002, 10003, 10004, 10005, 10006, 10007, 10011, 10013, 10014]
    path_to_input_file = XLSX.readxlsx(path_to_input_file)
    sheetname = XLSX.sheetnames(path_to_input_file)
    m = length(sheetname)
    num = Vector{Array{Float64}}(undef, m)
    firmindex = hcat(-(1:m), fill(NaN, (m, 2)))
    for i = 1:m
        fsnum = path_to_input_file[sheetname[i]][:]
        nfsclaim = fsnum[2, 2]
        fsnum = fsnum[3:13, 2:end]
        idx = .!all(ismissing.(fsnum), dims = 1)
        fsnum = fsnum[:, idx[:]]
        ## if FS data are missing, we set to 0.
        fsnum[ismissing.(fsnum)] .= 0
        if nfsclaim != size(fsnum, 2)
            error("The number of finaicial statements is inconsisitent with data provided. Please have a check!")
        end

        fsdate = @view fsnum[1,:]
        for i = 1:length(fsdate)
            try
                date, month, year = map(x -> parse(Int, x), split.(fsdate[i], "."))
                fsdate[i] = year*10000 + month*100 + date
            catch
                date, month, year = map(x -> parse(Int, x), split.(fsdate[i], "/"))
                fsdate[i] = year*10000 + month*100 + date
            end
        end

        idx = findlast(fxrate[:, 1] .<= fsnum[1, 1])
        temp = fsnum[9, 1]/fxrate[idx, 2]
        if 0 <= temp/1e6 <= 100
            if temp/1e6 > 10
                firmindex[i, 2] = 1 ## medium
            elseif temp/1e6 > 2
                firmindex[i, 2] = 2 ## small
            else
                firmindex[i, 2] = 3 ## micro
            end
        else
            println("It is not an SME firm as defined!")
        end
        firmindex[i, 3] = IndVtr[fsnum[end, 1]]

        for num_i = 1:size(fsnum, 2)
            # global fsnum
            ix = findlast(fxrate[:, 1] .<= fsnum[1, num_i])
            fsnum[2:end-1, num_i] /= fxrate[ix, 2]
        end
        num[i] = vcat([nfsclaim fill(NaN, 1, size(fsnum, 2)-1)], fsnum)
    end
    VfirmInfo = zeros(m, 6)
    VfirmInfo[:, [1, 4, 5]] = firmindex
    VfirmInfo[:, 6] .= countrycode

    return num, sheetname, VfirmInfo
end
