function main()

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
miniParam(parameter);
time = toc;
disp(['Finished parameter search: '  num2str(time/60) ' minutes']);

tic
varyFeatures;
toc

end



