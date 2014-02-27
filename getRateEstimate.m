function rates = getRateEstimate(parameter,param,method)

%% prepare data
load(parameter.featureFile,'featureMatAll','labelStructAll','partition');


featureMat = featureMatAll;
labelStruct = labelStructAll;
labels = labelStruct.labels;

if param(1) ~= 0
    labelStruct.sizeFlag = featureMat(:,1) >= param(1);
    partition.testCut = [];
    partition.test = setdiff(partition.test,partition.testCut);  
    partition.trainCut = [];
    partition.test = setdiff(partition.test,partition.testCut);
end
%% train test plot save
% [rates,pred] = trainAndTest(featureMat,labels,partition,param,method );

% % include cutoff segments for evaluation
% if isfield(partition,'testCut') 
%     labelsForPlots = labelStruct.labels([partition.test partition.testCut]);
% else
%     labelsForPlots = labelStruct.labels(partition.test);
% end
% RocAndPr(pred,labelsForPlots);

% %% analyze graph
[r,pred] = crossVal(featureMat,labelStruct,param,4,'matlab');
% analyzeGraph(parameter,pred,labelStruct,partition);
% 
% 
%% analyze seg size

misclassIdx = find(pred(:,1) ~= pred(:,3));
misclassType = pred(misclassIdx,1);
featTest = featureMat(partition.test);
featTest = featureMat(:,1);


%BETTER: DO QUAN OVER TP??
tpIdx = pred(:,1) == 1 & pred(:,3) == 1;
quan = quantile(featTest(tpIdx,1),9);
quan2 = quantile(featTest(:,1),9);


for i =1:length(quan)+1
    if i == 1
        nrSegFP(i) = sum(featTest(misclassIdx(misclassType == 1),1) < quan(i));
        nrSegFN(i) = sum(featTest(misclassIdx(misclassType == 0),1) < quan(i));
        nrSegTP(i) = sum(featTest(tpIdx,1) < quan(i));
    elseif i == 10
        nrSegFP(i) = sum(featTest(misclassIdx(misclassType == 1),1) > quan(i-1));
        nrSegFN(i) = sum(featTest(misclassIdx(misclassType == 0),1) > quan(i-1));
        nrSegTP(i) = sum(featTest(tpIdx,1) > quan(i-1));
    else
        nrSegFP(i) = sum(featTest(misclassIdx(misclassType == 1),1) > quan(i-1) & featTest(misclassIdx(misclassType == 1),1) < quan(i));
        nrSegFN(i) = sum(featTest(misclassIdx(misclassType == 0),1) > quan(i-1) & featTest(misclassIdx(misclassType == 0),1) < quan(i));
        nrSegTP(i) = sum(featTest(tpIdx,1) > quan(i-1) & featTest(tpIdx,1) < quan(i));
    end
end
figure
bar([nrSegFP/sum(nrSegFP) ; nrSegFN/sum(nrSegFN)]','grouped' );
legend('FP','FN');
xlabel( 'Equally sized buckets with ascending segment size');
ylabel( 'Percent of total FP/FN');

% totalSizes = hist(featTest(:,1),0.1:0.1:1);
% misclassSizesFN = hist(featTest(misclassIdx(misclassType == 0),1),0.1:0.1:1);
% misclassSizesFP = hist(featTest(misclassIdx(misclassType == 1),1),0.1:0.1:1);
% 
% figure
% bar([misclassSizesFP./totalSizes],'stacked')
% figure
% bar([misclassSizesFN./totalSizes],'stacked')
% figure
% bar([misclassSizesFN./totalSizes ; misclassSizesFP./totalSizes]','stacked')
% print(f,'-dpdf','C:\Users\behret\Dropbox\BachelorArbeit\libRoc');
% save

end
