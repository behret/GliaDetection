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
miniParam(parameter,0);
time = toc;
disp(['Finished parameter search: '  num2str(time/60) ' minutes']);

for i = 1:10
    parameter = setParam;
    miniParam(parameter,i~=1);
    rates(i,1:6) = predict(parameter,i~=1)
    addGraphFeatures(parameter);
end
plot(rates(:,4));
saveas(gcf,'C:\Users\behret\Dropbox\BachelorArbeit\TestResult','pdf');
save([parameter.testResultFile 'all']);


end



