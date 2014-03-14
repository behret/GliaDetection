function [partition] = getPartition(labelStruct,kfold)


%% prepare data

labels = labelStruct.labels;

% prepare partition indices
glia.unused = find(labels == 1);
nonGlia.unused = find(labels == 0);

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
    
end


end

