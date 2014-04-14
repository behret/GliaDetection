function [ output_args ] = predictCubes(parameter)

for i = parameter.tracingsToUse

    %% load training data

    load(parameter.featureFile,'featureMatAll','labelStructAll');
    trainTracings = setdiff([1 2 3],i);
    train = featureMatAll(labelStructAll.ids(:,1) == trainTracings(1) | labelStructAll.ids(:,1) == trainTracings(1),:);
    labelsTrain = labelStructAll.labels(labelStructAll.ids(:,1) == trainTracings(1) | labelStructAll.ids(:,1) == trainTracings(1));

    load(parameter.tracings(i).featuresAllFile,'featureMat','labelStruct')    
    test = featureMat;
    labelsTest = labelStruct.labels;

    %% classify

    load('G:\Benjamin\dataGraph\results\results','resultParams');
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
    tp = sum(pred(pred(:,3) == 1,1))/sum(labelsTest == 1)
    fp = sum(pred(pred(:,3) == 0,1))/sum(labelsTest == 0)

    segmentsNew = addGraphData(parameter,pred,i);
    save([parameter.tracings(i).segmentFile 'New']);


end
