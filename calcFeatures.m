function segments = calcFeatures(segments,featureFlag,raw)
    

    delList = [];
    for i=1:length(segments)
        featureCount = 1;
        PixelList = segments(i).PixelList;     
        objSize = length(PixelList);
        if objSize > 10000 
        %size
            if(featureFlag(1))
                segments(i).features(featureCount) = objSize;     
                featureCount = featureCount+1;
            end
        %pca
            if(featureFlag(2))
                [COEFF,SCORE,latent] = princomp(PixelList);
                pcFracs = latent./sum(latent);
                segments(i).features(featureCount) = pcFracs(1);
                segments(i).features(featureCount+1) = pcFracs(2);
                segments(i).features(featureCount+2) = pcFracs(3);
                segments(i).features(featureCount+3) = pcFracs(3)/pcFracs(2);
                segments(i).features(featureCount+4) = pcFracs(3)/pcFracs(1);
                segments(i).features(featureCount+5) = pcFracs(2)/pcFracs(1);
                segments(i).features(featureCount+6) = -pcFracs(1)*log(pcFracs(1))-pcFracs(2)*log(pcFracs(2))-pcFracs(3)*log(pcFracs(3));
                featureCount = featureCount+7;

            end
        
        %concavity
            if(featureFlag(3))
                segments(i).features(featureCount) = calcConcavity(PixelList,10);
                featureCount = featureCount+1;
            end
            
        %intensities
            if(featureFlag(4)) 
                [meanIntensity,stdIntensity] = calcIntensities(PixelList,raw);
                segments(i).features(featureCount) = meanIntensity;
                segments(i).features(featureCount+1) = stdIntensity;
                featureCount = featureCount+2;

            end
        %...
        
        else
            delList(end+1) = i;
        end
    end
    segments(delList) = [];
end

 
%                 objIdx = sub2ind(size(raw),PixelList(:,1),PixelList(:,2),PixelList(:,3));
%                 mitoVox = intersect(objIdx,mitoIdx);
% 
%                 if length(mitoVox) > 500
%                     intensity = sum(raw(mitoVox))./length(mitoVox);
%                 else
%                     intensity = NaN; 
%                 end
%                 segments(i).features(6) = intensity;
%                 featureCount = featureCount+1;

