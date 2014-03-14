function rates = runRVM

parameter = setParam;
sigmas = 1:10;

for i = 1:length(sigmas)
    tic
    rates(i,1:2) = RVMcross(parameter,4,sigmas(i));
    toc
end


end

