function rates = getRateEstimate(parameter,param,method)

%% prepare data
load(parameter.featureFile,'featureMatEval','labelsEval','featureMatParam','labelsParam');


featureMat = [featureMatEval;featureMatParam];
labels = [labelsEval;labelsParam];
sizeFlag = featureMat(:,1) > param(1);
labels = [labels  sizeFlag];

idx = find(labels(:,2) == 1);
partition.test = idx(idx <= length(labelsEval));
partition.train = idx(idx > length(labelsEval));


%% train test plot save
 
[rates,pred] = trainAndTest(featureMat,labels,partition,param,method );
%RocAndPr(pred,partition);

%print(f,'-dpdf','C:\Users\behret\Dropbox\BachelorArbeit\libRoc');
%save

end
