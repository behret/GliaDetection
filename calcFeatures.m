function segments = calcFeatures(segments,raw,mito)
    
    featureNames = [];
    delList = [];
    %mitoIdx = find(mito == 1);    
    for i=1:length(segments)
     
        PixelList = segments(i).PixelList;     
        objSize = length(PixelList);
        if objSize > 10000 
        %size
            segments(i).features(1) = objSize;     

        %princomp
            [COEFF,SCORE,latent] = princomp(PixelList);
            pcFracs = latent./sum(latent);
            segments(i).features(2) = pcFracs(1);
            segments(i).features(3) = pcFracs(2);
            segments(i).features(4) = pcFracs(3);
            segments(i).features(5) = pcFracs(3)/pcFracs(2);
            segments(i).features(6) = pcFracs(3)/pcFracs(1);
            segments(i).features(7) = pcFracs(2)/pcFracs(1);
            segments(i).features(8) = -pcFracs(1)*log(pcFracs(1))-pcFracs(2)*log(pcFracs(2))-pcFracs(3)*log(pcFracs(3));

        
        %concavity: compute convex hull and do V_hull - V_object
            segments(i).features(9) = calcConcavity(PixelList,1);

            
        % look for mitos in raw
            
%             objIdx = sub2ind(size(raw),PixelList(:,1),PixelList(:,2),PixelList(:,3));
%             mitoVox = intersect(objIdx,mitoIdx);
%                         
%             if length(mitoVox) > 500
%                 intensity = sum(raw(mitoVox))./length(mitoVox);
%             else
%                 intensity = NaN; 
%             end
%             segments(i).features(6) = intensity;
            
        %...
        
        else
            delList(end+1) = i;
        end
    end
    segments(delList) = [];
end