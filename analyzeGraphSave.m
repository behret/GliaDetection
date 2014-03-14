function [ output_args ] = analyzeGraph( parameter,pred,ids)

pred(:,1:4) = [pred ids];

tracing = 1;
% get segments for this tracing
load(parameter.tracings(tracing).segmentFile);
load(parameter.tracings(tracing).graphFile);
graphData = [edgesNew pNew];

allIds = cell2mat({segments.id});
for i = 1:length(allIds)
    if any(ids == allIds(i));
        idIdx(i) = 1;
    else
        idIdx(i) = 0;
    end
end
segments(~idIdx) = []; 


idxMat = zeros(length(segments),4);
% get graph info for every segment
for i = 1:length(segments)     
    % get pred for segment
    segments(i).pred = pred(i,1:2);       
    % get neighbors for segment: [id connectionPorb label pred predVal]
    [rows,cols] = ind2sub(size(graphData),find(graphData == segments(i).id));
    edges = graphData(rows,:);
    neighbors = setdiff(unique([edges(:,1) ; edges(:,2)]),segments(i).id);
    segments(i).neighbors = neighbors;
    neighborMat = zeros(1,5);
    for j = 1:length(neighbors)       
        %list only neighbors that are labeled
        if any(pred(:,4) == neighbors(j))                       
            [rows,cols] = ind2sub(size(edges),find(edges == neighbors(j)));
            connProb = edges(rows(1),3);     %there might be duplicates..take first one           
            predNeighbor = pred(pred(:,4) == neighbors(j),1:2);              
            labelNeighbor = pred(pred(:,4) == neighbors(j),3);                
            neighborMat(end+1,1:5) = [neighbors(j) connProb labelNeighbor predNeighbor];
        end          
    end
    segments(i).neighborMat = neighborMat; 
    segments(i).hasGliaNeighbor  = any(neighborMat(:,3));
    pNon = segments(i).neighborMat(neighborMat(:,4) == 0,2);
    segments(i).pNonNeighbor = max(pNon);            
    if any(neighborMat(:,4));
        pGlia = segments(i).neighborMat(neighborMat(:,4) == 1,2);
        segments(i).pGliaNeighbor = max(pGlia);
    else
        segments(i).pGliaNeighbor = 0;
    end

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

hasGliaNeighbor = cell2mat({segments.hasGliaNeighbor});
pGliaNeighbor = cell2mat({segments.pGliaNeighbor});
pNonNeighbor = cell2mat({segments.pNonNeighbor});

for bin = [1 3]   
    gliaNeighborRate(bin,1) = sum(hasGliaNeighbor(idxMat(:,bin) == 1))/sum(idxMat(:,bin) == 1);
    gliaNeighborRate(bin,2) = sum(pGliaNeighbor(idxMat(:,bin) == 1) ~= 0)/sum(idxMat(:,bin) == 1);   
    gliaNeighborRate(bin,3) = sum(pNonNeighbor(idxMat(:,bin) == 1) < 0.5)/sum(idxMat(:,bin) == 1);   
    gliaNeighborRate(bin,4) = sum(pGliaNeighbor(idxMat(:,bin) == 1) > 0.5)/sum(idxMat(:,bin) == 1);           
    gliaNeighborRate(bin,5) = sum(pGliaNeighbor(idxMat(:,bin) == 1) > 0.4 & pNonNeighbor(idxMat(:,bin) == 1) < 0.8)/sum(idxMat(:,bin) == 1);   
end

newPred = pGliaNeighbor(idxMat(:,bin) == 1) > 0.4 & pNonNeighbor(idxMat(:,bin) == 1) < 0.8;

% decrease: not found segments
% increase: other distribution due to false positives
% fp rates suggest wrongly labeled segments
figure
bar(gliaNeighborRate)
legend('labels', 'prediction','location','bestOutside')
set(gca,'XTick',1:3)
set(gca,'XTickLabel',{'TP','','FN'})
xlabel('Class by group in prediciton')
ylabel('Rate of segments with glia neighbor')
title('Glia neighbors')
ylim([0 1])



probsTP = pGliaNeighbor(idxMat(:,1) == 1);
probsFP = pGliaNeighbor(idxMat(:,3) == 1);    
figure
hist(probsTP(probsTP ~= 0),0.05:0.1:0.95);
figure
hist(probsFP(probsFP ~= 0),0.05:0.1:0.95);

    

    
    
    
    
    
    


end

