function [result,predAll] = crossVal(featureMat,labelStruct,param,cutoffs,kfold,method)


%% prepare data

partition = getPartition(labelStruct,kfold);
labels = labelStruct.labels;


%% training and prediction
for i = 1:kfold     
    prediction{i} = trainAndTest(featureMat,labels,partition(i),param,method);
end


%% calculate rates

for i = 1:kfold 
    for j = 1:length(cutoffs)  
        % exclude prediction under cutoff
        pred = prediction{i};
        sizeFlag = featureMat(partition(i).test,1) < cutoffs(j);
        pred(sizeFlag == 1,1) = 0;

        tp = sum(pred(pred(:,3) == 1,1))/sum(labels(partition(i).test));
        fp = sum(pred(pred(:,3) == 0,1))/sum(labels(partition(i).test) == 0);
     

        rates{i,j} = [tp fp];
        predAll{j}(partition(i).test,1:3) = pred;
    end
end

for i = 1:length(cutoffs) 
    result(i,1:2) = mean(cell2mat(rates(:,i)));
end


end