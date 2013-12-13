function [featureMat,ids,names,filterIdx] = calcFeatures(segments,featureFlag,raw)
    
    delList = [];
   
    for i=1:length(segments)
        featureCount = 1;
        PixelList = segments(i).PixelList;     
        
        objSize = length(PixelList);
        [COEFF,SCORE,latent] = princomp(PixelList);
        pcFracs = latent./sum(latent);
        % throw out too small segments, check pc1 to leave in leaf like
        % segments
        if objSize < 2000     
            delList(end+1) = i;
            continue;
%             if pcFracs(1) < 0.8 || objSize < 1000             
%                 delList(end+1) = i;
%                 continue;
%             end
        end
        
    %size, pca
        if(featureFlag(1))
            segments(i).features(featureCount) = objSize;                     
            segments(i).features(featureCount+1) = pcFracs(1);
            segments(i).features(featureCount+2) = pcFracs(2);
            segments(i).features(featureCount+3) = pcFracs(3);
            segments(i).features(featureCount+4) = pcFracs(3)/pcFracs(2);
            segments(i).features(featureCount+5) = pcFracs(3)/pcFracs(1);
            segments(i).features(featureCount+6) = pcFracs(2)/pcFracs(1);
            segments(i).features(featureCount+7) = -pcFracs(1)*log(pcFracs(1))-pcFracs(2)*log(pcFracs(2))-pcFracs(3)*log(pcFracs(3));
            featureCount = featureCount+8;
        end

    %concavity
        if(featureFlag(2))
            segments(i).features(featureCount) = calcConcavity(PixelList,10);
            featureCount = featureCount+1;
        end

    %intensities
        if(featureFlag(3)) 
            [ meanIntensity,stdIntensity,darkRatio,lightRatio ]  = calcIntensities(PixelList,raw);
            segments(i).features(featureCount) = meanIntensity;
            segments(i).features(featureCount+1) = stdIntensity;
            segments(i).features(featureCount+2) = darkRatio;
            segments(i).features(featureCount+3) = lightRatio;
            featureCount = featureCount+4;
        end
    %...
    
    end
    % delete too small segments, restructure features
    segments(delList) = [];   
    featureMat = reshape(cell2mat({segments.features}),length(segments(1).features),length(segments))';
    ids = cell2mat({segments.id})';
    filterIdx = setdiff(1:length(segments),delList);
    
    % feature names..
    featureNames{1} = {'size' ; 'frac pc1' ; 'frac pc2' ; 'frac pc3' ; 'frac pc3/frac pc2' ; 'frac pc3/frac pc1' ; 'frac pc2/frac pc1' ; 'entropy pc fracs'};
    featureNames{2} = {'concavity'};
    featureNames{3} = {'mean intensity' ; 'std intensity' ; 'darkRatio' ; 'lightRatio1' }; 
    a = featureNames(find(featureFlag));
    names = cell(0);
    for i=1:length(a)
        [names{length(names)+1 : length(names)+length(a{i})}] = a{i}{:};
    end
    
    
    %% scale features
    
    
    
    
    
    
    
    
end

