function [rates, pred ] = trainAndTest( featureMat,labels,partition,param,method )

train = featureMat(partition.train,:);
test =  featureMat(partition.test,:);  
labelsTrain = labels(partition.train);
labelsTest = labels(partition.test);

if strcmp(method, 'matlab')

    % convert gamma to sigma
    sigma = 1/sqrt(2*param(2));
    c = repmat(param(3),length(labelsTrain),1);
    c(labelsTrain == 1) = c(labelsTrain == 1)*param(4);    
    opt = struct('MaxIter',1000000);    
    SVMStruct = svmtrain(train,labelsTrain,'kernel_function','rbf',...
        'rbf_sigma',sigma,'boxconstraint',c,'autoscale',false,'options',opt);
    [pred,regVal] = svmclassifyR(SVMStruct,test);
    % calculate probabilities
    prob = -(regVal-min(regVal)) / (max(regVal) - min(regVal));
    pred = [pred prob labelsTest];

elseif strcmp(method, 'libsvm')

    c1 = param(4);
    optsTrain = ['-g ' num2str(param(2),'%f') ' -c ' num2str(param(3),'%f') ...
         ' -w1 ' num2str(c1,'%f') ' -q -b 1'];
    model = svmtrainLib(labelsTrain,train,optsTrain);

    optsPredict = '-b 1 -q';
    [pred, accuracy, prob_estimates] = ...
        svmpredict(labelsTest, test, model, optsPredict);
    pred = [pred prob_estimates(:,2) labelsTest];

else
    disp('Specify method correctly!');
end


% with cutoff
tp = sum(pred(pred(:,3) == 1,1))/sum(pred(:,3));
fp = sum(pred(pred(:,3) == 0,1))/sum(pred(:,3) == 0);
% for all
tpAll = sum(pred(pred(:,3) == 1,1))/sum(labels(:,1));
fpAll = sum(pred(pred(:,3) == 0,1))/sum(labels(:,1) == 0);


rates = [tp fp tpAll fpAll];

end

