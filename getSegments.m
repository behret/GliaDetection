function [resultGlia,resultNonGlia] = getSegments(skel,seg,p)

    comments = skel{1}.commentsString;
    pattern = '\d+"\scontent="glia';
    GliasComments = regexp(comments,pattern,'match');

    for i=1:length(GliasComments{1})
        splits = strsplit(GliasComments{1}{i},'"');
        GliaNodeIds(i) = str2num(splits{1,1});
    end
    
    %get tree ids
    gliaTrees = [];
    for i=1:length(skel)
        clear nodes;
        for j=1:length(skel{i}.nodesAsStruct)
            nodes(j) = str2num(skel{i}.nodesAsStruct{j}.id);
        end
           
        if ~isempty(intersect(nodes,GliaNodeIds));
            gliaTrees(end+1) = skel{i}.thingID;
        end
    end
    
    %get segment ids
    glia.ids = [];
    nonGlia.ids = [];
    
    for i=1:length(skel)
    gliaFlag = any(gliaTrees == skel{i}.thingID);
        for j=1:size(skel{i}.nodes)
            localCoords = transformCoords(skel{i}.nodes(j,1:3),p,0);
            if ~any(localCoords < 0) && ~any(localCoords-size(seg) > 0)
                if gliaFlag
                    glia.ids(end+1) = seg(localCoords(1),localCoords(2),localCoords(3));
                else
                    nonGlia.ids(end+1) = seg(localCoords(1),localCoords(2),localCoords(3));
                end
            end
        end
    end
    
%     %%% analysis nodes per segment
%     commonIds = intersect(glia.ids,nonGlia.ids);
%     for i=1:length(commonIds)
%         
%         N = sum(glia.ids == commonIds(i));
%         G = sum(nonGlia.ids == commonIds(i));
%         ratio(i) = min(N,G)/max(N,G);
% %         glia.ids(glia.ids == commonIds(i)) = [];
% %         nonGlia.ids(nonGlia.ids == commonIds(i)) = [];
%     end
%     ratio = sort(ratio);
%     plot(ratio);
%     
%     
%     g = unique(glia.ids);
%     for i=1:length(g)
%         sumsG(i) = sum(glia.ids == g(i));
%     end
%     hist(sumsG,25);
%     n = unique(nonGlia.ids);
%     for i=1:length(n)
%         sumsN(i) = sum(nonGlia.ids == n(i));
%     end
%     sumsN(sumsN > 25) = [];
%     hist(sumsN,25);  
%     %%
    
    
    glia.ids = unique(glia.ids);
    nonGlia.ids = unique(nonGlia.ids);
    
    
    % eliminate ids that are present in both
    commonIds = intersect(glia.ids,nonGlia.ids);
    glia.ids = setdiff(glia.ids,commonIds);
    nonGlia.ids = setdiff(nonGlia.ids,commonIds);
    %
    % if much more in one, leave in one.. quotient-> threshold 
    %     
    
    
    % later: how many (relevant) segments missed
    % targetted annotation? loading seg in oxalis?    
    props = regionprops(seg,'PixelList');
    glia.PixelLists = props(glia.ids);
    nonGlia.PixelLists = props(nonGlia.ids);
    
    %restructure and resolve XY swap
    for i=1:length(glia.ids)
        resultGlia(i).id = glia.ids(i);
        resultGlia(i).PixelList = [glia.PixelLists(i).PixelList(:,2) glia.PixelLists(i).PixelList(:,1) glia.PixelLists(i).PixelList(:,3)];
    end 
    for i=1:length(nonGlia.ids)
        resultNonGlia(i).id = nonGlia.ids(i);
        resultNonGlia(i).PixelList = [nonGlia.PixelLists(i).PixelList(:,2) nonGlia.PixelLists(i).PixelList(:,1) nonGlia.PixelLists(i).PixelList(:,3)];
    end 
    

end

