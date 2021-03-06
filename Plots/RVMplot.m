function [ rates,pred,AUC,ratioSV ] = RVMplot(parameter,kfold,sigma)

load(parameter.featureFile,'featureMatAll','labelStructAll');

labelStruct = labelStructAll;
labels = labelStruct.labels;
featureMat = featureMatAll;

if parameter.numFeatures ~= 158
    load('featureFilterGraph');
    idx(idx ==1) = [];
    idx = [1 idx];
    featureMat = featureMat(:,idx(1:parameter.numFeatures));
end

partition = getPartition(labelStruct,kfold);

for i = 1:kfold
    
    train = featureMat(partition(i).train,:);
    labelsTrain = labels(partition(i).train);
    test =  featureMat(partition(i).test,:);  
    labelsTest = labels(partition(i).test);
    
    TrainingDataSet = prtDataSetClass(train ,labelsTrain);
    TestDataSet = prtDataSetClass(test ,labelsTest);

    classifier = prtClassRvm; 
    % set sigma for RBF kernel
    rbf = prtKernelRbf;
    rbf.sigma = sigma;
    kernSet = prtKernelDirect & rbf;
    classifier.kernels = kernSet;
 
    classifier = classifier.train(TrainingDataSet);  
    classified = run(classifier, TestDataSet);     
    ratioSV(i) = length(classifier.sparseBeta)/length(classifier.beta);
    pred(partition(i).test,1:3) = [classified.data > 0.5 classified.data classified.targets];
    
end
%% Plot the results
tp = sum(pred(:,1) == 1 & pred(:,3) == 1)/sum(pred(:,3));
fp = sum(pred(:,1) == 1 & pred(:,3) == 0)/(sum(pred(:,3) == 0));
rates = [tp fp];

cutoffs = [0 0.26:0.01:0.35];
[mex,prob,predCut] = sizeCutoffRVM( pred, labels, cutoffs,featureMat(:,1),fp);
[AUC x y bound] = RocAndPrRVM( pred, labels, 0.5, predCut,prob);