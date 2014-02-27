%% com big all

figure 
hold on

scatter(allAll(:,2),allAll(:,1),30,[1 0 0],'fill');
scatter(bigBig(:,2),bigBig(:,1),30,[0 1 0],'fill');
scatter(varyAll(:,2),varyAll(:,1),30,[0 0 1],'fill');
scatter(allAdj(:,2),allAdj(:,1),30,[0 1 1],'fill');

%legend('train big, test big' , 'train big, test all')

%% compare testBig/testAll

params = {1:4 1:15 1:15};

figure 
hold on

scatter(rateMat(combis(:,1) == 1,2),rateMat(combis(:,1) == 1,1),30,[0.5 0 1],'fill');
scatter(rateMat(combis(:,1) == 2,2),rateMat(combis(:,1) == 2,1),30,[1 0 0],'fill');
scatter(rateMat(combis(:,1) == 3,2),rateMat(combis(:,1) == 3,1),30,[0 1 1],'fill');
scatter(rateMat(combis(:,1) == 4,2),rateMat(combis(:,1) == 4,1),30,[0 0 1],'fill');
legend('10','20','30','40','Location','SouthEast');

scatter(ram(:,2),ram(:,1),30,[1 0 0],'fill');
scatter(rateMat(:,2),rateMat(:,1),30,[0 0 1],'fill');

%% % of glia left after size cutoff


for i = 1:length(quan)
    
    cutLabels = labels(featureMat(:,1) > quan(i));
    
    ratio(i,1) = sum(cutLabels)/sum(labels);
    ratio(i,2) = sum(cutLabels == 0)/sum(labels == 0);
    
end

bar(ratio)

%% plot adjustment weights

figure
hold on
scatter(rateMat(combis(:,4) < 3,2),rateMat(combis(:,4) < 3,1),10,[1 0 0]);
scatter(rateMat(combis(:,4) > 3 & combis(:,4) < 7 ,2),rateMat(combis(:,4) > 3 & combis(:,4) < 7,1),10,[0 1 0]);
scatter(rateMat(combis(:,4) > 7,2),rateMat(combis(:,4) > 7,1),10,[0 0 1]);

xlabel('% False positives');
ylabel('% True positives');
legend('<3' , '3<7','>7');


%% size cutoff colorcoded

% get combis from paramSearch

figure 
hold on;

scatter(rateMat(combis(:,1) == params{1}(1),2),rateMat(combis(:,1) == params{1}(1),1),30,[0.5 0 1],'fill');
scatter(rateMat(combis(:,1) == params{1}(2),2),rateMat(combis(:,1) == params{1}(2),1),30,[1 0 0],'fill');
scatter(rateMat(combis(:,1) == params{1}(3),2),rateMat(combis(:,1) == params{1}(3),1),30,[0 1 1],'fill');
scatter(rateMat(combis(:,1) == params{1}(4),2),rateMat(combis(:,1) == params{1}(4),1),30,[0 0 1],'fill');
scatter(rateMat(combis(:,1) == params{1}(5),2),rateMat(combis(:,1) == params{1}(5),1),30,[0 1 0],'fill');
xlim([0 0.2])

xlabel('False positive rate');
ylabel('True positive rate');
title('Cut off x% of smalles segments');
legend('0','10','20','30','40','Location','SouthEast');

%% adj colorcoded

figure 
hold on;

scatter(rateMat(combis(:,4) == params{4}(1),2),rateMat(combis(:,4) == params{4}(1),1),30,[0.5 0 1],'fill');
scatter(rateMat(combis(:,4) == params{4}(2),2),rateMat(combis(:,4) == params{4}(2),1),30,[1 0 0],'fill');
scatter(rateMat(combis(:,4) == params{4}(3),2),rateMat(combis(:,4) == params{4}(3),1),30,[0 1 1],'fill');
scatter(rateMat(combis(:,4) == params{4}(4),2),rateMat(combis(:,4) == params{4}(4),1),30,[0 0 1],'fill');
scatter(rateMat(combis(:,4) == params{4}(5),2),rateMat(combis(:,4) == params{4}(5),1),30,[0 1 0],'fill');


xlabel('% False positives');
ylabel('% True positives');
title('C adjustment ratios');
legend('0','1','2','3','4','Location','SouthEast');


%% adj/noAdj comparison
figure 
hold on;
scatter(matAdjMat(:,2),matAdjMat(:,1),20,[1 0 0]);
scatter(matNoAdj(:,2),matNoAdj(:,1),20,[0 1 0]);

xlabel('% False positives');
ylabel('% True positives');

legend('Adjusted C' , 'Same C');




%% different C adjustments

load('G:\Benjamin\data\paramSearchComp')

figure 
hold on
scatter(noAdj(:,2),noAdj(:,1),20,[1 0 0]);
scatter(adjRight(:,2),adjRight(:,1),20,[0 1 0]);
scatter(adjWrong(:,2),adjWrong(:,1),20,[0 0 1]);


%% scatter good param combis
%get combis with indexes
params = {1:5 1:15 1:15};

goodCombis = find(rates(:,1) > 0.4 & rates(:,2) < 0.03);
vals = combis(goodCombis,:);

figure
scatter3(vals(:,1),vals(:,2),vals(:,3));
xlabel('cutoff size');
ylabel('sigma');
zlabel('C');



%% plot intensities

load(['G:\Benjamin\' tracing '\inputs']);
PixelList = cell(1);
PixelList{1} = cell2mat({glia.PixelList}');
PixelList{2} = cell2mat({nGlia.PixelList}');
intensities = cell(1);
intensities{1} = raw(sub2ind(size(raw),PixelList{1}(:,1),PixelList{1}(:,2),PixelList{1}(:,3)));
intensities{2} = raw(sub2ind(size(raw),PixelList{2}(:,1),PixelList{2}(:,2),PixelList{2}(:,3)));
figure
cdfplot(intensities{1})
hold on
cdfplot(intensities{2})

figure
hist(intensities{1},50);
figure 
hist(intensities{2},50);


%% analysis missed segments

allIds = unique(bboxSeg);
allIds = allIds(allIds ~= 0);
missed.ids = setdiff(allIds,union(glia.ids,nonGlia.ids));
missed.PixelLists = props(missed.ids);
for i=1:length(missed.ids)
    resultMissed(i).id = missed.ids(i);
    resultMissed(i).PixelList = [missed.PixelLists(i).PixelList(:,2) missed.PixelLists(i).PixelList(:,1) missed.PixelLists(i).PixelList(:,3)];
end    

sizesMissed = cellfun(@length,{resultMissed.PixelList});
sizesGila = cellfun(@length,{resultGlia.PixelList});
sizesNonGlia = cellfun(@length,{resultNonGlia.PixelList});
sizesMissed = sizesMissed(sizesMissed ~= 0);

xcenters = 0:0.1:7;
hist(log10(sizesGila),xcenters);
figure
hist(log10(sizesNonGlia),xcenters);
figure
hist(log10(sizesMissed),xcenters);

%% analysis nodes per segment   
g = unique(glia.ids);
for i=1:length(g)
    sumsG(i) = sum(glia.ids == g(i));
end
hist(sumsG,25);
n = unique(nonGlia.ids);
for i=1:length(n)
    sumsN(i) = sum(nonGlia.ids == n(i));
end
sumsN(sumsN > 25) = [];
hist(sumsN,25);  


%% scatterplots

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


%% analyze wrong/right
right.glia = gliaMat(predGlia);
right.nonGlia = nonGliaMat(imcomplement(predNonGlia));
wrong.glia = gliaMat(imcomplement(predGlia));
wrong.nonGlia = nonGliaMat(predNonGlia);

path = ['R:\Benjamin\GliaDetection\histos\' tracing '\' strrep(datestr(now),':','')];
mkdir(path);
for i=1:size(wrong.glia,2)   
    fig = getHist(right.glia(:,i),wrong.glia(:,i),featureNames{i},1);
    if(i == 1)
        print(fig, '-dpsc2', [path '\analysisWrongRight_Glia']);
    else
        print(fig, '-dpsc2', [path '\analysisWrongRight_Glia'], '-append'); 
    end
end
for i=1:size(wrong.nonGlia,2)   
    fig = getHist(right.nonGlia(:,i),wrong.nonGlia(:,i),featureNames(i),1);
    if(i == 1)
        print(fig, '-dpsc2', [path '\analysisWrongRight_nonGlia']);
    else
        print(fig, '-dpsc2', [path '\analysisWrongRight_nonGlia'], '-append'); 
    end
end


%% analysis in klee
cubeGlia = getSegCube(glia,size(seg));
KLEE_v4('stack',seg,'stack_2',raw,'stack_3',cubeGlia);

gliaTP = glia(predGlia);
cubeTP = getSegCube(gliaTP,size(seg));
