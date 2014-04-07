function calcFeatures(parameter)

for i = parameter.tracingsToUse
    if parameter.newDataFlag
        miniFilter(parameter,i);
    end
    
    load(parameter.tracings(i).segmentFile);
    
    matShape = miniShape(parameter,segments,i);
    matIntensity = miniIntensity(parameter,segments,i);  
    %matGraph = miniGraph(parameter,segments,i);
    
    matCombined{i} = cat(2,matShape,matIntensity);
    labels{i} = cell2mat({segments.label})';
    ids{i} = [repmat(i,1,length(segments)) ; cell2mat({segments.id})]';
    if parameter.useGraph
        inGraph{i} = cell2mat({segments.inGraph})';
    end    
    save([parameter.featureFile num2str(i)],'-v7.3');
end

matAll = cat(1,matCombined{:});

labelStructAll.labels = cat(1,labels{:});
labelStructAll.ids = cat(1,ids{:});
if parameter.useGraph
    labelStructAll.inGraph = cat(1,inGraph{:});
end

% scale features  
% for prediction on whole data: scale all features together!!
featureMatAll = zeros(size(matAll));
for feat = 1:size(matAll,2)
    scaleVals(feat,1) = min(matAll(:,feat));
    scaleVals(feat,2) = max(matAll(:,feat)) - min(matAll(:,feat));
    featureMatAll(:,feat) = (matAll(:,feat)-scaleVals(feat,1)) / ...
        scaleVals(feat,2);
end

% delete features that have nan values
delList = [];
for i = 1:size(featureMatAll,2)
    if any(isnan(featureMatAll(:,i)))
        delList(end+1) = i;
    end
end
featureMatAll(:,delList) = [];

% divide into featureMat for parameter search and evalMat for getting rate
% estimates
partition = getPartition(labelStructAll,4);
partition = partition(1);

featureMat = featureMatAll(partition.train,:);
labelStruct= divideLabelStruct( labelStructAll, partition.train );

save(parameter.featureFile,'-v7.3');

end

