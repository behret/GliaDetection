function result = predict( parameter,newFlag )

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

load(parameter.testResultFile,'resultParams');
[result,predCross] = crossVal(featureMatTrain,labelsTrain,resultParams(1:3),0,4,'matlab');

partition.train = labelsAll ~= -1;
partition.test = labelsAll == -1;

pred = trainAndTest( featureMatAll,labelsAll,partition,resultParams(1:3),'matlab');
predAll(partition.train,1:3) = predCross{1};
predAll(partition.test,1:3) = pred;

for i = parameter.tracingsToUse
    addGraphData(parameter,predAll(start(i):stop(i),:),i);
end
end

