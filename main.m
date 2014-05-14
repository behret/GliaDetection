function main

% there are two functions for predictions: predict and predictCubes
% predictCubes uses 2 regions as training and predicts the third for all
% three regions
% predict uses crossVal on all labeled segments. all unlabeled segments are
% predicted using the labeled segments as training data


diary 'C:\Users\behret\Dropbox\BachelorArbeit\diary.txt'

parameter = setParam;

tic
getLabeledSegments(parameter);
time = toc;
disp(['Got segments, time: ' num2str(time/60) ' minutes' ]);

tic
calcFeatures(parameter);
time = toc;
disp(['Calculated Features, time: ' num2str(time/60) ' minutes']);
 
tic
if parameter.includeNeighbors == 1
    % conduct param search and predict, then add additional features, run again
    maxTP(1) = miniParam(parameter,0);
    rates{1} = predictCubes(parameter,0);
    addGraphFeatures(parameter);   
    maxTP(2) = miniParam(parameter,1);
    rates{2} = predictCubes(parameter,1);
else
    maxTP = miniParam(parameter,0);
    rates = predictCubes(parameter,0);
end             
time = toc;
disp(['Finished parameter search and testing: '  num2str(time/60) ' minutes']);

diary off

