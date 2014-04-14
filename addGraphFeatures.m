function addGraphFeatures(parameter)


for tracing = 1:3
    
    load(parameter.tracings(tracing).featuresAllFile);
    load([parameter.tracings(tracing).segmentFile 'New'], 'segmentsNew');
    
    for i = 1:length(segmentsNew)
        
        neighborMat = segmentsNew(i).neighborMat;
        if ~isempty(neighborMat)
            gliaIdx = neighborMat(:,4) == 1;
            % stats of neighbors' glia prob
            mat(i,11) = max(neighborMat(:,5));
            mat(i,12) = min(neighborMat(:,5));
            mat(i,13) = mean(neighborMat(:,5));
            mat(i,14) = median(neighborMat(:,5));
            mat(i,15) = std(neighborMat(:,5));
            %
            mat(i,16) = length(gliaIdx);
            mat(i,17) = sum(gliaIdx)/length(gliaIdx);
            mat(i,18) = mean(neighborMat(:,2).*neighborMat(:,5));   
            %stats of nonGlia connections (if there are any)
            if sum(gliaIdx == 0 ~= 0)
                mat(i,1) = max(neighborMat(gliaIdx == 0,2));
                mat(i,2) = min(neighborMat(gliaIdx == 0,2));
                mat(i,3) = mean(neighborMat(gliaIdx == 0,2));
                mat(i,4) = median(neighborMat(gliaIdx == 0,2));
                mat(i,5) = std(neighborMat(gliaIdx == 0,2));
            else
                mat(i,1:5) = zeros(1,5);
            end
            % stats of glia connections (if there are any)
            if sum(gliaIdx ~= 0)
                mat(i,6) = max(neighborMat(gliaIdx,2));
                mat(i,7) = min(neighborMat(gliaIdx,2));
                mat(i,8) = mean(neighborMat(gliaIdx,2));
                mat(i,9) = median(neighborMat(gliaIdx,2));
                mat(i,10) = std(neighborMat(gliaIdx,2));
            else
                mat(i,6:10) = zeros(1,5);
            end

        else 
            mat(i,1:18) = zeros(1,18); % do zeros constitute a problem..?
        end
    
        
    end

    featureMat(:,160:177) = mat;
    clear mat;
    save([parameter.tracings(tracing).featuresAllFile 'New'], 'featureMat');
end
