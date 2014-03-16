function [cutChoice,prob,predCut] = sizeCutoffRVM( pred, labels, cutoffs,sizes,fprVal)


maxes = zeros(1,length(cutoffs));

for cut = 1:length(cutoffs)

    predCut = pred;
    cutIdx = sizes<cutoffs(cut);
    predCut(cutIdx,1:2) = zeros(sum(cutIdx),2);

    % ROC and PR
    [a b] = sort(predCut(:,2),'descend');
    predSorted = predCut(b,:);

    roc.pos = 0;
    roc.neg = 0;
    roc.stepPos = 1/sum(labels);
    roc.stepNeg = 1/sum(labels == 0);

    pr.total = sum(labels);
    pr.found = 0;
    pr.tp = 0;
    for i = 1: length(predSorted)
        %ROC
        if predSorted(i,3)
            roc.pos = roc.pos + roc.stepPos;
        else
            roc.neg = roc.neg + roc.stepNeg;
        end
        x(1,i) = roc.neg;
        y(1,i) = roc.pos;

        %PR  
        pr.tp = pr.tp + predSorted(i,3);
        %recall
        x(2,i) = pr.tp/pr.total;
        %precision
        y(2,i) = pr.tp/i;
        
        if maxes(cut) == 0    
            if x(1,i) > fprVal
                maxes(cut) = y(1,i-1);
                probs(cut) = mean([predSorted(i,2) predSorted(i-1,2)]);
            end
        end

    end
end

[maxVal,maxIdx] = max(maxes);
cutIdx = sizes<cutoffs(maxIdx);
predCut = pred(cutIdx == 0,:);
predCut(:,1) = predCut(:,2) >= probs(maxIdx);
labelsCut = labels(cutIdx == 0);
cutChoice = cutoffs(maxIdx);
prob = probs(maxIdx);

end

