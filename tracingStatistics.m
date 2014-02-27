



for tracing= 1:3

    clear segments;
    load(parameter(i).segmentFile);
    % sth like that
    labels = cell2mat({segments.label});
    pixelLists = {segments.PixelList};
    stats(tracing,1) = sum(cellfun(@length,pixelLists(labels)))/sum(cellfun(@length,pixelLists));
    
    
    % mean seg size
    
    % how many get joined in GP and their size distribution
    
    % #segments compared to voxelNr 
    
    
    
end


%% get segment and voxel numbers

load(parameter.tracings(2).segmentFile);
labels = cell2mat({segments.label});
ratioSegs = sum(labels)/sum(labels == 0);

sizs = cellfun(@length,{segments.PixelIdxList});
ratioVox = sum(sizs(labels == 1))/sum(sizs(labels == 0));
