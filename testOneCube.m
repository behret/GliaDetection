function [ rates ] = testOneCube(parameter,method)

load(parameter.featureFile,'featureMatAll','labelStructAll');

labelStruct = labelStructAll;
labels = labelStruct.labels;
featureMat = featureMatAll;
ids = labelStructAll.ids;


% take one whole cube for testing
partition.train = find(ids(:,1) == 2| ids(:,1) == 3);
partition.test = find(ids(:,1) == 1);
labelsTest = labels(partition.test);



%% take only half of cube for testing, other half for training too. 

%upper/lower half

load('G:\Benjamin\dataGraph\results\predCube\upperHalf');
ids = intersect(labelStruct.ids(partition.test,2),idsUpperHalf);
for i = 1:length(ids)
    idxUp(i) = find(labelStruct.ids(partition.test,2) == ids(i));
end
par2.test = partition.test(idxUp);
par2.train = setdiff(partition.test,par2.test);

%half of indices
% par2 = getPartition(divideLabelStruct(labelStruct,partition.test),2);
% par2 = par2(1);

labelsTest = labels(par2.test,:);
partition.test = par2.test;
partition.train = [partition.train ; par2.train];

%% train and test

if strcmp(method,'RVM')
    train = featureMat(partition.train,:);
    labelsTrain = labels(partition.train,:);
    test = featureMat(partition.test,:);
    labelsTest = labels(partition.test,:);
    TrainingDataSet = prtDataSetClass(train ,labelsTrain);
    TestDataSet = prtDataSetClass(test ,labelsTest);

    classifier = prtClassRvm;              
    tic
    classifier = classifier.train(TrainingDataSet);  
    toc
    classified = run(classifier, TestDataSet);     
    pred = [classified.data > 0.5 classified.data classified.targets];
elseif strcmp(method,'SVM')
    load('G:\Benjamin\dataGraph\results\results','resultParams');
    param = resultParams;
    [pred predTrain] = trainAndTest(featureMat,labels,partition,param,'matlab' );
end
    
tp = sum(pred(:,1) == 1 & pred(:,3) == 1)/sum(pred(:,3));
fp = sum(pred(:,1) == 1 & pred(:,3) == 0)/(sum(pred(:,3) == 0));
rates = [tp fp];

RocAndPr( pred, labelsTest );


end

