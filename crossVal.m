function [rates] = crossVal(featureMat,labels,param,kfold,method)


%% prepare data

% cut off featureMat at specified size
sizeFlag = featureMat(:,1) > param(1);
labels = [labels  sizeFlag];
partition = getPartition(labels,kfold);

%% training and prediction
rates = [];
for i = 1:kfold     
    rate = trainAndTest(featureMat,labels,partition(i),param,method);
    rates = [rates ; rate];        
end


end
