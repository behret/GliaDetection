function [ rates,pred,AUC,ratioSV ] = RVMcross(parameter,kfold,sigma)

load(parameter.featureFile,'featureMat','labelStruct');

labels = labelStruct.labels;
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

% set decision boundary to be at 0.05 FPR
[mex,prob,pred] = sizeCutoffRVM( pred, labels, 0,featureMat(:,1),0.05);

tp = sum(pred(:,1) == 1 & pred(:,3) == 1)/sum(pred(:,3));
fp = sum(pred(:,1) == 1 & pred(:,3) == 0)/(sum(pred(:,3) == 0));


% get bet cutoff value
cutoffs = [0 0.2:0.01:0.4];
[cutVal,probCut,predCut] = sizeCutoffRVM( pred, labels, cutoffs,featureMat(:,1),0.05);
%[AUC x y bound] = RocAndPrRVM( pred, labels, prob, predCut,probCut);

tpCut = sum(predCut(:,1) == 1 & predCut(:,3) == 1)/sum(pred(:,3));
fpCut = sum(predCut(:,1) == 1 & predCut(:,3) == 0)/(sum(pred(:,3) == 0));
rates = [tp fp cutVal prob tpCut fpCut cutVal probCut];

%testRVM(parameter,prob,sigma );
%save(parameter.testResultFile,'-v7.3');

end

