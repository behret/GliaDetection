function [ rates ] = RVMcross( parameter,kfold )

load(parameter.featureFile,'featureMatAll','labelStructAll');

labelStruct = labelStructAll;
labels = labelStruct.labels;
featureMat = featureMatAll;

partition = getPartition(labelStruct,0,featureMat(:,1),kfold);

pred = [];
for i = 1:kfold
    
    train = featureMat(partition(i).train,:);
    labelsTrain = labels(partition(i).train);
    test =  featureMat(partition(i).test,:);  
    labelsTest = labels(partition(i).test);
    
    TrainingDataSet = prtDataSetClass(train ,labelsTrain);
    TestDataSet = prtDataSetClass(test ,labelsTest);

    classifier = prtClassRvm;              
    tic
    classifier = classifier.train(TrainingDataSet);  
    toc
    classified = run(classifier, TestDataSet);     

    pred = [pred; classified.data > 0.5 classified.data classified.targets];
    
end
%% Plot the results

tp = sum(pred(:,1) == 1 & pred(:,3) == 1)/sum(pred(:,3));
fp = sum(pred(:,1) == 1 & pred(:,3) == 0)/(sum(pred(:,3) == 0));
rates = [tp fp];

RocAndPr( pred, labels )

end

