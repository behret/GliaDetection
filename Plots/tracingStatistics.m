
function stats = tracingStatistics(parameter)

for tracing= 1:3

    clear segments;
    load(parameter.tracings(tracing).segmentFile);
    labels = cell2mat({segments.label});
    idxGlia = labels == 1;
    idxNon = labels == 0;
    pixelLists = {segments.PixelIdxList};
    % mean seg size
%     stats(tracing,1) = mean(log(cellfun(@length,pixelLists(idxGlia))));
%     stats(tracing,2) = mean(log(cellfun(@length,pixelLists(idxNon))));
%     stats(tracing,3) = mean(log(cellfun(@length,pixelLists)));
%     stats(tracing,4) = median(log(cellfun(@length,pixelLists)));

    % num segments & lost segments & ambiguous segments
    stats(tracing,1) = totalNrSegs;
    stats(tracing,2) = length(labels);
    stats(tracing,3) = length(commonIds);
    stats(tracing,4) = length(labels) / totalNrSegs;
    allVox = (parameter.tracings(tracing).bbox(1,2)- parameter.tracings(tracing).bbox(1,1)) * ...
        (parameter.tracings(tracing).bbox(2,2)- parameter.tracings(tracing).bbox(2,1)) * ...
        (parameter.tracings(tracing).bbox(3,2)- parameter.tracings(tracing).bbox(3,1));
    stats(tracing,5) =  sum(cellfun(@length,pixelLists)) / allVox;

    
    % ratio voxel & ratio segments
    stats(tracing,6) = sum(cellfun(@length,pixelLists(idxGlia)))/sum(cellfun(@length,pixelLists(idxNon)));
    stats(tracing,7) = sum(idxGlia)/sum(idxNon);

    % how many get joined in GP and their size distribution
    
end

% totals / averages
stats(4,1:3) = sum(stats(:,1:3)); 

colsAv = 4:7;
averages = zeros(1,length(colsAv));
for i = 1:3
    averages = averages + stats(i,1)/stats(4,1) * stats(i,colsAv);
end
stats(4,colsAv) = averages;

%stats(:,colsAv) = round(stats(:,colsAv)* 100)/100;
stats = stats';


