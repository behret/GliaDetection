function [ output_args ] = analyzeMisclassSize( featureMat,labelStruct,param)

cutoffs = 0;
[rates,pred] = crossVal(featureMat,labelStruct,param,cutoffs,4,'matlab');
pred = pred{1};


TPidx = find(pred(:,1) == 1 & pred(:,3) == 1);
FPidx = find(pred(:,1) == 1 & pred(:,3) == 0);

sizes = featureMat(:,1);
load('G:\Benjamin\dataGraph\features.mat', 'scaleVals');
xvals = min(min(sizes(TPidx),min(sizes(FPidx)))):0.0112:max(max(sizes(TPidx),max(sizes(FPidx))));
cumTP = cumsum(hist(sizes(TPidx),xvals));
cumFP = cumsum(hist(sizes(FPidx),xvals));
figure 
hold on
xvals = xvals*scaleVals(1,2)+scaleVals(1,1);
%xvals = round(xvals*10)/10;
plot(xvals,cumTP/max(cumTP)*100,'g-','LineWidth',2)
plot(xvals,cumFP/max(cumFP)*100,'r-','LineWidth',2)
plot([xvals(max(find(23 > cumFP/max(cumFP)*100))) xvals(max(find(23 > cumFP/max(cumFP)*100)))],[0 100],'k--');
%set(gca,'XTick',xvals(1:10:61))
%set(gca,'XTickLabel',{num2str(exp(6)) num2str(exp(7)) num2str(exp(8)) num2str(exp(9)) num2str(exp(10)) num2str(exp(11)) num2str(exp(12))})
xlim([min(xvals) max(xvals)]);
legend('True Positives','False Positives','Possible Cutoff','location','SouthEast')
xlabel('log(#Voxels)')
ylabel('% of respective error type')


end

