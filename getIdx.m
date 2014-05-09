function idx = getIdx(neighborMat,ids,typ)

    if strcmp(typ,'min')
        fun = @min;
    elseif strcmp(typ,'max')
        fun = @max;
    elseif strcmp(typ,'med')
        fun = @(x) min(abs(x - median(x)));
    end

    [va, index] = fun(neighborMat(:,2));
    idx = find(ids(:,2) == neighborMat(index,1));
    if isempty(idx)
        neighborMat(index,:) = [];
        idx = getIdx(neighborMat,ids,typ);
    end

end