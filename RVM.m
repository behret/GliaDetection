function [ output_args ] = RVM( input_args )

load(parameter.featureFile,'featureMatEval','labelsEval','featureMatParam','labelsParam');


idx = featureMatParam(:,1) > 0.35;
labelsParam = labelsParam(idx,:);
featureMatParam = featureMatParam(idx,:);

idx = featureMatEval(:,1) > 0.35;
labelsEval = labelsEval(idx,:);
featureMatEval = featureMatEval(idx,:);



TrainingDataSet = prtDataSetClass(featureMatParam ,labelsParam);
TestDataSet = prtDataSetClass(featureMatEval ,labelsEval);


classifier = prtClassRvm;              
tic
classifier = classifier.train(TrainingDataSet);  
toc
classified = run(classifier, TestDataSet);     
% allGliaSet = prtDataSetClass(featureMat(labels == 1,:));
% allNonGliaSet = prtDataSetClass(featureMat(labels == 0,:));

%% Plot the results

pred = [classified.data > 0.5 classified.data classified.targets];

tp = sum(pred(:,1) == 1 & pred(:,3) == 1)/sum(pred(:,3));
fp = sum(pred(:,1) == 1 & pred(:,3) == 0)/(sum(pred(:,3) == 0));
rates = [tp fp];

labelsTest = classified.targets;


% ROC and PR
[a b] = sort(pred(:,2),'descend');
predSorted = pred(b,:);
positives = predSorted(predSorted(:,1) == 1,:);
positives = predSorted;
TP = positives(positives(:,3) == 1);
FP = positives(positives(:,3) == 0);


roc.pos = 0;
roc.neg = 0;
roc.stepPos = 1/sum(labelsTest);
roc.stepNeg = 1/sum(labelsTest == 0);

pr.total = sum(labelsTest);
pr.found = 0;
pr.tp = 0;
for i = 1: length(positives)
    %ROC
    if positives(i,3)
        roc.pos = roc.pos + roc.stepPos;
    else
        roc.neg = roc.neg + roc.stepNeg;
    end
    x(1,i) = roc.neg;
    y(1,i) = roc.pos;

    %PR  
    pr.tp = pr.tp + positives(i,3);
    x(2,i) = pr.tp/pr.total;
    y(2,i) = pr.tp/i;
end

figure
subplot(1,2,1)
plot(x(1,:),y(1,:),[0 1],[0 1]);
xlim([0 1]);
ylim([0 1]);
xlabel('False positive rate');
ylabel('True positive rate');
title('ROC');

% uistr(1) = {['% True Positives: ' num2str(rates(1),'%1.2f')]};
% uistr(2) = {['% False Positives: ' num2str(rates(2),'%1.2f') ]};
% uicontrol('Style','text','Position',[370 70 120 30],...
%           'String',uistr);

subplot(1,2,2)
plot(x(2,:),y(2,:));

xlim([0 1]);
ylim([0 1]);
xlabel('Recall');
ylabel('Precision');
title('Precision - Recall');


%%

% whats the difference???
[pf,pd] = prtScoreRoc(classified,TestDataSet);
h = plot(pf,pd,[0 1],[0 1],'linewidth',1);
title('ROC'); xlabel('Pf'); ylabel('Pd');



end

