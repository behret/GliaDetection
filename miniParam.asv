function rates = miniParam(parameter)

% jm = parcluster;
% job = batch(jm,@paramSearch,1,{parameter},'MatlabPool',8);
% wait(job);
% rates = fetchOutputs(job);
% destroy(job);

matlabpool 10
tic
params = paramSearch(parameter);
toc
matlabpool close

%params = [0.357502074507019,0.00390625000000000,16384,1];
rates = getRateEstimate(parameter,params,'matlab');

end


