function segment = parcalc(segment)


%%%%%%%%%%%%%%%%
%INSERT

% tic
% for i=1:length(glia)
%     result(i) = parcalc(glia(i));
% end
% toc

%%%%%%%%%%%%%%%%



    count = 0;

    PixelList = segment.PixelList;     
    objSize = length(PixelList);
    if objSize > 10000 
        count = count+1; 
    %size
        segment.features{1}(count) = objSize;     

    %princomp
        [COEFF,SCORE,latent] = princomp(PixelList);
        pcFracs = latent./sum(latent);
        segment.features{2}(count) = pcFracs(1);
        segment.features{3}(count) = pcFracs(2);
        segment.features{4}(count) = pcFracs(3);

    %concavity: compute convex hull and do V_hull - V_object

        projOnPlane = projPointOnPlane(PixelList,[zeros(1,3) COEFF(:,1)' COEFF(:,2)']);
        coordsIn2Dpc = projOnPlane*COEFF(:,1:2);
        coordsIn2Dpc = unique(round(coordsIn2Dpc),'rows');         
        [K,v] = convhull(coordsIn2Dpc(:,1),coordsIn2Dpc(:,2));
        %calc area of convhull
        wholeArea = [sort(repmat([min(coordsIn2Dpc(:,1)):max(coordsIn2Dpc(:,1))]',length(min(coordsIn2Dpc(:,2)):max(coordsIn2Dpc(:,2))),1)) ...
            repmat([min(coordsIn2Dpc(:,2)):max(coordsIn2Dpc(:,2))]',length(min(coordsIn2Dpc(:,1)):max(coordsIn2Dpc(:,1))),1)];
        in = inpolygon(wholeArea(:,1),wholeArea(:,2),coordsIn2Dpc(K,1),coordsIn2Dpc(K,2));
        areaConvhull = sum(in == 1);           
        %plot(coordsIn2Dpc(K,1),coordsIn2Dpc(K,2),'r-',coordsIn2Dpc(:,1),coordsIn2Dpc(:,2),'b+')            
        segment.features{5}(count) = length(coordsIn2Dpc)/areaConvhull;


    % look for mitos in raw

%         objIdx = sub2ind(size(raw),PixelList(:,1),PixelList(:,2),PixelList(:,3));
%         mitoVox = intersect(objIdx,mitoIdx);
% 
%         if length(mitoVox) > 500
%             intensity = sum(raw(mitoVox))./length(mitoVox);
%         else
%             intensity = NaN; 
%         end
%         segment.features{6}(count) = intensity;

    %...

    else
        segment.features = [];
    end
   
end