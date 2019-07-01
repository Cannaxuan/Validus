function RetrieveFieldEnum_v011(cell_field_names, str_base, nargout)
    # cell_field_names, str_base, nargout = cell_temp, GC["FS_ANN_IDX"], 2

    sql_query = "SELECT CAST([ID] AS FLOAT), CAST(FS_Type AS FLOAT), [Field_Mnemonic] FROM [Tier2].[REF].[BBG_field_definition]"
    sql_query = sql_query* " WHERE [Field_Mnemonic] IN ($(join(cell_field_names[:],","))) ORDER BY [ID]"
    cnt = connectDB()
    cellout = get_data_from_DMTdatabase(sql_query, cnt)

    if nargout > 1
        field_numbers = Matrix(cellout[:, 1:2])
        fs_types = unique(cellout[:, 2])
    elseif nargout == 1
        field_numbers = cellout[:, 1]
        fs_types = unique(cellout[:, 2])
    else
        error("Please insert the right nargout")
    end

    nvars = size(field_numbers, 1)
    for i = 1:nvars
        str_base[cellout[i, 3]] = i
    end

    return field_numbers, fs_types
end
