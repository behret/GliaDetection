function [result,resultNonGlia] = getSegments(seg)

    ids = unique(seg);
    props = regionprops(seg,'PixelList');
    result.PixelLists = props(ids);
    %restructure and resolve XY swap
    for i=1:length(ids)
        result(i).id = ids(i);
        result(i).PixelList = [result.PixelLists(i).PixelList(:,2) result.PixelLists(i).PixelList(:,1) result.PixelLists(i).PixelList(:,3)];
    end 
end

