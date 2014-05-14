function addGraphFeatures(parameter)


for tracing = 1:3
    
    load(parameter.tracings(tracing).featureFile);
    load(parameter.tracings(tracing).segmentFileNew, 'segmentsNew');
    % define median such that median value appears in probabilities
    getMedIdx = @(x) min(abs(x - median(x)));
    
    for i = 1:length(segmentsNew)
        
        neighborMat = segmentsNew(i).neighborMat;
        if ~isempty(neighborMat)
            
            mat(i,1) = size(neighborMat,1);
   
            %%% stats of connections
            [mat(i,2),maxIdx] = max(neighborMat(:,2));
            [mat(i,3),minIdx] = min(neighborMat(:,2));
            [val,medIdx] = getMedIdx(neighborMat(:,2));
            mat(i,4) = neighborMat(medIdx,2);
            mat(i,5) = mean(neighborMat(:,2));
            mat(i,6) = std(neighborMat(:,2));
            % glia probs corresponding to max min and med
            mat(i,7) = neighborMat(maxIdx,5);
            mat(i,8) = neighborMat(minIdx,5);
            mat(i,9) = neighborMat(medIdx,5);
            
            %%% stats of neighbors' glia prob
            [mat(i,10),maxIdx] = max(neighborMat(:,5));
            [mat(i,11),minIdx] = min(neighborMat(:,5));
            [val,medIdx] = getMedIdx(neighborMat(:,5));
            mat(i,12) = neighborMat(medIdx,5);
            mat(i,13) = mean(neighborMat(:,5));
            mat(i,14) = std(neighborMat(:,5));
            % connection probs corresponding do max min and med             
            mat(i,15) = neighborMat(maxIdx,2);
            mat(i,16) = neighborMat(minIdx,2);
            mat(i,17) = neighborMat(medIdx,2);
   
            %%% stats of product
            mat(i,18) = max(neighborMat(:,2).*neighborMat(:,5));   
            mat(i,19) = min(neighborMat(:,2).*neighborMat(:,5));   
            mat(i,20) = median(neighborMat(:,2).*neighborMat(:,5));   
            mat(i,21) = mean(neighborMat(:,2).*neighborMat(:,5));   
            mat(i,22) = std(neighborMat(:,2).*neighborMat(:,5));   

        else 
            mat(i,1:22) = zeros(1,22); 
        end

    end

    featureMat(:,160:181) = mat; % replace graph features from first prediction (160:165)
    clear mat;
    save(parameter.tracings(tracing).featureFileNew, 'featureMat','labels');
end