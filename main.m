function main

diary on

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
    % include neighbors after first prediction
    % do param search and predict, then add additional features, run again

    maxTP(1) = miniParam(parameter,0)
    rates(1,1:6) = predict(parameter,0)
    
    addGraphFeatures(parameter);   
    maxTP(2) = miniParam(parameter,1)
    rates(2,1:6) = predict(parameter,1)

else parameter.includeNeighbors
    % include neighbors directly or dont include neighbors
    
    miniParam(parameter,0);
    rates(1,1:6) = predict(parameter,0)
end             
time = toc;
disp(['Finished parameter search and testing: '  num2str(time/60) ' minutes']);



diary 'C:\Users\behret\Dropbox\BachelorArbeit\diary.txt'
diary off