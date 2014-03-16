function [ predCut,rates ] = testRVM( parameter,prob,sigma, cutVal )

%% load data
load(parameter.featureFile,'featureMatAll','labelStructAll','partition');

featureMat = featureMatAll;
labelStruct = labelStructAll;
labels = labelStruct.labels;

%% train and test

train = featureMat(partition.train,:);
labelsTrain = labels(partition.train);
test =  featureMat(partition.test,:);  
labelsTest = labels(partition.test);

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
ratioSV = length(classifier.sparseBeta)/length(classifier.beta);
pred(:,1:3) = [classified.data > prob , classified.data , classified.targets];

%% post
[mex,probCut,predCut] = sizeCutoffRVM( pred, labels(partition.test,1), cutVal,featureMat(partition.test,1),0.05);

tp = sum(predCut(:,1) == 1 & predCut(:,3) == 1)/sum(pred(:,3));
fp = sum(predCut(:,1) == 1 & predCut(:,3) == 0)/(sum(pred(:,3) == 0));
rates = [tp fp ratioSV];

end

