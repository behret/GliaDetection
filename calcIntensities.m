function [ meanIntensity,stdIntensity,darkRatio,lightRatio ] = calcIntensities( PixelList,raw )

    idx = sub2ind(size(raw),PixelList(:,1),PixelList(:,2),PixelList(:,3));
    meanIntensity = mean(raw(idx));
    stdIntensity = std(raw(idx));
    %detect wrong labels/segmentations via darkRatio???
    darkRatio = sum(raw(sub2ind(size(raw),PixelList(:,1),PixelList(:,2),PixelList(:,3))) < 90)/length(PixelList);
    lightRatio(1) = sum(raw(sub2ind(size(raw),PixelList(:,1),PixelList(:,2),PixelList(:,3))) > 130)/length(PixelList);


%     %vesicles       check cutoffs, values..     find normalizing factor
%     segment = visualizeSegment(PixelList,0,raw);
%     %erode to avoid membraes
%     eroded = imerode(logical(segment),ones(5,5,5));
%     %get voxels with dark intensity
%     segment(segment == 0) = 255;
%     segment(segment < 120) = NaN;
%     segment(~isnan(segment)) = 1;
%     segment(isnan(segment)) = 0;
%     segment(~eroded) = 1;
%     %close 
%     closed = imclose(segment,(ones(2,2,2)));
%     cc = bwconncomp(imcomplement(closed));
%     vesicleVal = sum( cellfun(@length,cc.PixelIdxList) < 20)/length(PixelList)^(1/3);
%     a = 1;
end

