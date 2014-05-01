function rates = predictCubes(parameter,newFlag)

rates = [];
for i = parameter.tracingsToUse

    %% load training data
    trainTracings = setdiff([1 2 3],i);
    train = [];
    labelsTrain = [];
    for j = trainTracings        
        if newFlag
            load(parameter.tracings(j).featureFileNew,'featureMat','labels');
        else
            load(parameter.tracings(j).featureFile,'featureMat','labels');
        end        
        train = [train ; featureMat(labels ~= -1,:)];
        labelsTrain = [labelsTrain ; labels(labels ~= -1)] ;
    end
    if newFlag
        load(parameter.tracings(i).featureFileNew,'featureMat','labels')  
    else
        load(parameter.tracings(i).featureFile,'featureMat','labels')  
    end
    test = featureMat;
    labelsTest = labels;

    %% classify

    load(parameter.paramFile);
    param = resultParams;
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
    
    % apply cutoff, choose boundary depending on prevalence
%     sizes = test(:,1);
%     prob(sizes < param(4),1) = 0;
    boundary = getDecisionBoundary(prob,0.15);    
    pred = [prob > boundary , prob , labelsTest];
    predLabeled = pred(pred(:,3) ~= -1,:);
    tp = sum(pred(pred(:,3) == 1,1))/sum(labelsTest == 1);
    fp = sum(pred(pred(:,3) == 0,1))/sum(labelsTest == 0);

    rates = [rates tp fp];
    addGraphData(parameter,pred,i);


end
