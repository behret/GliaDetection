function result = calcIntensities( PixelList,raw )

    idx = sub2ind(size(raw),PixelList(:,1),PixelList(:,2),PixelList(:,3));
    result(1) = mean(raw(idx));
    result(2) = std(raw(idx));
%     darkRatio = sum(raw(idx) < 90)/length(PixelList);
%     lightRatio(1) = sum(raw(idx) > 130)/length(PixelList);   
    
    % neighbourhood dark pixels    
    segment = visualizeSegment(PixelList,raw,0,0);
    segment = padarray(segment,[2 2 2]);
    %erode to avoid membraes
    if length(PixelList) > 10000
        segmentBW = segment;
        segmentBW(segmentBW ~= 0) = 1;
        fil = imerode(segmentBW,ones(5,5,5));
        segment(fil ~= 1) = 0;
    end
    %get voxels with dark intensity
    intensities = sort(segment(1:end));
    intensities(intensities == 0) = [];
    intensities = unique(intensities);
    darkVoxIdx = [];
    for i=1:10
        darkVoxIdx = [darkVoxIdx ; find(segment == intensities(i))];
    end
    nbStds = [];
    nbDevs = [];
    for i =1:10
        [x,y,z] = ind2sub(size(segment),darkVoxIdx(i));
        reg = segment(x-1:x+1,y-1:y+1,z-1:z+1);
        vals = reg(1:end);
        midVal = reg(2,2,2);
        vals(14) = [];
        vals(vals == 0 | vals == midVal) = [];
        nbDevs(end+1) = mean(vals) - midVal;
        nbStds(end+1) = std(vals-midVal);   
    end
    
    result(3) = mean(nbDevs);
    result(4) = mean(nbStds);
    result(5) = segment(darkVoxIdx(1));
    result(6) = segment(darkVoxIdx(10));
    result(7) = result(6) - result(5);
 
    
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

