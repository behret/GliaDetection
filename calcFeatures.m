function [ featureMat,labels ] = calcFeatures(parameter)

% calculate shape and intensity features
for i = parameter.tracingsToUse
    load(parameter.tracings(i).segmentFile);
    
    matShape = miniShape(parameter,segments,i);
    
    %miniEdges(parameter,i);
    matIntensity = miniIntensity(parameter,segments,i);

    matCombined{i} = cat(2,matShape,matIntensity);
    segLabels{i} = cell2mat({segments.label});
end

matAll = cat(1,matCombined{:});
labels = cat(2,segLabels{:});


% scale features  
featureMat = zeros(size(matAll));
for feat = 1:size(matAll,2)
    featureMat(:,feat) = (matAll(:,feat)-min(matAll(:,feat))) / ...
        (max(matAll(:,feat)) - min(matAll(:,feat)));
end

% post processing
delList = [];
for i = 1:size(featureMat,2)
    if any(isnan(featureMat(:,i)))
        delList(end+1) = i;
    end
end
featureMat(:,delList) = [];


% split in param search and evaluation file 
% (to avoid hyperparameter overfitting)
glia = featureMat(labels == 1,:);
nonGlia = featureMat(labels == 0,:);

idxEval.glia = randsample(length(glia),floor(length(glia)/4));
idxParam.glia = setdiff(1:length(glia),idxEval.glia);
idxEval.nonGlia = randsample(length(nonGlia),floor(length(nonGlia)/4));
idxParam.nonGlia = setdiff(1:length(nonGlia),idxEval.nonGlia);

featureMatEval = [glia(idxEval.glia,:) ; nonGlia(idxEval.nonGlia,:)];
labelsEval = [ones(length(idxEval.glia),1) ; zeros(length(idxEval.nonGlia),1)];
featureMatParam = [glia(idxParam.glia,:) ; nonGlia(idxParam.nonGlia,:)];
labelsParam = [ones(length(idxParam.glia),1) ; zeros(length(idxParam.nonGlia),1)];

save(parameter.featureFile,'-v7.3');

end

