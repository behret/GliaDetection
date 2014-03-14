function miniParam(parameter)

% jm = parcluster;
% job = batch(jm,@paramSearch,1,{parameter},'MatlabPool',8);
% wait(job);
% rates = fetchOutputs(job);
% destroy(job);

matlabpool 8
tic
paramSearch(parameter);
toc
matlabpool close

end


