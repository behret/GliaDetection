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
        skel = skeleton(skelPath,0);
    end
    bbox = p.bboxBig;
    segments = getLabeledSegments(skel,seg,bbox);
    save(['G:\Benjamin\' tracing '\inputs'],'-v7.3');
end

%% calculate features
%load(['G:\Benjamin\' tracing '\inputs']);

featureFlag = [1 1 0];
[featureMat_unscaled,labels,idx,featureNames] = calcFeatures(segments,featureFlag,raw);
disp('done calculating features');

% scatterplots
f = figure('Visible', 'off' );
subplot(2,2,1);
scatter(featureMat_unscaled(:,2),featureMat_unscaled(:,3)); title('pc1/pc2');
subplot(2,2,2);
scatter(featureMat_unscaled(:,2),featureMat_unscaled(:,4)); title('pc1/pc3');
subplot(2,2,3);
scatter(featureMat_unscaled(:,3),featureMat_unscaled(:,4)); title('pc2/pc3');
subplot(2,2,4);
scatter(featureMat_unscaled(:,2),featureMat_unscaled(:,9)); title('pc1/concavity');
print(f,'-dpdf','R:\Benjamin\GliaDetection\stuff\Lablog\3_progress\scatter');

%scale features  
for feat = 1:size(featureMat_unscaled,2)
    featureMat(:,feat) = (featureMat_unscaled(:,feat)-min(featureMat_unscaled(:,feat))) / ...
        (max(featureMat_unscaled(:,feat)) - min(featureMat_unscaled(:,feat)));
end

clear seg raw;
save(['G:\Benjamin\' tracing '\features'],'-v7.3');


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

% parameter search
disp('starting parameter search');
for i=1:20
    sigmas(i) = 2^(i-11);
    Cs(i) = 2^(i-6);
end

for i=1:length(sigmas)
    tic
    for j=1:length(Cs)
        try
            [pred,rate] = crossVal(featureMat,labels,4,sigmas(i),Cs(j)); 
            rates{i,j} = mean(rate);
        catch
            rates{i,j} = [0,1,1,0];
        end
    end
    toc
end
 
filterFun = @(x) x(1) > 0.3 && x(3) > 0.8;
filteredRates = cellfun(filterFun,rates);
[sig c] = find(filteredRates);
scatter(sig,c);



choiceFun = @(x) x(1) + x(3) + (x(3) > 0.8);
[choiceSig,choiceC] = find(cellfun(choiceFun,rates) == max(max(cellfun(choiceFun,rates))));

[pred,rateFinal] = crossVal(featureMat,labels,4,sigmas(choiceSig),Cs(choiceC));
save(['G:\Benjamin\' tracing '\predictions'],'-v7.3');



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



