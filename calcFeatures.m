function [scaledMat,featureMat,labels,names] = calcFeatures(segments,featureFlag,raw)
    
    %delList = [];
   
    for i=1:length(segments)
        PixelList = segments(i).PixelList;     
        
        objSize = length(PixelList);
        segments(i).features(1) = log(objSize);                     
        featureCount = 2;      

    % throw out too small segments
    % optimize outside, use here for prediction
    %   if objSize < 2000     
    %       delList(end+1) = i;
    %       continue;
    %   end
        
    % shape features
        if(featureFlag(1))            
            segments(i).features(featureCount) = calcConcavity(PixelList,10);
            [COEFF,SCORE,latent] = princomp(PixelList);
            pcFracs = latent./sum(latent);
            segments(i).features(featureCount+1) = pcFracs(1);
            segments(i).features(featureCount+2) = pcFracs(2);
            segments(i).features(featureCount+3) = pcFracs(3);
            segments(i).features(featureCount+4) = pcFracs(3)/pcFracs(2);
            segments(i).features(featureCount+5) = pcFracs(3)/pcFracs(1);
            segments(i).features(featureCount+6) = pcFracs(2)/pcFracs(1);
            segments(i).features(featureCount+7) = -pcFracs(1)*log(pcFracs(1))-pcFracs(2)*log(pcFracs(2))-pcFracs(3)*log(pcFracs(3));
            featureCount = featureCount+8;
        end

    % intensity features
        if(featureFlag(2)) 
            intensityVals  = calcIntensities(PixelList,raw);
            segments(i).features(featureCount:featureCount+6) = intensityVals;
        end
    
    end
    
    % for prediction: delete too small segments
    % idx = setdiff(1:length(segments),delList);
    % segments(delList) = []; 
    
    
    %restructure features
    featureMat = reshape(cell2mat({segments.features}),length(segments(1).features),length(segments))';
    labels = cell2mat({segments.label});
        
       
    %scale features  
    scaledMat = zeros(size(featureMat));
    for feat = 1:size(featureMat,2)
        scaledMat(:,feat) = (featureMat(:,feat)-min(featureMat(:,feat))) / ...
            (max(featureMat(:,feat)) - min(featureMat(:,feat)));
    end
    
 
    % feature names..
    featureNames{1} = {'log size'};
    featureNames{2} = {'frac pc1' ; 'frac pc2' ; 'frac pc3' ; 'frac pc3/frac pc2' ; 'frac pc3/frac pc1' ; 'frac pc2/frac pc1' ; 'entropy pc fracs';'concavity'};
    featureNames{3} = {'mean intensity' ; 'std intensity' ; 'nbMean' ; 'nbStd' ; 'dark1' ; 'dark10' ; 'darkDiff' ; }; 
    a = featureNames([1,find(featureFlag)+1]);
    names = cell(0);
    for i=1:length(a)
        [names{length(names)+1 : length(names)+length(a{i})}] = a{i}{:};
    end
    
   
end

