function [ SVMstruct ] = trainAndTestSVM(parameter)

load(parameter.featureFile);

%% parameter search
for i=1:15
    sigmas(i) = 2^(i-3);
    Cs(i) = 2^(i-1);
end
quan = quantile(featureMat(:,1),14);

for i=1:length(sigmas)
    for j=1:length(Cs)
        for k = 1:7
            % cut off smallest x% 
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


%% run with best parameters

% choose best param pair
choiceFun = @(x) x(1) + x(3) + (x(3) > 0.95);
[choiceSig,choiceC,choiceCutoff] = ind2sub(size(rates),find(cellfun(choiceFun,rates) == max(max(max(cellfun(choiceFun,rates))))));

[pred,rateFinal] = crossVal(featureMat(featureMat(:,1) > quan(choiceCutoff),:),labels(:,featureMat(:,1) > quan(choiceCutoff)),4,sigmas(choiceSig),Cs(choiceC),1);

save(parameter.testResultFile,'-v7.3');


end

