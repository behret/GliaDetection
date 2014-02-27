function calcFeatures(parameter)

% calculate shape and intensity features
for i = parameter.tracingsToUse
    load(parameter.tracings(i).segmentFile);
    
    matShape = miniShape(parameter,segments,i);
    
    %miniEdges(parameter,i);
    matIntensity = miniIntensity(parameter,segments,i);

    matCombined{i} = cat(2,matShape,matIntensity);
    labels{i} = cell2mat({segments.label})';
    ids{i} = [repmat(i,1,length(segments)) ; cell2mat({segments.id})]';
    inGraph{i} = cell2mat({segments.inGraph})';

end

matAll = cat(1,matCombined{:});

labelStructAll.labels = cat(1,labels{:});
labelStructAll.ids = cat(1,ids{:});
labelStructAll.inGraph = cat(1,inGraph{:});


% scale features  
% for prediction on whole data: scale all features together!!
featureMatAll = zeros(size(matAll));
for feat = 1:size(matAll,2)
    featureMatAll(:,feat) = (matAll(:,feat)-min(matAll(:,feat))) / ...
        (max(matAll(:,feat)) - min(matAll(:,feat)));
end

% post processing
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

