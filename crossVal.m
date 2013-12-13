function [predGlia,predNonGlia] = crossVal(gliaMat,nonGliaMat,kfold)


glia.part = cvpartition(length(gliaMat),'kfold',kfold);
nonGlia.part = cvpartition(length(nonGliaMat),'kfold',kfold);

glia.usedIdx = [];
nonGlia.usedIdx = [];

glia.idx = 1:length(gliaMat);
nonGlia.idx = 1:length(nonGliaMat);

rates = [];

for i = 1:kfold   
    
    idxTest.glia = randsample(glia.idx,glia.part.TestSize(i));
    glia.idx = setdiff(glia.idx,idxTest.glia);
    idxTrain.glia = [glia.idx glia.usedIdx];
    glia.usedIdx = [glia.usedIdx idxTest.glia];    
    testGlia = gliaMat(idxTest.glia,:);
    trainGlia = gliaMat(idxTrain.glia,:);
    
    
    idxTest.nonGlia = randsample(nonGlia.idx,nonGlia.part.TestSize(i));
    nonGlia.idx = setdiff(nonGlia.idx,idxTest.nonGlia);
    idxTrain.nonGlia = [nonGlia.idx nonGlia.usedIdx];
    nonGlia.usedIdx = [nonGlia.usedIdx idxTest.nonGlia];    
    testNonGlia = nonGliaMat(idxTest.nonGlia,:);
    trainNonGlia = nonGliaMat(idxTrain.nonGlia,:);
    
    train = [trainGlia ; trainNonGlia];
    test = [testGlia ; testNonGlia];   
    labels = [ones(size(trainGlia,1),1) ; zeros(size(trainNonGlia,1),1)];
    
    
    
    %%% LIBSVM
    SVMStruct = svmtrain(labels,train,'-b');

    
    %%%
    
    
    
    SVMStruct = svmtrain(train,labels);
    
    pred = svmclassify(SVMStruct,test);
    tp = sum(pred(1:length(testGlia)))/length(testGlia);
    fn = 1-tp;
    fp = sum(pred(length(testGlia)+1:end))/length(testNonGlia);
    tn = 1-fp;
    rates = [rates ; tp fn tn fp];
    
    for j = 1:length(pred)
        if j <= size(testGlia,1)
            predGlia(idxTest.glia(j)) = pred(j);
        else
            predNonGlia(idxTest.nonGlia(j-size(testGlia,1))) = pred(j);
        end
    end
    
end
figure
boxplot(rates(:,[1,3]));
set(gca,'XTick',[1 2])
set(gca,'XTickLabel',{'true positives','true negatives'});

end
