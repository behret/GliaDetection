function [ output_args ] = predictCube( )

% predict whole area of upper half of first tracing region using t2 and t3
% as training data


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

% pixelLists = {segments.PixelIdxList};
% sizeLists = cellfun(@length,pixelLists);
% segments = segments(sizeLists > 1000);
% labelsTest = labelsTest(sizeLists > 1000);

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

save('G:\Benjamin\dataGraph\predictCubeFeaturesBIG') 


%% load training data
%load('G:\Benjamin\dataGraph\predictCubeFeatures') 

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

prob = -regVal;

prob  = prob - min(prob);
prob = (prob - min(prob))/(max(prob) - min(prob));
pred = [prob > 0.5 , prob , labelsTest'];
[cutVal,probCut,predCut] = sizeCutoffRVM( pred, labelsTest, 0,test(:,1),0.05);
pred = [prob > probCut , prob , labelsTest'];
predLabeled = pred(pred(:,3) ~= -1,:);
tp = sum(predLabeled(predLabeled(:,3) == 1,1))/sum(labelsTest == 1);
fp = sum(predLabeled(predLabeled(:,3) == 0,1))/sum(labelsTest == 0);
RocAndPr(predLabeled,labelsTest(pred(:,3) ~= -1)',probCut)


ids = cell2mat({segments.id})';
segmentsNew = analyzeGraph(parameter,pred,ids,1);
%analyzeGraphSave(parameter,pred(pred(:,3) ~= -1,:),ids(pred(:,3) ~= -1,:))


%% generate prob cube, KLEE
predCube = false(size(seg));
gliaCube = false(size(seg));
for i = 1:length(segmentsNew)  
    %predCube(seg == segmentsNew(i).id) = segmentsNew(i).pred(1) == 1;    
    gliaCube(seg == segmentsNew(i).id) = segmentsNew(i).label == 1;    
end

load(parameter.tracings(1).cubeFile,'raw');

figure
rawIm = uint8(raw(390:580,320:510,57));
imshow(rawIm)
hold on
green = cat(3, zeros(size(rawIm)), ones(size(rawIm)), zeros(size(rawIm)));
f = imshow(green);
predIm = predCube(390:580,320:510,57);
set(f,'AlphaData',0.2*predIm);

KLEE_v4('stack',raw(:,:,1:101),'stack_2',seg,'stack_3',predCube,'stack_4',gliaCube);


end
