function segments = getLabeledSegments(parameter)

for tracing = parameter.tracingsToUse
    
    skel = skeleton(parameter.tracings(tracing).nml,0);
    bbox = parameter.tracings(tracing).bbox;
    load(parameter.tracings(tracing).cubeFile,'seg');
    load(parameter.tracings(tracing).graphFile);
    graphData = [edgesNew pNew];
    
    %% get tree ids

    gliaTrees = [];
    for i=1:length(skel.nodesAsStruct)
        for j=1:length(skel.nodesAsStruct{i})
            if strcmp(skel.nodesAsStruct{i}{j}.comment,'glia') || strcmp(skel.nodesAsStruct{i}{j}.comment,'Glia') 
                gliaTrees(end+1) = skel.thingIDs(i);
                continue;
            end
        end
    end
    
    idxBbox = find(cellfun(@(x) strcmp('bbox',x),skel.names));
    
    %% get segment ids
    glia.ids = [];
    nonGlia.ids = [];
    
    for i=1:length(skel.nodes)
        if i == idxBbox
            continue;
        end
        gliaFlag = any(gliaTrees == skel.thingIDs(i));
        for j=1:size(skel.nodes{i})
            %restrict on bbox, switch to local coords
            if(any(bbox(:,1)' - skel.nodes{i}(j,1:3) > 0) || any(bbox(:,2)' - skel.nodes{i}(j,1:3) < 0))
                continue;
            end
            localCoords = transformCoords(skel.nodes{i}(j,1:3),bbox,0);
            if gliaFlag
                glia.ids(end+1) = seg(localCoords(1),localCoords(2),localCoords(3));
            else
                nonGlia.ids(end+1) = seg(localCoords(1),localCoords(2),localCoords(3));
            end           
        end
    end

    % resolve id ambiguities if ratio is small enough
    commonIds = intersect(glia.ids,nonGlia.ids);
    for i=1:length(commonIds)
        
        N(i) = sum(glia.ids == commonIds(i));
        G(i) = sum(nonGlia.ids == commonIds(i));
        ratio(i) = min(N(i),G(i))/max(N(i),G(i));
    end
        nodesPerSeg = [N;G;ratio;commonIds];  
        corrected = nodesPerSeg(:,nodesPerSeg(3,:) < 0.15);
        
    for i=1:length(corrected)
        if corrected(1,i) > corrected(2,i)
            nonGlia.ids(nonGlia.ids == corrected(4,i)) = [];
        else
            glia.ids(glia.ids == corrected(4,i)) = [];
        end
    end  
    
    glia.ids = unique(glia.ids);
    nonGlia.ids = unique(nonGlia.ids);
    
    commonIds = intersect(glia.ids,nonGlia.ids);
    glia.ids = setdiff(glia.ids,commonIds);
    nonGlia.ids = setdiff(nonGlia.ids,commonIds);
    % exclude 0
    nonGlia.ids(nonGlia.ids == 0) = [];

    
    %% build segments struct    
    props = regionprops(seg,'PixelIdxList');
    
    ids = [glia.ids nonGlia.ids];
    allIds = unique(seg);
    unlabeledIds = setdiff(allIds,[glia.ids nonGlia.ids]);
    unlabeledIds(unlabeledIds == 0) = [];
    ids = [glia.ids nonGlia.ids unlabeledIds'];
    
    for i=1:length(ids)      
        if i <= length(glia.ids)     
            segments(i).label = 1;
        elseif  i <= length(glia.ids) + length(nonGlia.ids)
            segments(i).label = 0;
        else
            segments(i).label = -1;
        end
        
        segments(i).PixelIdxList = props(ids(i)).PixelIdxList;
        segments(i).id = ids(i);       
        % graph info
        [rows,cols] = ind2sub(size(graphData),find(graphData == ids(i)));
        edges = graphData(rows,:);
        neighbors = setdiff(unique([edges(:,1) ; edges(:,2)]),ids(i));
        neighborMat = [];     
        for j = 1:length(neighbors) 
            [rows,cols] = ind2sub(size(edges),find(edges == neighbors(j)));
            connProb = edges(rows(1),3);     %there might be duplicates..take first one                           
            neighborMat(j,1:2) = [neighbors(j) connProb];
        end
        segments(i).neighborMat = neighborMat;
    end 
    totalNrSegs = length(unique(seg));
    save(parameter.tracings(tracing).segmentFile,'segments','commonIds','totalNrSegs','-v7.3');  
    clearvars -except parameter tracing includeUnlabeled;
    
end
end

