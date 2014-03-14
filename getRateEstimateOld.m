function [rates,AUC,ratioSV] = getRateEstimate(parameter,param,method)

%% prepare data
load(parameter.featureFile,'featureMatAll','labelStructAll','partition');

featureMat = featureMatAll;
labelStruct = labelStructAll;
labels = labelStruct.labels;

%% test set rates/plot
[predTest predTrain ratioSV] = trainAndTest(featureMat,labels,partition,param,method );
%RocAndPr(predTest,labels(partition.test),predTrain,labels(partition.train));
tp = sum(predTest(predTest(:,3) == 1,1))/sum(labels(partition.test));
fp = sum(predTest(predTest(:,3) == 0,1))/sum(labels(partition.test) == 0);
ratesTest = [tp fp];

%% corss validation rates/plot
% cutoffs = param(4);
% [ratesCross,predCross] = crossVal(featureMat,labelStruct,param,cutoffs,4,'matlab');
% predCross = predCross{1};
% [AUC, x, y ,bound] = RocAndPr(predTest,labels(partition.test),predCross,labels,predTrain,labels(partition.train));
% rates = [ratesTest,ratesCross];
%% analyze seg size
%analyzeMisclassSize(featureMat,labelStruct,param)

%% analyze graph
%ids = labelStruct.ids(:,2);
%analyzeGraph(parameter,predCross,ids,0);

%% analyze edges
%analyzeEdges(parameter,predCross,labelStruct);

end
