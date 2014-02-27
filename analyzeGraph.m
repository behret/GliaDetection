function [ output_args ] = analyzeGraph( parameter,pred,labelStruct,partition)

labelStructTest = divideLabelStruct(labelStruct,partition.test);
labelStructTrain = divideLabelStruct(labelStruct,partition.train);

pred(partition.test,1:5) = [pred(partition.test,:) labelStructTest.ids];
pred(partition.train,1:5) = [pred(partition.train,1:3) labelStructTrain.ids];

for tracing = parameter.tracingsToUse
    % get segments for this tracing
    load(parameter.tracings(tracing).segmentFile);
    predTracing = pred(pred(:,4) == tracing,:);
    load(parameter.tracings(tracing).graphFile);
    graphData = [edgesNew pNew'];
    
    
    idxMat = zeros(length(segments),4);
    for i = 1:length(segments)     
        % get pred for segment
        segments(i).pred = predTracing(i,1:2);       
        % get neighbors for segment: [id connectionPorb label pred predVal]
        [rows,cols] = ind2sub(size(graphData),find(graphData == segments(i).id));
        edges = graphData(rows,:);
        neighbors = setdiff(unique([edges(:,1) ; edges(:,2)]),segments(i).id);
        segments(i).neighbors = neighbors;
        neighborMat = zeros(1,5);
        for j = 1:length(neighbors)       
            %list only neighbors that are labeled
            if any(predTracing(:,5) == neighbors(j))                       
                [rows,cols] = ind2sub(size(edges),find(edges == neighbors(j)));
                connProb = edges(rows(1),3);     %there might be duplicates..take first one           
                predNeighbor = predTracing(predTracing(:,5) == neighbors(j),1:2);              
                labelNeighbor = predTracing(predTracing(:,5) == neighbors(j),3);                
                neighborMat(end+1,1:5) = [neighbors(j) connProb labelNeighbor predNeighbor];
            end          
        end
        segments(i).neigborMat = neighborMat; 
        segments(i).hasGliaNeighbor  = any(neighborMat(:,3));
        segments(i).hasGliaNeighborPred  = any(neighborMat(:,4));
        
        %get indices for further analysis: [TP TN FP FN]
        if segments(i).label == 1 && segments(i).pred(1) == 1
            idxMat(i,1) = 1;
        elseif segments(i).label == 0 && segments(i).pred(1) == 0
            idxMat(i,2) = 1;
        elseif segments(i).label == 0 && segments(i).pred(1) == 1
            idxMat(i,3) = 1;    
        elseif segments(i).label == 1 && segments(i).pred(1) == 0
            idxMat(i,4) = 1;
        end
    end
    
    %segments(cellfun(@isempty,{segments.neighbors})) = [];
    
    labels = cell2mat({segments.label});
    %neighbors = {segments.neighbors};
    hasGliaNeighbor = cell2mat({segments.hasGliaNeighbor});
    hasGliaNeighborPred = cell2mat({segments.hasGliaNeighborPred});
       
    pGlia = sum(hasGliaNeighbor(labels ==1))/sum(labels == 1);
    pNonGlia = sum(hasGliaNeighbor(labels ==0))/sum(labels == 0);
    
    pTP(1) = sum(hasGliaNeighbor(idxMat(:,1) == 1))/sum(idxMat(:,1) == 1);
    pTN(1) = sum(hasGliaNeighbor(idxMat(:,2) == 1))/sum(idxMat(:,2) == 1);
    pFP(1) = sum(hasGliaNeighbor(idxMat(:,3) == 1))/sum(idxMat(:,3) == 1);
    pFN(1) = sum(hasGliaNeighbor(idxMat(:,4) == 1))/sum(idxMat(:,4) == 1);  
    
    pTP(2) = sum(hasGliaNeighborPred(idxMat(:,1) == 1))/sum(idxMat(:,1) == 1);
    pTN(2) = sum(hasGliaNeighborPred(idxMat(:,2) == 1))/sum(idxMat(:,2) == 1);
    pFP(2) = sum(hasGliaNeighborPred(idxMat(:,3) == 1))/sum(idxMat(:,3) == 1);
    pFN(2) = sum(hasGliaNeighborPred(idxMat(:,4) == 1))/sum(idxMat(:,4) == 1);    
    
    
    % decrease: not found segments
    % increase: other distribution due to false positives
    % fp rates suggest wrongly labeled segments
    bar([pTP;pFN;pTN;pFP])
    legend('labels', 'prediction','location','bestOutside')
    set(gca,'XTick',1:4)
    set(gca,'XTickLabel',{'TP','FN','TN','FP'})
    xlabel('Class by group in prediciton')
    ylabel('Rate of segments with glia neighbor')
    title('Glia neighbors')
    ylim([0 1])
    
    
    
    
    glia.neighbors = neighbors(labels == 1);
    glia.neighbors(cellfun(@isempty,glia.neighbors)) = [];
    nonGlia.neighbors = neighbors(labels == 0);
    nonGlia.neighbors(cellfun(@isempty,nonGlia.neighbors)) = [];

    gliaNfun = @(x) sum(x(:,2));
    totalNfun = @(x) length(x(:,2));
    glia.totalN = sum(cellfun(totalNfun,glia.neighbors));
    nonGlia.totalN = sum(cellfun(totalNfun,nonGlia.neighbors));
    glia.gliaN = sum(cellfun(gliaNfun,glia.neighbors));
    nonGlia.gliaN = sum(cellfun(gliaNfun,nonGlia.neighbors));
end

end

