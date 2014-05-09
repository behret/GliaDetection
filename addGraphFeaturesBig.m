function addGraphFeaturesBig(parameter)


for tracing = 1:3
    
    load(parameter.tracings(tracing).featureFile);
    load(parameter.tracings(tracing).segmentFileNew, 'segmentsNew');
    pred = cell2mat({segmentsNew.pred}');
    probs = pred(:,2);
    for i = 1:length(segmentsNew)
        
        neighborMat = segmentsNew(i).neighborMat;
        if ~isempty(neighborMat)
            % stats of neighbors' glia prob
            mat(i,1) = max(neighborMat(:,5));
            mat(i,2) = min(neighborMat(:,5));
            mat(i,3) = mean(neighborMat(:,5));
            mat(i,4) = median(neighborMat(:,5));
            mat(i,5) = std(neighborMat(:,5));
            mat(i,6) = size(neighborMat,1);
            mat(i,7) = mean(neighborMat(:,2).*neighborMat(:,5));   

            % features dependent on decision boundary
            prevs = 0.05:0.05:0.30;
            for db = 1:length(prevs)

                boundary = getDecisionBoundary(probs,prevs(db));
                gliaIdx = neighborMat(:,5) > boundary;

                tmpFeat(1) = sum(gliaIdx);
                tmpFeat(2) = sum(gliaIdx)/length(gliaIdx);
                % stats of nonGlia connections (if there are any)
                if sum(gliaIdx == 0 ~= 0)
                    tmpFeat(3) = max(neighborMat(gliaIdx == 0,2));
                    tmpFeat(4) = min(neighborMat(gliaIdx == 0,2));
                    tmpFeat(5) = mean(neighborMat(gliaIdx == 0,2));
                    tmpFeat(6) = median(neighborMat(gliaIdx == 0,2));
                    tmpFeat(7) = std(neighborMat(gliaIdx == 0,2));
                else
                   tmpFeat(3:7) = zeros(1,5);
                end
                % stats of glia connections (if there are any)
                if sum(gliaIdx ~= 0)
                    tmpFeat(8) = max(neighborMat(gliaIdx,2));
                    tmpFeat(9) = min(neighborMat(gliaIdx,2));
                    tmpFeat(10) = mean(neighborMat(gliaIdx,2));
                    tmpFeat(11) = median(neighborMat(gliaIdx,2));
                    tmpFeat(12) = std(neighborMat(gliaIdx,2));
                else
                    tmpFeat(8:12) = zeros(1,5);
                end
                mat(i,8+(db-1)*length(tmpFeat):8+(db-1)*length(tmpFeat)+length(tmpFeat)-1) = tmpFeat;
            end
        else
            mat(i,1:79) = zeros(1,79);
        end
    end

    featureMat(:,160:160+size(mat,2)-1) = mat;
    clear mat;
    save(parameter.tracings(tracing).featureFileNew, 'featureMat','labels');
end
