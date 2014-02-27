function rateEstimate = paramSearch(parameter)

load(parameter.featureFile,'featureMat','labelStruct');

labelStruct = labelStruct;
featureMat = featureMat;

%% define ranges

% size cutoff
quan = quantile(featureMat(:,1),9);
params{1} = [0 quan(1:4)];

% gamma
for i= -8:-1
    params{2}(i+9) = 2^(i*2);
end

% C
for i=1:8
    params{3}(i) = 2^(i*2);
end

% C weights
params{4} = [1 2 2.5 3 4];

%try
% params{1} = 0;
% params{2} = [0.007 0.05];
% params{3} = [128 256];
params{4} = 1;

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

%permute indices to get better distribution on workers
randIdx = randperm(length(combis));
[sor,trueIdx] = sort(randIdx);
combis = combis(randIdx,:);
rates = cell(1,length(combis));

parfor i = 1:length(combis)
%     try
        rate = crossVal(featureMat,labelStruct,combis(i,:),4,'matlab');
%     catch
%         rate = [0 0;0 0];
%     end
    if any(rate(:,1) == 0 & rate(:,2) == 0)
        rate = [0 0;0 0];
    end  
    rates{i} = mean(rate);
end

% change back to right order
rates = rates(:,trueIdx);
combis = combis(trueIdx,:);
%% plot results

f = figure;
hold on;
rateMat = cell2mat(rates');
scatter(rateMat(:,2),rateMat(:,1),20,[1 0 0]);
xlabel('False positive rate');
ylabel('True positive rate');
xlim([0 0.2])
ylim([0 0.8])
noAdjIdx = (combis(:,1) == 0 & combis(:,4) == 1);
scatter(rateMat(noAdjIdx,2),rateMat(noAdjIdx,1),20,[0 1 0]);
% print(f,'-dpdf','C:\Users\behret\Dropbox\BachelorArbeit\trainBigTestAll');


%% choose best params, get rate estimate and save
choiceFun = @(x) x(1) + (x(2) < 0.05);
resultParams = combis(cellfun(choiceFun,rates) == max(max(cellfun(choiceFun,rates))),:);
rateEstimate = getRateEstimate(parameter,resultParams,'matlab');

save(parameter.testResultFile,'-v7.3');


%% try size cutoffs after gamma C search

% quan = quantile(featureMat(:,1),9);
% cutoffs = [0 quan(1:4)];
% 
% for i= 1:length(cutoffs)
%     
%     paramsCut =  resultParams;
%     paramsCut(1) = cutoffs(i);
%    
%     try
%         rateCut = crossVal(featureMat,labelStruct,paramsCut,4,'matlab');
%     catch
%         rateCut = [0 0;0 0];
%     end
%     if any(rateCut(:,1) == 0 & rateCut(:,2) == 0)
%         rateCut = [0 0;0 0];
%     end  
%     ratesCut{i} = mean(rateCut);
% end
% rateMatCut = cell2mat(ratesCut');
% figure
% scatter(rateMatCut(:,2),rateMatCut(:,1),20,[1 0 0]);

%% try c adjust after gamma C search

% cAdjust = [1 2 2.5 3 4];
% 
% 
% for i= 1:length(cAdjust)
%     
%     paramsNew =  resultParams;
%     paramsNew(4) = cAdjust(i);
%    
%     try
%         rateNew = crossVal(featureMat,labelStruct,paramsNew,4,'matlab');
%     catch
%         rateNew = [0 0;0 0];
%     end
%     if any(rateNew(:,1) == 0 & rateNew(:,2) == 0)
%         rateNew = [0 0;0 0];
%     end  
%     ratesNew{i} = mean(rateNew);
% end
% rateMatNew = cell2mat(ratesNew');
% figure
% scatter(rateMatNew(:,2),rateMatNew(:,1),20,[1 0 0]);


