function [] = findGlia(tracings)
%ISSUES
% calc features for every object directly and drop pixellist => memory,
% parallel!


%%  get segments

if(nargin == 0)
    load('G:\Benjamin\combi\tracings');

    tracings(1).path = 'R:\Benjamin\GliaDetection\data\tracings\heiko.nml';
    tracings(1).bbox = [4096 4730; 4478 5240; 2251 2400];
    tracings(1).skel = skeleton(tracings(1).path,0);
    tracings(1).segments = getLabeledSegments(tracings(1).skel,tracings(1).seg,tracings(1).bbox);
    
    tracings(2).path = 'R:\Benjamin\GliaDetection\data\tracings\alex.nml';
    tracings(2).bbox = [1417 1717; 4739 5039; 890 1190];
    tracings(2).skel = skeleton(tracings(2).path,0);
    tracings(2).segments = getLabeledSegments(tracings(2).skel,tracings(2).seg,tracings(2).bbox);
    
    save('G:\Benjamin\combi\tracings','-v7.3');
end



%% calculate features
%load('G:\Benjamin\combi\tracings');
featureFlag = [0 1];

for i = [1 2]
    disp(['starting feature calculation tracing ' num2str(i)]);
    tic
    [tracings(i).feat.scaled,tracings(i).feat.unscaled,tracings(i).feat.labels,tracings(i).feat.names] ...
        = calcFeatures(tracings(i).segments,featureFlag,tracings(i).raw);
    toc
end

featureMat = [tracings(1).feat.scaled ; tracings(2).feat.scaled];
featureMat(isnan(featureMat)) = 0;
labels = [tracings(1).feat.labels  tracings(2).feat.labels];

disp('done calculating features');
featuresAllInfo = {tracings.feat};
save('G:\Benjamin\combi\features','featuresAllInfo','featureMat','labels','-v7.3');


%% plot distinction

path = ['G:\Benjamin\combi\histos\' strrep(datestr(now),':','')];
mkdir(path);
%path = 'C:\Users\behret\Dropbox\BachelorArbeit';

for i=1:size(featureMat,2)   
    fig = getHist(featureMat(find(labels),i),featureMat(find(imcomplement(labels)),i),featuresAllInfo{1}.names{i});   
    if(i == 1)
        print(fig, '-dpsc2', [path '\distinction']);
    else
        print(fig, '-dpsc2', [path '\distinction'], '-append'); 
    end
end

%% SVM: train and test
tic
%load('G:\Benjamin\combi\features');

% parameter search
disp('starting parameter search');
for i=1:10
    sigmas(i) = 2^(i-3);
    Cs(i) = 2^(i);
end


quan = quantile(featureMat(:,1),9);
for i=1:length(sigmas)
    for j=1:length(Cs)
        for k = 1:7
            
            labelsCut = labels(:,featureMat(:,1) > quan(k));
            featureMatCut = featureMat(featureMat(:,1) > quan(k) ,:);
            
            try
                [pred,rate] = crossVal(featureMatCut,labelsCut,4,sigmas(i),Cs(j),0); 
                rates{i,j,k} = mean(rate);
            catch
                rates{i,j,k} = [0,1,1,0];
            end
        end
    end
end

save('G:\Benjamin\combi\rates' ,'rates');
% scatter good combinations
filterFun = @(x) x(1) > 0.5 && x(3) > 0.80;
filteredRates = cellfun(filterFun,rates);
[sig,c,cutoffSize] = ind2sub(size(filteredRates),find(filteredRates));
figure
scatter3(sig,c,cutoffSize);
xlabel('sigma');
ylabel('C');
zlabel('cutoff size');

% choose best param pair
choiceFun = @(x) x(1) + x(3) + (x(3) > 0.8);
[choiceSig,choiceC,choiceCutoff] = ind2sub(size(rates),find(cellfun(choiceFun,rates) == max(max(max(cellfun(choiceFun,rates))))));

[pred,rateFinal] = crossVal(featureMat(featureMat(:,1) > quan(choiceCutoff),:),labels(:,featureMat(:,1) > quan(choiceCutoff)),4,sigmas(choiceSig),Cs(choiceC),1);
save('G:\Benjamin\combi\test','-v7.3');
disp('done training and testing');
toc

%%%%% analysis in KLEE
%%%%% analyze wrong/right


end



