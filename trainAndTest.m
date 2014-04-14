function [pred ratioSV] = trainAndTest( featureMat,labels,partition,param,method )

%% prepare data

train = featureMat(partition.train,:);
labelsTrain = labels(partition.train);

test =  featureMat(partition.test,:);  
labelsTest = labels(partition.test);

%% train and test
if strcmp(method, 'matlab')

    % convert gamma to sigma
    sigma = 1/sqrt(2*param(1));
    c = repmat(param(2),length(labelsTrain),1);
    c(labelsTrain == 1) = c(labelsTrain == 1)*param(3);    
    opt = struct('MaxIter',1000000);    
    SVMStruct = svmtrain(train,labelsTrain,'kernel_function','rbf',...
        'rbf_sigma',sigma,'boxconstraint',c,'autoscale',false,'options',opt);
    [pred,regVal] = svmclassifyR(SVMStruct,test);
    prob = -regVal;
    prob = prob - min(prob);
    prob = (prob - min(prob))/(max(prob) - min(prob));
 
    pred = [pred prob labelsTest];
    ratioSV = length(SVMStruct.SupportVectors)/length(labelsTrain);
elseif strcmp(method, 'libsvm')

    c1 = param(3);
    optsTrain = ['-g ' num2str(param(1),'%f') ' -c ' num2str(param(2),'%f') ...
         ' -w1 ' num2str(c1,'%f') ' -q -b 1'];
    model = svmtrainLib(labelsTrain,train,optsTrain);

    optsPredict = '-b 1 -q';
    [pred, accuracy, prob_estimates] = ...
        svmpredict(labelsTest, test, model, optsPredict);
    pred = [pred prob_estimates(:,2) labelsTest];

else
    disp('Specify method correctly!');
end



