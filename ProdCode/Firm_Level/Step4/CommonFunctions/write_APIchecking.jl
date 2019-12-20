function write_APIchecking(G_CONST::Dict{Any,Any}, thisGrp::Int64,thisstep::Int64,modulename::String)
    if !isfile(G_CONST["forAPIcheck"])
        src=G_CONST["forAPIcheck_tmp"];
        dst=G_CONST["forAPIcheck"];
        cp(src,dst)
    end
    da = readdlm(G_CONST["forAPIcheck"], ',')
    if thisGrp!=0
        groupCol=Int(G_CONST["GrpAPICol"][thisGrp])
        stepRow=G_CONST[modulename][thisstep]
        da[stepRow,groupCol] = 1;
        #writecsv(G_CONST["forAPIcheck"],da)
        writedlm(G_CONST["forAPIcheck"],da, ',')
    end
    if thisGrp==0
        stepRow=G_CONST[modulename][thisstep]
        da[stepRow,collect(3:8)].=1;
        writedlm(G_CONST["forAPIcheck"],da, ',')
    end

end
