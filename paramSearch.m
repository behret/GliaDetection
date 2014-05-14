function maxTP = paramSearch(parameter,featureMat,labels,newFlag)


%% define ranges

% size cutoff 
% quan = quantile(featureMat(:,1),9);
% cutoffs = [0 quan(1:4)];
% cutoffs = [0 0.26:0.03:0.35];
cutoffs = 0;

% gamma
for i= -15:-1
    params{1}(i+16) = 2^(i);
end

% C
for i=1:15
    params{2}(i) = 2^(i);
end

% C weights
params{3} = [1 2 3];

% % for testing
% params{1} = [0.0001 0.001 0.01 0.1];
% params{2} = [32 256 1024 4096];
% params{3} = [1 2];
% cutoffs = 0;

%% get parameter combinations

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
rates = cell(length(combis),1);

parfor i = 1:length(combis)    
    rates{i} = crossVal(featureMat,labels,combis(i,:),cutoffs,4,'matlab');
end

% change back to right order
rates = rates(trueIdx);
combis = combis(trueIdx,:);
new = zeros(length(combis)*length(cutoffs),size(combis,2)+1);
for i = 1:length(combis)
    new(length(cutoffs)*(i-1)+1:length(cutoffs)*(i-1)+length(cutoffs),:) = [repmat(combis(i,:),length(cutoffs),1) cutoffs'] ;
end
combis = new;
rateMat = cell2mat(rates);



%% choose best params and save
% best = highest TPR at 15% glia prevalence (see rates defined in crossVal)

maxTP = max(rateMat(:,1));
resultParams = combis(rateMat(:,1) == maxTP,:);
resultParams = resultParams(1,:);

disp(['Maximal TPR at 15% prevalence: ' num2str(maxTP,3)]);
save(parameter.paramFile{newFlag+1},'-v7.3');    


%% plot results
% plotParamSearch( rateMat,combis )
% scatter(rateMat(:,2),rateMat(:,1));
% saveas(gcf,['C:\Users\behret\Dropbox\BachelorArbeit\Test' strrep(datestr(now),':','')],'pdf');


