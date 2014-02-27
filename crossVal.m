function [rates,predAll] = crossVal(featureMat,labelStruct,param,kfold,method)


%% prepare data

% cut off featureMat at specified size
partition = getPartition(labelStruct,param,featureMat(:,1),kfold);
labels = labelStruct.labels;
%% training and prediction
rates = [];
predAll = zeros(length(featureMat),3);
for i = 1:kfold     
    [rate,pred] = trainAndTest(featureMat,labels,partition(i),param,method);
    rates = [rates ; rate];     
    predAll(partition(i).test,:) = pred;
end

end