function boundary = getDecisionBoundary( probs,fraction,labels )

%prevalance
if nargin == 2
    [pSorted,idx] = sort(probs,'descend');
    numPositives = floor(length(probs)*fraction);
    boundary = pSorted(numPositives);
end

%fpr
if nargin == 3
    [pSorted,idx] = sort(probs,'descend');
    lSorted = labels(idx);
    maxFP = floor(sum(labels == 0)*fraction);
    numFP = cumsum(lSorted == 0);
    boundaryIdx = find(numFP == maxFP);
    boundaryIdx = boundaryIdx(1);
    boundary = pSorted(boundaryIdx);
end

end

