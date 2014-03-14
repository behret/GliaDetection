function plotParamSearch( rateMat,combis )

%%

noAdjIdx = (combis(:,3) == 1 & combis(:,4) == 0);
cOnlyIdx = (combis(:,3) ~= 1 & combis(:,4) == 0);
sizeOnlyIdx = (combis(:,3) == 1 & combis(:,4) ~= 0);
cAndSizeIdx = (combis(:,3) ~= 1 & combis(:,4) ~= 0);
sizeAllIdx = (combis(:,4) ~= 0);

%% paramSearch (w/o size)
f = figure;
hold on;
xlabel('False positive rate');
ylabel('True positive rate');
% xlim([0 0.1])
% ylim([0 0.8])
scatter(rateMat(cOnlyIdx,2),rateMat(cOnlyIdx,1),36,[1 0 0],'.');
scatter(rateMat(noAdjIdx,2),rateMat(noAdjIdx,1),36,[0 0 1],'.');

legend('with C adjustment','without C adjustment','location','SouthEast')

% saveFig('paramSearch');
% print(f,'-dpdf','C:\Users\behret\Dropbox\BachelorArbeit\trainBigTestAll');


%% size vs all
f = figure;
hold on;
xlabel('False positive rate');
ylabel('True positive rate');

scatter(rateMat(sizeAllIdx,2),rateMat(sizeAllIdx,1),36,[1 0 0],'.');
scatter(rateMat(noAdjIdx,2),rateMat(noAdjIdx,1),36,[0 0 1],'.');
scatter(rateMat(cOnlyIdx,2),rateMat(cOnlyIdx,1),36,[0 0 1],'.');

legend('with size cutoff','without size cutoff','location','SouthEast')
%saveFig('paramSearchSize');

end

