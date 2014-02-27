function RocAndPr( pred, labels )




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
end

figure
subplot(1,2,1)
plot(x(1,:),y(1,:),[0 1],[0 1]);
xlim([0 1]);
ylim([0 1]);
xlabel('False positive rate');
ylabel('True positive rate');


% uistr(1) = {['% True Positives: ' num2str(rates(1),'%1.2f')]};
% uistr(2) = {['% False Positives: ' num2str(rates(2),'%1.2f') ]};
% uicontrol('Style','text','Position',[140 350 120 30],...
%           'String',uistr);

subplot(1,2,2)
plot(x(2,:),y(2,:));

xlim([0 1]);
ylim([0 1]);
xlabel('Recall');
ylabel('Precision');




end

