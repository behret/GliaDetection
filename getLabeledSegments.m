function getLabeledSegments(parameter)

% merges should be excluded in general...not only glia nonGlia mergers
% trees in oxalis would have to be merged..

for tracing = parameter.tracingsToUse;
    
    skel = skeleton(parameter.tracings(tracing).nml,0);
    bbox = parameter.tracings(tracing).bbox;
    load(parameter.tracings(tracing).cubeFile,'seg');
    if parameter.useGraph
        load(parameter.tracings(tracing).graphFile);
    end
    
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
    
%%%%% analysis nodes per segment   
    
    glia.ids = unique(glia.ids);
    nonGlia.ids = unique(nonGlia.ids);
    
    commonIds = intersect(glia.ids,nonGlia.ids);
    glia.ids = setdiff(glia.ids,commonIds);
    nonGlia.ids = setdiff(nonGlia.ids,commonIds);
    % exclude 0
    nonGlia.ids(nonGlia.ids == 0) = [];

    
    %% get segment pixel lists
    
    props = regionprops(seg,'PixelIdxList');
    glia.PixelIdxLists = props(glia.ids);
    nonGlia.PixelIdxLists = props(nonGlia.ids);
    
    %if graph is not used, make sure no segment gets excluded
    if ~parameter.useGraph
        edgesNew = [glia.ids nonGlia.ids];
    end
     
    %restructure
    for i=1:length(glia.ids)
        segments(i).PixelIdxList = glia.PixelIdxLists(i).PixelIdxList;
        segments(i).id = glia.ids(i);
        segments(i).label = 1;
        segments(i).inGraph = any(unique(edgesNew) == glia.ids(i));

    end 
    for i=1:length(nonGlia.ids)
        segments(length(glia.ids)+i).PixelIdxList = nonGlia.PixelIdxLists(i).PixelIdxList;
        segments(length(glia.ids)+i).id = nonGlia.ids(i);
        segments(length(glia.ids)+i).label = 0;
        segments(length(glia.ids)+i).inGraph = any(unique(edgesNew) == nonGlia.ids(i));
    end

    totalNrSegs = length(unique(seg));
    save(parameter.tracings(tracing).segmentFile,'segments','commonIds','totalNrSegs','-v7.3');
    clearvars -except parameter tracing;
    
%%%%% analysis missed segments
end
end

