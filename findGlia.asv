function [] = findGlia(seg,raw,p,skel,segments)
%ISSUES
% calc features for every object directly and drop pixellist => memory,
% parallel!

tic
%tracing = 'denseHeiko';
tracing = 'denseAlex';p.bboxBig = [1417 1717; 4739 5039; 890 1190];

%%  get segments

if(nargin < 5)
    if(nargin == 3)
        skelPath = ['R:\Benjamin\GliaDetection\data\' tracing '\dense.nml'];
        skel = readNml(skelPath,1);
    end
    bbox = p.bboxBig;
    segments = getLabeledSegments(skel,seg,bbox);
    save(['G:\Benjamin\' tracing '\inputsNew'],'-v7.3');
end

%% calculate features
%load(['G:\Benjamin\' tracing '\inputs']);

featureFlag = [1 1 1];
[featureMat,labels,idx,featureNames] = calcFeatures(segments,featureFlag,raw);
clear seg raw;
save(['G:\Benjamin\' tracing '\featuresNew'],'-v7.3');


%% plot distinction

path = ['R:\Benjamin\GliaDetection\histos\' tracing '\' strrep(datestr(now),':','')];
mkdir(path);
for i=1:size(featureMat,2)   
    fig = getHist(featureMat(find(labels),i),featureMat(find(imcomplement(labels)),i),featureNames{i});   
    if(i == 1)
        print(fig, '-dpsc2', [path '\distinction']);
    else
        print(fig, '-dpsc2', [path '\distinction'], '-append'); 
    end
end


%% train and test

%load(['G:\Benjamin\' tracing '\features']);
[predGlia,predNonGlia] = crossVal(featureMat,labels,4);
save(['G:\Benjamin\' tracing '\predictionsNew'],'-v7.3');



% analyse in KLEE
% cubeGlia = getSegCube(glia,size(seg));
% KLEE_v4('stack',seg,'stack_2',raw,'stack_3',cubeGlia);

% gliaTP = glia(predGlia);
% cubeTP = getSegCube(gliaTP,size(seg));


% analyze wrong/right
% right.glia = gliaMat(predGlia);
% right.nonGlia = nonGliaMat(imcomplement(predNonGlia));
% wrong.glia = gliaMat(imcomplement(predGlia));
% wrong.nonGlia = nonGliaMat(predNonGlia);
% 
% path = ['R:\Benjamin\GliaDetection\histos\' tracing '\' strrep(datestr(now),':','')];
% mkdir(path);
% for i=1:size(wrong.glia,2)   
%     fig = getHist(right.glia(:,i),wrong.glia(:,i),featureNames{i},1);
%     if(i == 1)
%         print(fig, '-dpsc2', [path '\analysisWrongRight_Glia']);
%     else
%         print(fig, '-dpsc2', [path '\analysisWrongRight_Glia'], '-append'); 
%     end
% end
% for i=1:size(wrong.nonGlia,2)   
%     fig = getHist(right.nonGlia(:,i),wrong.nonGlia(:,i),featureNames(i),1);
%     if(i == 1)
%         print(fig, '-dpsc2', [path '\analysisWrongRight_nonGlia']);
%     else
%         print(fig, '-dpsc2', [path '\analysisWrongRight_nonGlia'], '-append'); 
%     end
% end

toc

end



