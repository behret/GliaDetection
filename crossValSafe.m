function [rates] = crossVal(featureMat,labels,param,kfold,method)

%% prepare data

% cut off featureMat at specified size
idx = featureMat(:,1) > param(1);
labels = labels(idx,:);
featureMat = featureMat(idx,:);

gliaMat = featureMat(find(labels),:);
nonGliaMat = featureMat(find(imcomplement(labels)),:);


% prepare partition indices
glia.part = cvpartition(size(gliaMat,1),'kfold',kfold);
nonGlia.part = cvpartition(size(nonGliaMat,1),'kfold',kfold);

glia.usedIdx = [];
nonGlia.usedIdx = [];

glia.idx = 1:size(gliaMat,1);
nonGlia.idx = 1:size(nonGliaMat,1);

rates = [];

%% training and prediction

for i = 1:kfold   
    
    idxTest.glia = randsample(glia.idx,glia.part.TestSize(i));
    glia.idx = setdiff(glia.idx,idxTest.glia);
    idxTrain.glia = [glia.idx glia.usedIdx];
    glia.usedIdx = [glia.usedIdx idxTest.glia];    
    testGlia = gliaMat(idxTest.glia,:);
    trainGlia = gliaMat(idxTrain.glia,:);
    
    idxTest.nonGlia = randsample(nonGlia.idx,nonGlia.part.TestSize(i));
    nonGlia.idx = setdiff(nonGlia.idx,idxTest.nonGlia);
    idxTrain.nonGlia = [nonGlia.idx nonGlia.usedIdx];
    nonGlia.usedIdx = [nonGlia.usedIdx idxTest.nonGlia];    
    testNonGlia = nonGliaMat(idxTest.nonGlia,:);
    trainNonGlia = nonGliaMat(idxTrain.nonGlia,:);
    
    train = [trainGlia ; trainNonGlia];
    test = [testGlia ; testNonGlia];   
    labelsTrain = [ones(size(trainGlia,1),1) ; zeros(size(trainNonGlia,1),1)];
    labelsTest = [ones(size(testGlia,1),1) ; zeros(size(testNonGlia,1),1)];
    
    
    rate = trainAndTest(train,labelsTrain,test,labelsTest,param,method);
    rates = [rates ; rate];        
end


end
