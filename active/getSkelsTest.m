function [glia,nonGlia] = getSkelsTest(skel)

    comments = skel{1}.commentsString;
    skel = skel(2:end);%bbox..
    %pattern = '\d+"\scontent="non-glia"';
    pattern = '\d+';
    nonGliasComments = regexp(comments,pattern,'match');

    for i=1:length(nonGliasComments{1})
        splits = strsplit(nonGliasComments{1}{i},'"');
        nonGliaNodeIds(i) = str2num(splits{1,1});
    end


    %get segment ids
    zeroOfCube = p.bboxBig(:,1)';
    glia.ids = [];
    nonGlia.ids = [];
    for i=1:length(skel)
        gliaFlag = size(intersect(skel{i}.nodesNumDataAll(:,1),nonGliaNodeIds),1) == 0;
        for j=1:size(skel{i}.nodes)
            localCoords = skel{i}.nodes(j,1:3) + [1 1 1] - zeroOfCube;
            if ~any(localCoords < 0) && ~any(localCoords-size(segNew) > 0)
                if gliaFlag
                    glia.ids(end+1) = segNew(localCoords(1),localCoords(2),localCoords(3));
                else
                    nonGlia.ids(end+1) = segNew(localCoords(1),localCoords(2),localCoords(3));
                end
            end
        end
    end
    glia.ids = unique(glia.ids);
    nonGlia.ids = unique(nonGlia.ids);

end

