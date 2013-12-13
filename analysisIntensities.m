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