function featureMat = calcShape(segments)
     
    parfor i=1:length(segments)
        PixelList = segments(i).PixelList;             
        objSize = length(PixelList);

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
   
    %restructure features
    featureMat = reshape(cell2mat({segments.features}),length(segments(1).features),length(segments))';          
end

