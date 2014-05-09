function mat = graphFeatures(segments)

for i = 1:length(segments)
    
    neighborMat = segments(i).neighborMat;
    
    if ~isempty(neighborMat)
        mat(i,1) = max(neighborMat(:,2));
        mat(i,2) = min(neighborMat(:,2));
        mat(i,3) = mean(neighborMat(:,2));
        mat(i,4) = median(neighborMat(:,2));
        mat(i,5) = std(neighborMat(:,2));
        mat(i,6) = size(neighborMat,1);
    else 
        mat(i,1:6) = zeros(1,6); 
    end
    
end

end