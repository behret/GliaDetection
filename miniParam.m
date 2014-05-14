function maxTP = miniParam(parameter,newFlag)
% conduct parameter search using the labeled data

%get labeled data
featureMatAll = [];
labelsAll = [];

for tracing = parameter.tracingsToUse
    if newFlag
        load(parameter.tracings(tracing).featureFileNew,'featureMat','labels');
    else
        load(parameter.tracings(tracing).featureFile,'featureMat','labels');
    end
    labeledIdx = labels ~= -1;
    featureMatAll = [featureMatAll ; featureMat(labeledIdx,:)];
    labelsAll = [labelsAll ; labels(labeledIdx)];
end

% start search
matlabpool 8
maxTP = paramSearch(parameter,featureMatAll,labelsAll,newFlag);
matlabpool close



% jm = parcluster;
% job = batch(jm,@paramSearch,1,{parameter},'MatlabPool',8);
% wait(job);
% rates = fetchOutputs(job);
% destroy(job);

end


