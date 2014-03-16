function [ segments ] = analyzeGraph( parameter,pred,ids,wholeCubeFlag)

pred(:,1:4) = [pred double(ids)];

tracing = 1;
% get segments for this tracing
if wholeCubeFlag
    load('G:\Benjamin\dataGraph\predictCubeFeatures','segments');
else
    load(parameter.tracings(tracing).segmentFile,'segments');
end
load(parameter.tracings(tracing).graphFile);
graphData = [edgesNew pNew];


%% write data into segment struct

idxMat = zeros(length(segments),4);
% get graph info for every segment
for i = 1:length(segments)     
    % get label and  pred for segment
    segments(i).label = pred(i,3);
    segments(i).pred = pred(i,1:2);       
    % get neighbors for segment: [id connectionPorb label pred predVal]
    [rows,cols] = ind2sub(size(graphData),find(graphData == segments(i).id));
    edges = graphData(rows,:);
    neighbors = setdiff(unique([edges(:,1) ; edges(:,2)]),segments(i).id);
    segments(i).neighbors = neighbors;
    count = 0;
    neighborMat = zeros(1,5);
    for j = 1:length(neighbors) 
        if ~isempty(pred(pred(:,4) == neighbors(j),1:2))
            count = count+1;
            [rows,cols] = ind2sub(size(edges),find(edges == neighbors(j)));
            connProb = edges(rows(1),3);     %there might be duplicates..take first one           
            predNeighbor = pred(pred(:,4) == neighbors(j),1:2);              
            labelNeighbor = pred(pred(:,4) == neighbors(j),3);                
            neighborMat(count,1:5) = [neighbors(j) connProb labelNeighbor(1) predNeighbor(1,:)];
        end
    end
    segments(i).neighborMat = neighborMat; 

    %get indices for further analysis: [TP FN TN FP G NG]
    if segments(i).label == 1 && segments(i).pred(1) == 1
        idxMat(i,3) = 1;
        idxMat(i,1) = 1;
    elseif segments(i).label == 1 && segments(i).pred(1) == 0
        idxMat(i,4) = 1;
        idxMat(i,1) = 1;
    elseif segments(i).label == 0 && segments(i).pred(1) == 0
        idxMat(i,5) = 1;
        idxMat(i,2) = 1;
    elseif segments(i).label == 0 && segments(i).pred(1) == 1
        idxMat(i,6) = 1;
        idxMat(i,2) = 1;
    end
end




%% analyse connections

for i = 1:length(segments)
    gliaIdx = segments(i).neighborMat(:,4) == 1;
    nonGliaIdx = segments(i).neighborMat(:,4) == 0;
    
    if length(segments(i).neighborMat(gliaIdx,5)) > 0 
        plotData(i,1) = 1;
    else
        plotData(i,1) = 0; 
    end
    
    if mean(segments(i).neighborMat(gliaIdx,2)) > .3
        plotData(i,2) = 1;
    else
        plotData(i,2) = 0; 
    end
    
    if sum(segments(i).neighborMat(:,4))/length(segments(i).neighborMat(:,4)) > 0.2
        plotData(i,3) = 1;
    else
        plotData(i,3) = 0;
    end
%     
%     if mean(segments(i).neighborMat(gliaIdx,2).*segments(i).neighborMat(gliaIdx,5)) ...
%             / mean(segments(i).neighborMat(nonGliaIdx,2).*segments(i).neighborMat(nonGliaIdx,5))  > 1
%         plotData(i,5) = 1;
%     else
%         plotData(i,5) = 0; 
%     end
end


for bin = 1:2
    for crit = 1:size(plotData,2)
        gliaNeighborRate(bin,crit) = sum(plotData(idxMat(:,bin) == 1,crit)) /sum(idxMat(:,bin) == 1);
    end
end

figure
bar(gliaNeighborRate)
legend('has glia neighbor','prob glia neighbor > 0.5','prob non glia neighbor > 0.5','location','NorthEast')
set(gca,'XTick',1:2)
set(gca,'XTickLabel',{'Glia','NonGlia'})
ylabel('Proportion of segments in class')
ylim([0 1])



%%
% probsTP = pGliaNeighbor(idxMat(:,1) == 1);
% probsFP = pGliaNeighbor(idxMat(:,3) == 1);    
% figure
% hist(probsTP(probsTP ~= 0),0.05:0.1:0.95);
% figure
% hist(probsFP(probsFP ~= 0),0.05:0.1:0.95);

    
%% visualize good glia: 4 113 139 206 212 218 good neuron : 552 575 579
% load(parameter.tracings(tracing).cubeFile,'raw');
% [x,y,z] = ind2sub(size(raw),segments(212).PixelIdxList);
% PixelList = [x y z];
% visualizeSegment(PixelList,raw,0,1);

    
%% edge numbers

neighborMats = {segments.neighborMat};
labels = cell2mat({segments.label});
numEdges = cellfun(@length,neighborMats);
mean(numEdges(labels == -1))
    
    
    
    


end

