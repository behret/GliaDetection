function [ output_args ] = predictCube( )

%% prepare data
parameter = setParam;

load(parameter.tracings(1).cubeFile,'seg');
seg = seg(:,:,1:100);

%% get segments and calc features


load(parameter.tracings(1).segmentFile);
labeledIds = cell2mat({segments.id});
labelsForTesting =  cell2mat({segments.label});
clear segments;

% get segments
ids = unique(seg);
ids(ids == 0) = [];
props = regionprops(seg,'PixelIdxList');


for i=1:length(ids)
    segments(i).PixelIdxList = props(ids(i)).PixelIdxList;
    segments(i).id = ids(i);
    labelIdx = find(labeledIds == ids(i));
    if isempty(labelIdx)
        labelsTest(i) = -1;
    else
        labelsTest(i) = labelsForTesting(labelIdx);
    end
end 

pixelLists = {segments.PixelIdxList};
sizeLists = cellfun(@length,pixelLists);
segments = segments(sizeLists > 1000);
labelsTest = labelsTest(sizeLists > 1000);

% calc features
tic
matShape = miniShape(parameter,segments,1);
matIntensity = miniIntensity(parameter,segments,1);
toc
testMat = cat(2,matShape,matIntensity);
% scale same as training
load(parameter.featureFile,'scaleVals');

featureMatTest = zeros(size(testMat));
for feat = 1:size(testMat,2)
    scaleVals(feat,1) = min(testMat(:,feat));
    scaleVals(feat,2) = max(testMat(:,feat)) - min(testMat(:,feat));
    featureMatTest(:,feat) = (testMat(:,feat)-scaleVals(feat,1)) / ...
        scaleVals(feat,2);
end

save('G:\Benjamin\dataGraph\predictCubeFeatures') 


%% load training data

load(parameter.featureFile,'featureMatAll','labelStructAll');
train = featureMatAll(labelStructAll.ids(:,1) == 2 | labelStructAll.ids(:,1) == 3,:);
labelsTrain = labelStructAll.labels(labelStructAll.ids(:,1) == 2 | labelStructAll.ids(:,1) == 3);

test = featureMatTest;
test(:,9)= [];
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
% calculate probabilities
%prob = -(regVal-min(regVal)) / (max(regVal) - min(regVal));
prob = -regVal;
pred = [pred prob labelsTest'];
[predTrain,regValTrain] = svmclassifyR(SVMStruct,train);
predTrain = [predTrain -regValTrain labelsTrain];


predLabeled = pred(pred(:,3) ~= -1,:);
tp = sum(predLabeled(predLabeled(:,3) == 1,1))/sum(labelsTest == 1);
fp = sum(predLabeled(predLabeled(:,3) == 0,1))/sum(labelsTest == 0);


ids = cell2mat({segments.id})';
analyzeGraph(parameter,pred,ids,1)
%analyzeGraphSave(parameter,pred(pred(:,3) ~= -1,:),ids(pred(:,3) ~= -1,:))

RocAndPr(predLabeled,labelsTest(pred(:,3) ~= -1)')
RocAndPr(predTrain,labelsTrain);


%% generate prob cube, KLEE
predCube = seg;
for i = 1:length(ids)  
    predCube(predCube == ids(i)) = pred(i,2);    
end

KLEE_v4('stack',raw,'stack_2',seg,'stack_3',cubeGlia,'stack_4',predCube);

end
