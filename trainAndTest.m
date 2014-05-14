function [pred ratioSV] = trainAndTest( featureMat,labels,partition,param,method )

%% prepare data

train = featureMat(partition.train,:);
labelsTrain = labels(partition.train);

test =  featureMat(partition.test,:);  
labelsTest = labels(partition.test);

%% train and test
if strcmp(method, 'matlab')

    % convert gamma to sigma, create vector with Cs
    sigma = 1/sqrt(2*param(1));
    c = repmat(param(2),length(labelsTrain),1);
    c(labelsTrain == 1) = c(labelsTrain == 1)*param(3);    
    % train and classify
    opt = struct('MaxIter',1000000);    
    SVMStruct = svmtrain(train,labelsTrain,'kernel_function','rbf',...
        'rbf_sigma',sigma,'boxconstraint',c,'autoscale',false,'options',opt);
    [pred,regVal] = svmclassifyR(SVMStruct,test);   
    % turn distance to hyperplane to probability
    prob = -regVal;
    prob = prob - min(prob);
    prob = (prob - min(prob))/(max(prob) - min(prob));
    % scale prob to .5 mean and .1 std
    scaledProb = .5 + (prob-mean(prob))*.3/std(prob); 
    pred = [pred scaledProb labelsTest];
    ratioSV = length(SVMStruct.SupportVectors)/length(labelsTrain);
    
elseif strcmp(method, 'libsvm')
    % did not use that anymore...
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



