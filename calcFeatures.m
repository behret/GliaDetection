function calcFeatures(parameter)

for i = parameter.tracingsToUse
    
    if parameter.newDataFlag
        miniFilter(parameter,i);
    end
    
    load(parameter.tracings(i).segmentFile);
    
    matShape = miniShape(parameter,segments,i);
    matIntensity = miniIntensity(parameter,segments,i);  
    matGraph = graphFeatures(segments);
    
    featuresAll{i} = cat(2,matShape,matIntensity,matGraph);
    labelsAll{i} = cell2mat({segments.label})';
    idsAll{i} = [repmat(i,1,length(segments)) ; cell2mat({segments.id})]';
    
    maxVals(i,1:size(featuresAll{i},2)) = max(featuresAll{i});
    minVals(i,1:size(featuresAll{i},2)) = min(featuresAll{i});
    
    % delete segments that have nan values
    delList{i} = [];
    for j = 1:size(featuresAll{i},1)
        if any(isnan(featuresAll{i}(j,:)))
            delList{i}(end+1) = j;
        end
    end
    featuresAll{i}(delList{i},:) = [];
    idsAll{i}(delList{i},:) = [];
    labelsAll{i}(delList{i}) = [];
    disp(['excluded ' num2str(length(delList{i})) ' segments due to nan values']);
    
end

% scale and save features  
scaleVals(1,1:length(minVals)) = min(minVals);
scaleVals(2,1:length(maxVals)) = max(maxVals) - min(minVals);
save(parameter.scaleValFile, 'scaleVals');

for i = 1:length(featuresAll)
    delSegIdx = delList{i};
    labels = labelsAll{i};
    ids = idsAll{i};    
    featureMat = zeros(size(featuresAll{i}));
    for feat = 1:size(featureMat,2)
        featureMat(:,feat) = (featuresAll{i}(:,feat)-scaleVals(1,feat)) / ...
            scaleVals(2,feat);
    end
    save(parameter.tracings(i).featureFile,'featureMat','labels','ids','delSegIdx','-v7.3');  
end

end

