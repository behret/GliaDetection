function [result,predAll] = crossVal(featureMat,labels,param,cutoffs,kfold,method)


%% prepare data

partition = getPartition(labels,kfold);


%% training and prediction
for i = 1:kfold     
    prediction{i} = trainAndTest(featureMat,labels,partition(i),param,method);
end

%% calculate rates

for i = 1:kfold 
    for j = 1:length(cutoffs)  
        % apply cutoff
        pred = prediction{i};
        sizeFlag = featureMat(partition(i).test,1) < cutoffs(j);
        pred(sizeFlag == 1,1) = 0;
        pred(sizeFlag == 1,2) = 0;
        
        % include precision, tp at 5% FPR
        tp = sum(pred(pred(:,3) == 1,1))/sum(labels(partition(i).test));
        fp = sum(pred(pred(:,3) == 0,1))/sum(labels(partition(i).test) == 0);
        prec = sum(pred(pred(:,3) == 1,1)) / (sum(pred(pred(:,3) == 1,1)) + sum(pred(pred(:,3) == 0,1)));
        
        boundary = getDecisionBoundary(pred(:,2),0.05,pred(:,3));
        pred(:,1) = pred(:,2) > boundary;
        tp5 = sum(pred(pred(:,3) == 1,1))/sum(labels(partition(i).test));
        fp5 = sum(pred(pred(:,3) == 0,1))/sum(labels(partition(i).test) == 0);
        prec5 = sum(pred(pred(:,3) == 1,1)) / (sum(pred(pred(:,3) == 1,1)) + sum(pred(pred(:,3) == 0,1)));

        rates{i,j} = [tp fp prec tp5 fp5 prec5];
        predAll{j}(partition(i).test,1:3) = pred;
    end
end

for i = 1:length(cutoffs) 
    result(i,1:6) = mean(cell2mat(rates(:,i)));
end


end