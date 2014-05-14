function rates = predict( parameter,newFlag )

featureMatTrain = [];
labelsTrain = [];
featureMatAll = [];
labelsAll = [];

for tracing = parameter.tracingsToUse
    if newFlag
        load(parameter.tracings(tracing).featureFileNew,'featureMat','labels');
    else
        load(parameter.tracings(tracing).featureFile,'featureMat','labels');
    end
    labeledIdx = labels ~= -1;
    featureMatTrain = [featureMatTrain ; featureMat(labeledIdx,:)];
    labelsTrain = [labelsTrain ; labels(labeledIdx)];
    featureMatAll = [featureMatAll ; featureMat];
    start(tracing) = length(labelsAll)+1;
    labelsAll = [labelsAll ; labels];
    stop(tracing) = length(labelsAll);
end

% change such that unlabeled data is also predicted in cross validation to
% avoid having different probability distributions

% get crossVal results for labeled data
load(parameter.paramFile{newFlag+1},'resultParams');
[rates,predCross] = crossVal(featureMatTrain,labelsTrain,resultParams(1:3),0,4,'matlab');

% use all labeled data for prediction on unlabeled data
partition.train = labelsAll ~= -1;
partition.test = labelsAll == -1;

pred = trainAndTest(featureMatAll,labelsAll,partition,resultParams(1:3),'matlab');
% where should the probabilities be scaled...?
% pred(:,2) = mean(predCross{1}(:,2)) + (pred(:,2)-mean(pred(:,2)))*std(predCross{1}(:,2))/std(pred(:,2)); 
predAll(partition.train,1:3) = predCross{1};
predAll(partition.test,1:3) = pred;


boundary = getDecisionBoundary(predAll(:,2),0.15);
predAll(:,1) = predAll(:,2) > boundary;
tp = sum(predAll(labelsAll == 1,1))/sum(labelsAll == 1);
fp = sum(predAll(labelsAll == 0,1))/sum(labelsAll == 0);

rates = [rates tp fp];

if ~newFlag && parameter.includeNeighbors == 1
    for i = parameter.tracingsToUse
        addGraphData(parameter,predAll(start(i):stop(i),:),i);
    end
end

end

