function [AUC,x,y,boundaryIdx] = RocAndPr( pred, labels,cutVal, predCross,labelsCross,predTrain, labelsTrain )


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
        if predSorted(i,2) < cutVal
            boundaryIdx = i-1;
        end
    end
    
end

AUC = trapz(x(1,:),y(1,:));

if nargin == 6
    [AUCcross,xCross,yCross,boundaryIdxCross] = RocAndPr(predCross,labelsCross,1);
    [AUCtrain,xTrain,yTrain,boundaryIdxTrain] = RocAndPr(predTrain,labelsTrain,1);
end 

if nargin ~= 2
    f = figure;
    set(f, 'Position', [500 500 1200 500]);
    subplot(1,2,1)
    hold on
    plot(x(1,:),y(1,:));
    if nargin == 6
        plot(xCross(1,:),yCross(1,:),'g-');
        plot(xTrain(1,:),yTrain(1,:),'r-');
        legend('Test','Cross validation','Train','location','SouthEast');
        plot(xTrain(1,boundaryIdxTrain),yTrain(1,boundaryIdxTrain), 'k.','MarkerSize',20);
        plot(xCross(1,boundaryIdxCross),yCross(1,boundaryIdxCross), 'k.','MarkerSize',20);
    end
    plot(x(1,boundaryIdx),y(1,boundaryIdx), 'k.','MarkerSize',20)
    plot([0 1],[0 1],'k-')

    xlim([0 1]);
    ylim([0 1]);
    xlabel('False positive rate');
    ylabel('True positive rate');

    % uistr(1) = {['% True Positives: ' num2str(rates(1),'%1.2f')]};
    % uistr(2) = {['% False Positives: ' num2str(rates(2),'%1.2f') ]};
    % uicontrol('Style','text','Position',[140 350 120 30],...
    %           'String',uistr);

    subplot(1,2,2)
    hold on
    plot(x(2,:),y(2,:));
    if nargin == 6
        plot(xCross(2,:),yCross(2,:),'g-');
        plot(xTrain(2,:),yTrain(2,:),'r-');
        plot(xTrain(2,boundaryIdxTrain),yTrain(2,boundaryIdxTrain), 'k.','MarkerSize',20);
        plot(xCross(2,boundaryIdxCross),yCross(2,boundaryIdxCross), 'k.','MarkerSize',20);
        legend('Test','Cross validation','Train','location','SouthWest');
    end
    plot(x(2,boundaryIdx),y(2,boundaryIdx), 'k.', 'MarkerSize',20)

    xlim([0 1]);
    ylim([0 1]);
    xlabel('Recall');
    ylabel('Precision');
end



end

