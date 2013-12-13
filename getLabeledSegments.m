function result = getLabeledSegments(skel,seg,bbox)

    %% get traced bbox and tree ids
    comments = skel{1}.commentsString;
    patternBbox = '\d+"\scontent="bbox';
    bboxComment = regexp(comments,patternBbox,'match');
    split = strsplit(bboxComment{1}{1},'"');
    bboxNode = str2num(split{1,1});
    
   
    pattern = '\d+"\scontent="(glia|oligoden)';
    GliasComments = regexp(comments,pattern,'match');    
    for i=1:length(GliasComments{1})
        splits = strsplit(GliasComments{1}{i},'"');
        GliaNodeIds(i) = str2num(splits{1,1});
    end
    

    gliaTrees = [];
    for i=1:length(skel)
        clear nodes;
        for j=1:length(skel{i}.nodesAsStruct)
            nodes(j) = str2num(skel{i}.nodesAsStruct{j}.id);
        end
           
        if ~isempty(intersect(nodes,GliaNodeIds));
            gliaTrees(end+1) = skel{i}.thingID;
        end
        if any(nodes == bboxNode)
            bboxIdx = i;
        end
    end
    
    % +- 1 because seg has offset! if it does not, change!!!
    bboxTraced = [min(skel{bboxIdx}.nodes(:,1))+1 max(skel{bboxIdx}.nodes(:,1))-1 ; ...
        min(skel{bboxIdx}.nodes(:,2))+1 max(skel{bboxIdx}.nodes(:,2))-1 ; ...
        min(skel{bboxIdx}.nodes(:,3))+1 max(skel{bboxIdx}.nodes(:,3))-1] ;

    
    if any(bbox(:,1) - bboxTraced(:,1) > 0) || any(bbox(:,2) - bboxTraced(:,2) < 0)
        disp('seg too small!');
    end 
    
    %% get segment ids
    glia.ids = [];
    nonGlia.ids = [];
    
    for i=1:length(skel)
    if i == bboxIdx
        continue;
    end
    gliaFlag = any(gliaTrees == skel{i}.thingID);
        for j=1:size(skel{i}.nodes)
            %restrict on dense bbox, switch to local coords
            if(any(bboxTraced(:,1)' - skel{i}.nodes(j,1:3) > 0) || any(bboxTraced(:,2)' - skel{i}.nodes(j,1:3) < 0))
                continue;
            end
            localCoords = transformCoords(skel{i}.nodes(j,1:3),bbox,0);
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
    
    %% get segment pixel lists
    
    
    bboxTracedLocal = [transformCoords(bboxTraced(:,1)',bbox,0)' transformCoords(bboxTraced(:,2)',bbox,0)']; 
    bboxSeg = seg(bboxTracedLocal(1,1):bboxTracedLocal(1,2),bboxTracedLocal(2,1):bboxTracedLocal(2,2),bboxTracedLocal(3,1):bboxTracedLocal(3,2));   
    props = regionprops(bboxSeg,'PixelList');
    glia.PixelLists = props(glia.ids);
    nonGlia.PixelLists = props(nonGlia.ids);
    
     
    %restructure and resolve XY swap
    for i=1:length(glia.ids)
        result(i).id = glia.ids(i);
        result(i).PixelList = [glia.PixelLists(i).PixelList(:,2) glia.PixelLists(i).PixelList(:,1) glia.PixelLists(i).PixelList(:,3)];
        result(i).label = 1;
    end 
    for i=1:length(nonGlia.ids)
        result(length(glia.ids)+i).id = nonGlia.ids(i);
        result(length(glia.ids)+i).PixelList = [nonGlia.PixelLists(i).PixelList(:,2) nonGlia.PixelLists(i).PixelList(:,1) nonGlia.PixelLists(i).PixelList(:,3)];
        result(length(glia.ids)+i).label = 0;
    end

%%%%% analysis missed segments

    
end

