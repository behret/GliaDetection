function rates = runRVM

parameter = setParam;
sigmas = 1:0.5:10;

for i = 1:length(sigmas)
    rates(i,1:8) = RVMcross(parameter,4,sigmas(i));
    disp(i);
end



[maxVal idx] = max(rates(:,1));
[maxValCut idxCut] = max(rates(:,5));

sigma = sigmas(idx);
prob = rates(idx,4);
[pred ratesEstimate] = testRVM( parameter,prob,sigma,0);


sigmaCut = sigmas(idxCut);
probCut = rates(idxCut,8);
cutVal = rates(idxCut,7);
[predCut rateEstimateCut] = testRVM( parameter,probCut,sigmaCut,cutVal);

load(parameter.featureFile,'labelStructAll','partition');
labels = labelStructAll.labels(partition.test);
[AUC x y bound] = RocAndPrRVM( pred, labels, prob, predCut,probCut);


end