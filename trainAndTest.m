function [rates, pred ] = trainAndTest( featureMat,labels,partition,param,method )

%% prepare data
if isfield(partition,'trainCut')  
    train = featureMat([partition.train ; partition.trainCut],:);
    labelsTrain = labels([partition.train ; partition.trainCut]);
else
    train = featureMat(partition.train,:);
    labelsTrain = labels(partition.train);
end
test =  featureMat(partition.test,:);  
labelsTest = labels(partition.test);


%% train and test
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
    %prob = -(regVal-min(regVal)) / (max(regVal) - min(regVal));
    prob = -regVal;
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


%% calculate rates

if isfield(partition,'testCut')  
    %include cut off segments in calculation to get overall performance
    tp = sum(pred(pred(:,3) == 1,1))/(sum(labels(partition.test)) + sum(labels(partition.testCut)));
    fp = sum(pred(pred(:,3) == 0,1))/(sum(labels(partition.test) == 0) + sum(labels(partition.testCut) == 0));
else 
    tp = sum(pred(pred(:,3) == 1,1))/sum(labels(partition.test));
    fp = sum(pred(pred(:,3) == 0,1))/sum(labels(partition.test) == 0);
end

rates = [tp fp];

end

