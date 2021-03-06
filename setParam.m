function parameter = setParam()

% 0 for no inclusion
% 1 for inclusion after first prediction, 
% 2 for direct inclusion
parameter.includeNeighbors = 1;

if parameter.includeNeighbors == 1
    datadir = 'data';
elseif parameter.includeNeighbors == 2
    datadir = 'dataNew';
end

parameter.newDataFlag = 0; % if 1, filters will be calculated again
parameter.tracingsToUse = [1 2 3];  
parameter.featureFile = ['G:\Benjamin\' datadir '\features'];
parameter.scaleValFile = ['G:\Benjamin\' datadir '\scaleVals'];
parameter.paramFile{1} = ['G:\Benjamin\' datadir '\params1'];
parameter.paramFile{2} = ['G:\Benjamin\' datadir '\params2'];
parameter.testResultFile = ['G:\Benjamin\' datadir '\results\result-' strrep(datestr(now),':','')];
parameter.filter = {{'sortedeigenvalueshessian' [3 5] []}...
     {'gaussiansmoothedgradmagnitude' [3 5] []}...
     {'intensitygaussiansmoothed' [3 5] []}...
     {'laplaceofgaussian' [3 5] []}...
     {'differenceofgaussians' [3 5] []}};
 
% still an offset of -1
% bbox3 is still wrong! should go to 2440 in y
bboxes{1} = [4097 4736; 4481 5248; 2250 2450]-1;
bboxes{2} = [1417 1717; 4739 5039; 890 1190]-1;
bboxes{3} = [6800 7100; 2140 2340; 1236 1536]-1;


for i = 1:3

    dir = ['G:\Benjamin\' datadir '\tracing' num2str(i) '\'];

    parameter.tracings(i).nml = [dir 'densetracing.nml'];
    parameter.tracings(i).cubeFile = [dir 'cubesAll'];
    parameter.tracings(i).segmentFile = [dir 'segments'];
    parameter.tracings(i).segmentFileNew = [dir 'segmentsNew'];
    parameter.tracings(i).featureFile = [dir 'features'];
    parameter.tracings(i).featureFileNew = [dir 'featuresNew'];
    parameter.tracings(i).filterdCubesDir = [dir 'filterdCubes\'];
    parameter.tracings(i).graphFile = [dir 'graph'];
    parameter.tracings(i).bbox = bboxes{i}; 

end

end


