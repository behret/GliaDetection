function [partition] = getPartition(labelStruct,kfold)


% isCut is fucked up ... would recursively call itself..change!



%% prepare data

labels = labelStruct.labels;
if ~isfield(labelStruct,'sizeFlag')
    labelStruct.sizeFlag = ones(size(labels));
end
isCut = (labelStruct.sizeFlag == 0);

% if there is a cutoff, distribute the cut off segments evenly over the
% partitions (for global rate calculation)
if isCut
    labelStructCut = labelStruct;
    labelStructCut.sizeFlag = imcomplement(labelStruct.sizeFlag);
    partitionCut = getPartition(labelStructCut,kfold);
end

% prepare partition indices
glia.unused = find(labels == 1 & labelStruct.sizeFlag == 1);
nonGlia.unused = find(labels == 0 & labelStruct.sizeFlag == 1);

glia.part = cvpartition(length(glia.unused),'kfold',kfold);
nonGlia.part = cvpartition(length(nonGlia.unused),'kfold',kfold);

glia.used = [];
nonGlia.used = [];


for i = 1:kfold   
    
    thisTestGlia = randsample(glia.unused,glia.part.TestSize(i));
    glia.unused = setdiff(glia.unused,thisTestGlia);
    thisTrainGlia = [glia.unused ; glia.used];
    glia.used = [glia.used ; thisTestGlia];    

    thisTestNonGlia = randsample(nonGlia.unused,nonGlia.part.TestSize(i));
    nonGlia.unused = setdiff(nonGlia.unused,thisTestNonGlia);
    thisTrainNonGlia = [nonGlia.unused ; nonGlia.used];
    nonGlia.used = [nonGlia.used ; thisTestNonGlia];        
       
    partition(i).test = [thisTestGlia ; thisTestNonGlia];
    partition(i).train = [thisTrainGlia ; thisTrainNonGlia];
    if isCut
        partition(i).testCut = partitionCut(i).test;
        partition(i).trainCut = partitionCut(i).train;
    end
    
end

% %doesnt make sense... different for every cross val
% if getEval
%     % get an evaluation set, that is not used for parameter search -> get
%     % better measure of generalization
%     evalSet = partition(1);
%     partition = partition(2:end);
%     % exclude evalSet from training
%     for i = 1:length(partition)
%         partition(i).train = setdiff(partition(i).train,evalSet.test);
%     end
% else
%     evalSet = [];
% end

end

