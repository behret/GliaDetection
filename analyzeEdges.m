function percDel = analyzeEdges(parameter,pred,ids)

pred(:,1:5) = [pred ids];
 
for i = 1:3
    load(parameter.tracings(i).graphFile);
    idxTracingTPs = find(pred(:,1) == 1 & pred(:,3) == 1 & pred(:,4) == i);
    edges{i} = edgesNew;
    lengthOld(i) = length(edgesNew);
    for j = 1:length(idxTracingTPs)  
        id = pred(idxTracingTPs(j),5);
        [row,col] = ind2sub(size(edges{i}),find(edges{i} == id));
        edges{i}(row,:) = [];
    end
    lengthNew(i) = length(edges{i});
end


ratio = sum(lengthNew)/sum(lengthOld);
percDel = 1 - ratio;


