function [predAll,rates] = crossVal(featureMat,labels,kfold,sigma,C)


gliaMat = featureMat(find(labels),:);
nonGliaMat = featureMat(find(imcomplement(labels)),:);

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
    
    
    
%     %%% LIBSVM
%     model = svmtrain(labels,train);
%     labelsTest = [ones(size(testGlia,1),1) ; zeros(size(testNonGlia,1),1)];
%     predicted_label = svmpredict(labelsTest,test,model);
%     
%     %%%
    
    
    
    SVMStruct = svmtrain(train,labels,'kernel_function','rbf','rbf_sigma',sigma,'boxconstraint',C);
    
    [pred,regVal] = svmclassifyR(SVMStruct,test);
    tp = sum(pred(1:length(testGlia)))/length(testGlia);
    fn = 1-tp;
    fp = sum(pred(length(testGlia)+1:end))/length(testNonGlia);
    tn = 1-fp;
    rates = [rates ; tp fn tn fp];
    
    for j = 1:length(pred)
        if j <= size(testGlia,1)
            predAll(idxTest.glia(j),1:3) = [pred(j) regVal(j) 1];
        else
            predAll(idxTest.nonGlia(j-size(testGlia,1))+length(gliaMat),1:3) = [pred(j) regVal(j) 0];
        end
    end
    
end

% % boxplot
% figure
% boxplot(rates(:,[1,3]));
% set(gca,'XTick',[1 2])
% set(gca,'XTickLabel',{'true positives','true negatives'});
% 
% % ROC
% [a b] = sort(predAll(:,2));
% c = predAll(b,:);
% positives = c(c(:,1) == 1,:);
% TP = positives(positives(:,3) == 1);
% FP = positives(positives(:,3) == 0);
% 
% val.pos = 0;
% val.neg = 0;
% val.stepPos = 1/length(TP);
% val.stepNeg = 1/length(FP);
% 
% for i = 1: length(positives)
%     if positives(i,3)
%         val.pos = val.pos + val.stepPos;
%     else
%         val.neg = val.neg + val.stepNeg;
%     end
%     x(i) = val.neg;
%     y(i) = val.pos;
% end
% 
% figure
% plot(x,y,[0 1],[0 1]);
% xlim([0 1]);
% ylim([0 1]);



end
