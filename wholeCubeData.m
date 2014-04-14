function wholeCubeData

parameter = setParam;

for i = parameter.tracingsToUse
    
    %get all segments and calculate features
    %getLabeledSegments(parameter,1);
    
    load(parameter.tracings(i).segmentAllFile);   
    matShape = miniShape(parameter,segments,i);
    matIntensity = miniIntensity(parameter,segments,i);  
    matGraph = graphFeatures(segments);   
    matCombined = cat(2,matShape,matIntensity,matGraph);
    labelStruct.labels = cell2mat({segments.label})';
    labelStruct.ids = cell2mat({segments.id})';
     
    % scale with values from feature calculation for labeled segments
    load(parameter.featureFile,'scaleVals');
    featureMat = zeros(size(matCombined));
    for feat = 1:size(matCombined,2)
        featureMat(:,feat) = (matCombined(:,feat)-scaleVals(feat,1)) / ...
            scaleVals(feat,2);
    end
    
    % delete segments that have nan values
    delList = [];
    for j = 1:size(featureMat,1)
        if any(isnan(featureMat(j,:)))
            delList(end+1) = j;
        end
    end
    featureMat(delList,:) = [];
    labelStruct.ids(delList) = [];
    labelStruct.labels(delList) = [];
    
    disp(['excluded ' num2str(length(delList)) ' segments due to nan values']);

    save(parameter.tracings(i).featuresAllFile,'featureMat','labelStruct','delList','-v7.3');   
end

end

