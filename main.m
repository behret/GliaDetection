function main()

parameter = setParam;

tic
getLabeledSegments(parameter,0);
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

%%%

tic
wholeCubeData;
time = toc;
disp(['Got whole cube data: '  num2str(time/60) ' minutes']);

tic
predictCubes(parameter);
time = toc;
disp(['Finished predicting cubes: '  num2str(time/60) ' minutes']);



end



