function featureMat = calcIntensity(calcFilters)

parameter = setParam;

% Filterbank
if(calcFilters)
    tic;
    miniEdges(parameter);
    time = toc;
    display(['Graph construction & filterbank: ' num2str(time/3600) ' hours']);
end

%Feature extraction
tic;
featureMat = miniFeatures(parameter);
time = toc;
display(['Feature extraction: ' num2str(time/3600) ' hours']);

end
