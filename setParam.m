function parameter = setParam()

parameter.useGraph = 1;

if parameter.useGraph 
    dataDir = 'dataGraph';
else
    dataDir = 'data';
end

parameter.profileDir = ['G:\Benjamin\' dataDir '\profiles\' strrep(datestr(now),':','') ];
%mkdir(parameter.profileDir);
parameter.testResultFile = ['G:\Benjamin\' dataDir '\results\resultVaryC'];
parameter.tracingsToUse = [1];
parameter.featureFile = ['G:\Benjamin\' dataDir '\featuresSmall'];
% parameter.filter = {{'sortedeigenvalueshessian' [3 5] []}...
%      {'gaussiansmoothedgradmagnitude' [3 5] []}...
%      {'intensitygaussiansmoothed' [3 5] []}...
%      {'sortedeigenvaluesstructure' [3 5] [5 7]}...
%      {'laplaceofgaussian' [3 5] []}...
%      {'differenceofgaussians' [3 5] []}};

 parameter.filter = {{'sortedeigenvalueshessian' [3 5] []}...
     {'gaussiansmoothedgradmagnitude' [3 5] []}...
     {'intensitygaussiansmoothed' [3 5] []}...
     {'laplaceofgaussian' [3 5] []}...
     {'differenceofgaussians' [3 5] []}};

 
parameter.tracings(1).nml = ['G:\Benjamin\' dataDir '\tracing1\densetracing.nml'];
parameter.tracings(1).bbox = [4097 4736; 4481 5248; 2250 2450]-1; % offset in cubes!
parameter.tracings(1).cubeFile = ['G:\Benjamin\' dataDir '\tracing1\cubesAll'];
parameter.tracings(1).segmentFile = ['G:\Benjamin\' dataDir '\tracing1\segments'];
parameter.tracings(1).filterdCubesDir = ['G:\Benjamin\' dataDir '\tracing1\filterdCubes\'];
parameter.tracings(1).graphFile = ['G:\Benjamin\' dataDir '\tracing1\graph'];

parameter.tracings(2).nml = ['G:\Benjamin\' dataDir '\tracing2\densetracing.nml'];
parameter.tracings(2).bbox = [1417 1717; 4739 5039; 890 1190]-1; % offset in cubes!
parameter.tracings(2).cubeFile = ['G:\Benjamin\' dataDir '\tracing2\cubesAll'];
parameter.tracings(2).segmentFile = ['G:\Benjamin\' dataDir '\tracing2\segments'];
parameter.tracings(2).filterdCubesDir = ['G:\Benjamin\' dataDir '\tracing2\filterdCubes\'];
parameter.tracings(2).graphFile = ['G:\Benjamin\' dataDir '\tracing2\graph'];

parameter.tracings(3).nml = ['G:\Benjamin\' dataDir '\tracing3\densetracing.nml'];
parameter.tracings(3).bbox = [6800 7100;2140 2340;1236 1536]-1; % offset in cubes!
parameter.tracings(3).cubeFile = ['G:\Benjamin\' dataDir '\tracing3\cubesAll'];
parameter.tracings(3).segmentFile = ['G:\Benjamin\' dataDir '\tracing3\segments'];
parameter.tracings(3).filterdCubesDir = ['G:\Benjamin\' dataDir '\tracing3\filterdCubes\'];
parameter.tracings(3).graphFile = ['G:\Benjamin\' dataDir '\tracing3\graph'];

end


