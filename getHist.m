function f = getHist(glia,nonGlia,name)
   
%if feature does not apply(e.g. no mito in segment)    
glia(isnan(glia)) = [];
nonGlia(isnan(nonGlia)) = [];


nrBins = 20;
minVal = min(min(glia),min(nonGlia));
maxVal = max(max(glia),max(nonGlia));

plotData = zeros(2,nrBins);

for i=1:length(glia)

    idx = floor((glia(i)-minVal)./((maxVal-minVal)./nrBins))+1;
    if glia(i) == minVal
        idx = idx+1;
    end
    if glia(i) == maxVal
        idx = idx-1;
    end
    plotData(1,idx) = plotData(1,idx) + 1;
end

for i=1:length(nonGlia)

    idx = floor((nonGlia(i)-(minVal))./((maxVal-minVal)./nrBins))+1;
    if nonGlia(i) == minVal
        idx = idx+1;
    end
    if nonGlia(i) == maxVal
        idx = idx-1;
    end
    plotData(2,idx) = plotData(2,idx) + 1;
end

plotData(1,:) =  plotData(1,:)./length(glia);
plotData(2,:) =  plotData(2,:)./length(nonGlia);


% close up, if range is too wide
maxBin = find(any(plotData(1,:)));
if(any(plotData(1,:) > 0.8) && plotData(2,maxBin)> 0.8)
    gliaNew = []; 
    for i=1:length(glia)
        idx = floor((glia(i)-minVal)./((maxVal-minVal)./nrBins))+1;
        if idx == maxBin
            gliaNew(end+1) = glia(i);
        end
    end
    nonGliaNew = [];
    for i=1:length(nonGlia)
        idx = floor((nonGlia(i)-minVal)./((maxVal-minVal)./nrBins))+1;
        if idx == maxBin
            nonGliaNew(end+1) = nonGlia(i);
        end
    end
    f = getHist(gliaNew,nonGliaNew,[name '-CloseUp']);
else    
    f = figure;
    plot(plotData(1,:));   
    hold on
    plot(plotData(2,:), 'r');  
    title(name);
    legend('glia','non-glia'); 
end
end

