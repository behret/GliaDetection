function featureMat = calcShape(segments)
    
%     delList = [];
   
    parfor i=1:length(segments)
        PixelList = segments(i).PixelList;             
        objSize = length(PixelList);

%     throw out too small segments
%     optimize outside, use here for prediction
%       if objSize < 2000     
%           delList(end+1) = i;
%           continue;
%       end
      

        segments(i).features(1) = log(objSize);                     
        segments(i).features(2) = calcConcavity(PixelList,10);
        [COEFF,SCORE,latent] = princomp(PixelList);
        pcFracs = latent./sum(latent);
        segments(i).features(3) = pcFracs(1);
        segments(i).features(4) = pcFracs(2);
        segments(i).features(5) = pcFracs(3);
        segments(i).features(6) = pcFracs(3)/pcFracs(2);
        segments(i).features(7) = pcFracs(3)/pcFracs(1);
        segments(i).features(8) = pcFracs(2)/pcFracs(1);
        segments(i).features(9) = -pcFracs(1)*log(pcFracs(1))-pcFracs(2)*log(pcFracs(2))-pcFracs(3)*log(pcFracs(3));
                 

    end
    
%     for prediction: delete too small segments
%     idx = setdiff(1:length(segments),delList);
%     segments(delList) = []; 
    
    %restructure features
    featureMat = reshape(cell2mat({segments.features}),length(segments(1).features),length(segments))';        

%     % feature names..
%     featureNames = {'log size' ; 'frac pc1' ; 'frac pc2' ; 'frac pc3' ; 'frac pc3/frac pc2' ; 'frac pc3/frac pc1' ; 'frac pc2/frac pc1' ; 'entropy pc fracs';'concavity'};
%     featureNames{3} = {'mean intensity' ; 'std intensity' ; 'nbMean' ; 'nbStd' ; 'dark1' ; 'dark10' ; 'darkDiff' ; }; 
%     a = featureNames([1,find(featureFlag)+1]);
%     names = cell(0);
%     for i=1:length(a)
%         [names{length(names)+1 : length(names)+length(a{i})}] = a{i}{:};
%     end
    
   
end

