function partition = getPartition(labels,kfold)


%% prepare data


% prepare partition indices
glia.unused = find(labels(:,1) == 1 & labels(:,2) == 1);
nonGlia.unused = find(labels(:,1) == 0 & labels(:,2) == 1);

glia.part = cvpartition(length(glia.unused),'kfold',kfold);
nonGlia.part = cvpartition(length(nonGlia.unused),'kfold',kfold);

glia.used = [];
nonGlia.used = [];

%% training and prediction

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

