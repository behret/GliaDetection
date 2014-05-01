function result = predictTest(parameter,newFlag)


featureMatAll = [];
labelsAll = [];

for tracing = parameter.tracingsToUse
    if newFlag
        load(parameter.tracings(tracing).featureFileNew,'featureMat','labels');
    else
        load(parameter.tracings(tracing).featureFile,'featureMat','labels');
    end
    labeledIdx = labels ~= -1;
    featureMatAll = [featureMatAll ; featureMat(labeledIdx,:)];
    labelsAll = [labelsAll ; labels(labeledIdx)];
end

load(parameter.paramFile);
[result,predAll] = crossVal(featureMatAll,labelsAll,resultParams(1:3),resultParams(4),4,'matlab');