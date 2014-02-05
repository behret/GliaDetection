function result = paramSearch(parameter)

%%
load(parameter.featureFile,'featureMatParam','labelsParam');

featureMat = featureMatParam;
labels = labelsParam;

%% define ranges

% size cutoff
siz = 5;
quan = quantile(featureMat(:,1),2*siz-1);
params{1} = quan(1:2);

% gamma
for i= -15:-1
    params{2}(i+16) = 2^i;
end

% C
for i=1:15
    params{3}(i) = 2^i;
end

params{4} = 1;

% C weights
params{4} = [1.0000    2.0000    2.5000    3.0000    3.5000    4.0000    4.5000    5.0000    7.0000   10.0000];
%%%try
% params{1} = [0.1 0.3];
% params{2} = [0.007 0.05];
% params{3} = [128 256];
% params{4} = 1;

%% get param combinations

cols = 0;
lines = 1;
combis = 0;
for i=1:length(params) 
    numPars = length(params{i});
    cols = cols+1;
    lines = lines.*numPars;      
    combis = repmat(combis,numPars,1);
    if(i ~= 1)
        combis = [combis zeros(lines,1)];
    end
    for k=1:lines
        combis(k,cols) = params{i}(1 + floor((k-1)./(lines./numPars)));
    end
end   


%% do search

parfor i = 1:length(combis)
%     rateLib = crossVal(featureMat,labels,combis(i,:),4,'libsvm',1);
%     if any(rateLib(:,1) == 0 & rateLib(:,2) == 0)
%         rateLib= [0 0;0 0];
%     end  
%     ratesLib{i} = mean(rateLib);

    rateMatlab = crossVal(featureMat,labels,combis(i,:),4,'matlab');
    if any(rateMatlab(:,1) == 0 & rateMatlab(:,2) == 0)
        rateMatlab = [0 0 0 0;0 0 0 0];
    end  
    ratesMatlab{i} = mean(rateMatlab);
end

rates = ratesMatlab;

f = figure;
hold on;
rateMat = cell2mat(rates');
scatter(rateMat(:,2),rateMat(:,1),20,[1 0 0]);
scatter(rateMat(:,4),rateMat(:,3),20,[0 1 0]);
print(f,'-dpdf','C:\Users\behret\Dropbox\BachelorArbeit\ratesGlobal');


%% choose best params and save
choiceFun = @(x) x(1) + (x(2) < 0.05);
choice = find(cellfun(choiceFun,rates) == max(max(cellfun(choiceFun,rates))));

result = combis(choice,:);

save(parameter.testResultFile,'-v7.3');

end

