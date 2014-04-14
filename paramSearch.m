function paramSearch(parameter)

load(parameter.featureFile,'featureMat','labelStruct');

labelStruct = labelStruct;
featureMat = featureMat;

if parameter.numFeatures ~= 159
    load('featureFilterGraph');
    idx(idx ==1) = [];
    idx = [1 idx];
    featureMat = featureMat(:,idx(1:parameter.numFeatures));
end
%% define ranges

% size cutoff
quan = quantile(featureMat(:,1),9);
% cutoffs = [0 quan(1:4)];
cutoffs = [0 0.26:0.03:0.35];

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
% params{1} = [0.25 0.5];
% params{2} = [16 32];
% params{3} = [1 2];
% cutoffs = [0 .3];

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
rates = cell(length(combis),1);

parfor i = 1:length(combis)    
    rates{i} = crossVal(featureMat,labelStruct,combis(i,:),cutoffs,4,'matlab');
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

save([parameter.testResultFile 'Before'],'-v7.3');
scatter(rateMat(:,5),rateMat(:,4));
saveas(gcf,'C:\Users\behret\Dropbox\BachelorArbeit\TestNewFeatures','pdf');

%% choose best params, get rate estimate and save
%with cutoff
maxTP = max(rateMat(rateMat(:,2) < 0.05,1));
resultParams = combis(rateMat(:,1) == maxTP & rateMat(:,2) < 0.05,:);
rateEstimate(1,1:5) = getRateEstimate(parameter,resultParams,'matlab');
%without cutoff
rateMatNoCut = rateMat(combis(:,4) == 0,:);
combisNoCut = combis(combis(:,4) == 0,:);
maxTP = max(rateMatNoCut(rateMatNoCut(:,2) < 0.055,1));
resultParams = combisNoCut(rateMatNoCut(:,1) == maxTP & rateMatNoCut(:,2) < 0.055,:);
rateEstimate(2,1:5) = getRateEstimate(parameter,resultParams,'matlab');

%% plot results
plotParamSearch( rateMat,combis )

%% plot data for feature selection evaluation

K = convhull(rateMat(:,1),rateMat(:,2));
K = [K rateMat(K,:)];
lastVal = 0;
for i = 1:length(K)
    if K(i,2) >= lastVal  
        plotVals(i,1:3) = K(i,:);
        lastVal = K(i,2);
    else
        break;
    end
end
save(parameter.testResultFile,'-v7.3');


