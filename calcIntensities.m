function [ meanIntensity,stdIntensity ] = calcIntensities( PixelList,raw )

        idx = sub2ind(size(raw),PixelList(:,1),PixelList(:,2),PixelList(:,3));
        meanIntensity = mean(raw(idx));
        stdIntensity = std(raw(idx));

end

