tracing = 'denseHeiko';      
skelPath = ['R:\Benjamin\GliaDetection\data\' tracing '\dense.nml'];
skel = skeleton(skelPath,0);


count = 0;
com{1} = '';
for i=1:length(skel.nodesAsStruct)
    for j=1:length(skel.nodesAsStruct{i})
        if strcmp(skel.nodesAsStruct{i}{j}.comment,'1')
            count = count+1;
            skel.nodesAsStruct{i}{j}.comment = '';
        end
        if ~strcmp(skel.nodesAsStruct{i}{j}.comment,'')
            com{end+1} = skel.nodesAsStruct{i}{j}.comment;
        end
    end
end

% active node is missing
write(skel,['R:\Benjamin\GliaDetection\data\' tracing '\denseNew.nml']);
