function find_first_finite(data,headColumn)
    # This function chooses the first finite values [with highest priority] in
    # different columns for each unique row specified by data[headColumn].
    # uniqueCoordinateOutput indicates the location in the data columns of
    # output that are filled by values from data columns located at
    # indexChosen. The data columns are columns of data without the headColumns.

    # Author: Zhang Zhifeng [ZF]
    # Created Time: 2016-02-02
    # Last modified: 2016-09-14 by ZF

    # if isempty(data)
    #     output = Array{Float64}(0,0)
    #     uniqueCoordinateOutput = Array{Int64,2}
    #     indexChosen = Array{Int64}(0)
    #     return  output,uniqueCoordinateOutput,indexChosen
    # end
    #
    # if isempty(headColumn)||minimum(headColumn)==0
    #     if size(data,1) == 1
    #         output = data
    #         uniqueCoordinateOutput = collect(1:size(data,2))
    #         indexChosen = uniqueCoordinateOutput
    #         return output,uniqueCoordinateOutput,indexChosen
    #     end
    #     data = cat(2,ones(size(data,1),1),data)
    #     headColumn=1;
    # end

    nRowData,nColumnData = size(data)


    headData = unique(data[:,headColumn],1)

    idxData = map(x->[findfirst(headData.==x[i, headColumn]) for i=1:size(x,1)], [data])[1]

    output = fill!(Array{Float64}(size(headData,1),nColumnData), NaN)
    output[:,1:length(headColumn)] = headData
    data = data[:,setdiff(1:size(data,2),headColumn)]
    nColumnData = nColumnData - length(headColumn)

    isFiniteData = isfinite.(data)
    idxData = repmat(idxData,1,nColumnData)

    # The nonzero elements in the below matrix have two meanings. Firstly, it is()
    # finite [non-nan]. Secondly, the exact number represents the row
    # number in the headData. For example, if the number is 4, it means it
    # contributes to the 4th row in the final output.
    isFiniteData = isFiniteData.*idxData

    isFiniteDataPosition = findall([isFiniteData[[1],:];diff(isFiniteData,1)].>0)
    # The values at isFinitePosition of raw data shall be located in the
    # following coordinates in the output. However, it is possible that they
    # are not unique since there could be more than one valid field values in
    # one period from different financial statement.
    coordinateOutput = [isFiniteData[isFiniteDataPosition] floor.(Int, (isFiniteDataPosition-1)/nRowData)+1+length(headColumn)]

    # Get the unique coordinates from the fact that the first one always has
    # highest priority if has been sorted previously.
    uniqueCoordinateOutput = unique(coordinateOutput,1)
    uniqueCoordinateOutput = sortrows(uniqueCoordinateOutput,by=x->(x[1],x[2]));

    idx = map(x->[findfirst((coordinateOutput[:,1].==x[[i],1]).&(coordinateOutput[:,2].==x[[i],2])) for i=1:size(x,1)], [uniqueCoordinateOutput])[1]
    # This step is not neccessary. Just to make the output sorted.
    uniqueCoordinateOutput = sortrows(uniqueCoordinateOutput,by=x->(x[2],x[1]));
    # Transform the 2D coordinates into 1D coordinates and fill in the chosen
    # value to the output.
    #uniqueCoordinateOutput = uniqueCoordinateOutput[:,1]+(uniqueCoordinateOutput[:,2]-1)*size(headData,1)
    uniqueCoordinateOutput = sub2ind(size(output),uniqueCoordinateOutput[:,1],uniqueCoordinateOutput[:,2])
    indexChosen = isFiniteDataPosition[idx]
    indexChosen = sort(indexChosen)
    output[uniqueCoordinateOutput] = data[indexChosen]
    uniqueCoordinateOutput = uniqueCoordinateOutput-length(headData)

    # if isempty(headColumn) || minimum(headColumn)==0
    #     output = output[:,2:end]
    # end

    return output,uniqueCoordinateOutput,indexChosen
end
