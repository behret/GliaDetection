function parameter = setParam()

dataDir = 'data';
parameter.newDataFlag = 0;
parameter.tracingsToUse = [1 2 3];   
parameter.featureFile = 'G:\Benjamin\data\features';
parameter.numFeatures = 159;
parameter.testResultFile = ['G:\Benjamin\data\results\resultNewCutoff' num2str(parameter.numFeatures)];
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

    dir = ['G:\Benjamin\data\tracing' num2str(i) '\'];

    parameter.tracings(i).nml = [dir 'densetracing.nml'];
    parameter.tracings(i).cubeFile = [dir 'cubesAll'];
    parameter.tracings(i).segmentFile = [dir 'segments'];
    parameter.tracings(i).segmentAllFile = [dir 'segmentsAll'];
    parameter.tracings(i).featuresAllFile = [dir 'featuresAll'];
    parameter.tracings(i).filterdCubesDir = [dir 'filterdCubes\'];
    parameter.tracings(i).graphFile = [dir 'graph'];
    parameter.tracings(i).bbox = bboxes{i}; 

end

end


