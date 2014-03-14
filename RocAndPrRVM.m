function [AUC,x,y,boundaryIdx] = RocAndPrRVM( pred, labels,probVal, predCut, probValCut)

boundaryIdx = 0;

% ROC and PR
[a b] = sort(pred(:,2),'descend');
predSorted = pred(b,:);

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
    
    if boundaryIdx == 0    
        if predSorted(i,2) < probVal
            boundaryIdx = i-1;
        end
    end
    
end

AUC = trapz(x(1,:),y(1,:));

if nargin == 5
    [AUCcut,xCut,yCut,boundaryIdxCut] = RocAndPrRVM(predCut,labels,probValCut);
end 

if nargin ~= 3
    f = figure;
    set(f, 'Position', [500 500 600 500]);
    %subplot(1,2,1)
    hold on
    plot(x(1,:),y(1,:));
    if nargin == 5
        plot(xCut(1,:),yCut(1,:),'g-');
        legend('Without cutoff','With cutoff','location','SouthEast');
        plot(xCut(1,boundaryIdxCut),yCut(1,boundaryIdxCut), 'k.','MarkerSize',20);
    end
    plot(x(1,boundaryIdx),y(1,boundaryIdx), 'k.','MarkerSize',20)
    plot([0 1],[0 1],'k-')

    xlim([0 1]);
    ylim([0 1]);
    xlabel('False positive rate');
    ylabel('True positive rate');

    %subplot(1,2,2)
    f = figure;
    set(f, 'Position', [500 500 600 500]);
    hold on
    plot(x(2,:),y(2,:));
    if nargin == 5
        plot(xCut(2,:),yCut(2,:),'g-');
        legend('Without cutoff','With cutoff','location','SouthWest');
        plot(xCut(2,boundaryIdxCut),yCut(2,boundaryIdxCut), 'k.','MarkerSize',20);
    end
    plot(x(2,boundaryIdx),y(2,boundaryIdx), 'k.', 'MarkerSize',20)

    xlim([0 1]);
    ylim([0 1]);
    xlabel('Recall');
    ylabel('Precision');
end

end

