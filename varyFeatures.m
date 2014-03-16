function varyFeatures
parameter = setParam;
featureNums = [158 120 90 60 40];  

matlabpool 8
for i = 1:length(featureNums)
    tic
    parameter.numFeatures = featureNums(i);    
    parameter.testResultFile = ['G:\Benjamin\dataGraph\results\featureSelection\result' num2str(parameter.numFeatures)];
    paramSearch(parameter);
    time = toc;
    disp(['run ' num2str(i) ': ' num2str(time/60) ' minutes' ]);
end
matlabpool close
generateSelectionPlot
saveFig('featureSelectionGraph');
