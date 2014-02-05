function f = getHist(glia,nonGlia,name)

nrBins = 20;
minVal = min(min(glia),min(nonGlia));
maxVal = max(max(glia),max(nonGlia));

plotData = zeros(2,nrBins);

%change to h = hist(glia)...

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

%normalize
plotData(1,:) =  plotData(1,:)./length(glia);
plotData(2,:) =  plotData(2,:)./length(nonGlia);


% close up, if range is too wide
maxBin = find(any(plotData(1,:) > 0.8));
if(~isempty(maxBin) && plotData(2,maxBin)> 0.8)
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
    f = getHist(gliaNew,nonGliaNew,[name '-CloseUp bin ' num2str(maxBin)]);
else  
    %set xvals from bin to real val
    binVals = minVal:(maxVal-minVal)/nrBins:maxVal;
    binVals = binVals(1:end-1);
    
    f = figure('Visible', 'off' );
    plot(binVals,plotData(1,:));   
    hold on
    plot(binVals,plotData(2,:), 'r');  
    title(name);
    if(nargin ==3)
        legend('glia','non-glia'); 
    else
        legend('right','wrong');
    end
end
end

