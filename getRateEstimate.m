function rates = getRateEstimate(parameter,param,method)

%% prepare data
load(parameter.featureFile,'featureMatAll','labelStructAll','partition');

featureMat = featureMatAll;
labelStruct = labelStructAll;
labels = labelStruct.labels;

%% test set rates/plot
[pred predTrain ratioSV] = trainAndTest(featureMat,labels,partition,param,method );
% do cutoff
sizes = featureMat(partition.test,1);
pred = pred(sizes > param(4),:);
sizes = sizes(sizes > param(4));

tp = sum(pred(pred(:,3) == 1,1))/sum(labels(partition.test));
fp = sum(pred(pred(:,3) == 0,1))/sum(labels(partition.test) == 0);
precision = sum(pred(pred(:,3) == 1,1))/(sum(pred(pred(:,3) == 1,1))+sum(pred(pred(:,3) == 0,1)));

load('G:\Benjamin\dataGraph\features.mat', 'scaleVals');
sizesTP = sizes(pred(:,1) == 1 & pred(:,3) == 1);
sizesTP = exp(sizesTP*scaleVals(1,2)+scaleVals(1,1));
meanSize = mean(sizesTP);

cutoffs = param(4);
%[ratesCross,predCross] = crossVal(featureMat,labelStruct,param,cutoffs,4,'matlab');
%ids = labelStruct.ids(partition.test,:);
%predCross = predCross{1};
%percentage = analyzeEdges(parameter,pred,ids);
percentage = 0;

rates = [tp fp meanSize percentage ratioSV];


%% analyze seg size
%analyzeMisclassSize(featureMat,labelStruct,param)

%% analyze graph and edges
% ids = labelStruct.ids(:,2);
% analyzeGraph(parameter,predCross,ids,0);


end
