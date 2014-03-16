nums = {'158' '120' '90' '60' '40'};
%nums = {'158' '120' '90' '60'}; 
spec = linspecer(length(nums));

figure
hold on

for i = 1:length(nums)

    load(['G:\Benjamin\dataGraph\results\featureSelection\result' nums{i} '.mat'], 'plotVals' )
    line(plotVals(:,3),plotVals(:,2),'color',spec(i,:),'LineWidth',2)
    %plot(plotVals(:,3),plotVals(:,2),'k.')
    xlabel('False positive rate');
    ylabel('True positive rate');
    xlim([0 0.15])
    
end

leg = legend(nums{:},'location','SouthEast');
v = get(leg,'title');
set(v,'string','#features');
