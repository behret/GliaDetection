function segments = addGraphData( parameter,pred,tracing )


%% prepare data

load(parameter.tracings(tracing).segmentAllFile,'segments');
load(parameter.tracings(tracing).featuresAllFile,'delList');
load(parameter.tracings(tracing).graphFile);
graphData = [edgesNew pNew];

allIds = cell2mat({segments.id});
deletedIds = allIds(delList);
ids = allIds(setdiff(1:length(allIds),delList))';
segments(delList) = [];

%% write data into segment struct


for i = 1:length(segments)     
    % get label and pred for segment
    segments(i).label = pred(i,3);
    segments(i).pred = pred(i,1:2);       
    % get predictions of neighbors: neighborMat [id connectionPorb label pred predVal]
    delEdge = []; % delete edges to segments without features
    for j = 1:size(segments(i).neighborMat) 
        if any(segments(i).neighborMat(j,1) == deletedIds)
            delEdge = [delEdge j]; 
        else
            neighborIdx = find(ids == segments(i).neighborMat(j,1));
            predNeighbor = pred(neighborIdx,1:2);              
            labelNeighbor = pred(neighborIdx,3);                
            segments(i).neighborMat(j,3:5) = [labelNeighbor predNeighbor];
        end
    end
    segments(i).neighborMat(delEdge,:) = [];
end

end

