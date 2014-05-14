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

    load(parameter.paramFile{newFlag+1},'resultParams');

    partition.train = 1:length(train);
    partition.test= length(train)+1:length(train)+length(test);
    pred = trainAndTest( [train;test],[labelsTrain;labelsTest],partition,resultParams,'matlab');
    
    boundary = getDecisionBoundary(pred(:,2),0.15);    
    pred(:,1) = pred(:,2) > boundary;
    predLabeled = pred(pred(:,3) ~= -1,:);
    
    tp = sum(pred(pred(:,3) == 1,1))/sum(labelsTest == 1);
    fp = sum(pred(pred(:,3) == 0,1))/sum(labelsTest == 0);
    pr = sum(pred(pred(:,3) == 1,1))/ (sum(pred(pred(:,3) == 1,1)) + sum(pred(pred(:,3) == 0,1)));
    
    disp(['Tracing ' num2str(i) ' : (TPR, FPR, precision): ' num2str([tp fp pr],3)])

    numLabeledSegments(i) = length(labelsTest ~= -1);
    rates = [rates tp fp pr];
    if ~newFlag && parameter.includeNeighbors == 1
        addGraphData(parameter,pred,i);
    end


end

totals = numLabeledSegments(1)/sum(numLabeledSegments)*rates(1:3) + numLabeledSegments(2)/sum(numLabeledSegments)*rates(4:6) + numLabeledSegments(3)/sum(numLabeledSegments)*rates(7:9);
disp(['Total: (TPR, FPR, precision): ' num2str(totals,3)])


