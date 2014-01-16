function [parameter, parameterTrain] = setParameterSettings()

% Regions needed for training data
bbox{1} = [4097 4736; 4481 5248; 2250 2450];
bbox{2} = [2001 2300; 2001 2300; 2001 2100];

% Define region to put through pipeline
% start = [4225 4736; 4609 5120; 2177 2432];
startCoord = [577 641 175];
endCoord = [8257 5761 3247];
sizeInnerBBox =  [512 512 256];
tiles = (endCoord - startCoord) ./ sizeInnerBBox;
for i=1:tiles(1)
	for j=1:tiles(2)
		for k=1:tiles(3)
			bbox{2+sub2ind(tiles, i, j, k)} = [startCoord + [i-1 j-1 k-1] .* sizeInnerBBox; startCoord + [i j k] .* sizeInnerBBox]';
		end
	end
end

startTime = datestr(clock, 30);
for i=1:length(bbox)
	parameter(i).start = [startTime '/' num2str(i,'%.5i')];
	%% GLOBAL SETTINGS 
	% Which raw dataset
	parameter(i).raw.root = '/zdata/manuel/data/cortex/2012-09-28_ex145_07x2_corrected/color/1/';
	parameter(i).raw.prefix = '2012-09-28_ex145_07x2_corrected_mag1';
	% Which classifier to use
	parameter(i).cnn.dateStrings = '20130516T204040';
	parameter(i).cnn.iter = 8; 
	parameter(i).cnn.gpu = 3;
	parameter(i).cnn.root = ['/zdata/manuel/results/parameterSearch/' parameter(i).cnn.dateStrings '/iter' num2str(parameter(i).cnn.iter, '%.2i') '/gpu' num2str(parameter(i).cnn.gpu, '%.2i') '/'];
	% Function to use for classification
	parameter(i).class.func = @fwdPass3DonKhierachy;
	% Function to use for segmentation
	parameter(i).seg.func = @seg20130604;
	% Specify arguments for filterbank applied to raw and aff data each
	parameter(i).filter = {{'sortedeigenvalueshessian' [3 5] []}...
		 {'gaussiansmoothedgradmagnitude' [3 5] []}...
		 {'intensitygaussiansmoothed' [3 5] []}...
		 {'sortedeigenvaluesstructure' [3 5] [5 7]}...
		 {'laplaceofgaussian' [3 5] []}...
		 {'differenceofgaussians' [3 5] []}};
	%% KNOWLEDGE DB PARAMETER
	parameter(i).stateFolder = ['/zdata/manuel/activeState/' startTime '/'];
	% Where to put knowledge DB data
	parameter(i).writeLocation = '/nfs/bmo/mberning/knowledgeDB5/';
	% Global 'state' file locations
	parameter(i).kdbCounter = [parameter(i).stateFolder 'kdbCounter.mat'];
	parameter(i).normValues = [parameter(i).stateFolder 'normValues.mat'];
	parameter(i).hyper = [parameter(i).stateFolder 'hyper.mat'];
	parameter(i).gtSkel = [parameter(i).stateFolder 'skelGT/'];
	parameter(i).gtVol = [parameter(i).stateFolder 'volGT/'];
	parameter(i).useSkelGT = true;
	parameter(i).useVolGT = true;
	parameter(i).upperCut = .95;
	parameter(i).lowerCut = .15;
	% Settings for dataset (written to knowledge DB)
	parameter(i).settings.name = '2012-09-28_ex145_07x2';
	parameter(i).settings.scale = [11.24 11.24 28];
	parameter(i).settings.priority = 0;
	% Border around problem to be looked at
	% has to be big enough for rendering length calculation, sqrt(2)*maxLength in xy voxel equiv
	parameter(i).border = [225 225 90];
	% Viewports
	parameter(i).v(1).name = 'tracer';
	parameter(i).v(1).width = 200;
	parameter(i).v(1).height = 200;
	parameter(i).v(1).isRotated = 0;
	parameter(i).v(1).openingAngle = [];
	parameter(i).v(2).name = 'b4b';
	parameter(i).v(2).width = 312;
	parameter(i).v(2).height = 214;
	parameter(i).v(2).isRotated = 1;
	parameter(i).v(2).openingAngle = 20;
	%kdb flags
	parameter(i).restartCounter = 0;
	parameter(i).saveForProblemInspector = 1;
	parameter(i).controlFlag = 0;
	parameter(i).tutorialFlag = 0;
	% LOCAL PARAMETER, for each bounding box
	% Region passed as input argument
	parameter(i).bboxSmall = bbox{i};
	parameter(i).cubesSmall(:,1) = floor((parameter(i).bboxSmall(:,1)-1)/128);
	parameter(i).cubesSmall(:,2) = floor((parameter(i).bboxSmall(:,2)-1)/128);
	parameter(i).border = [-256 256; -256 256; -128 128];
	parameter(i).bboxBig = bbox{i} + parameter(i).border;
	parameter(i).cubesBig(:,1) = floor((parameter(i).bboxBig(:,1)-1)/128);
	parameter(i).cubesBig(:,2) = floor((parameter(i).bboxBig(:,2)-1)/128);
	% Where to save
	parameter(i).folder = ['/zdata/manuel/temp/' parameter(i).start]; 
	parameter(i).class.root = [parameter(i).folder '/class/'];
	parameter(i).class.prefix = parameter(i).raw.prefix;
	parameter(i).seg.root = [parameter(i).folder '/seg/'];
	parameter(i).seg.prefix = parameter(i).raw.prefix;
	parameter(i).feature.root = [parameter(i).folder '/features/'];
	parameter(i).edgeFile = [parameter(i).folder '/edges.mat'];
	parameter(i).borderFile =  [parameter(i).folder '/borders.mat'];
	parameter(i).weightFile = [parameter(i).folder '/weights.mat'];
	% Create needed folders
	mkdir(parameter(i).class.root);
	mkdir(parameter(i).seg.root);
	mkdir(parameter(i).feature.root);
end
mkdir(parameter(end).stateFolder);
mkdir(parameter(end).gtSkel);
mkdir(parameter(end).gtVol);

% Split struct to training and test sets (more like whole dataset fwd & small training bboxes)
parameterTrain = parameter(1:2);
parameter = parameter(3:end);

%% add SETTINGS FOR CREATING INITIAL TRAINING DATA, for active classifier (has to fit bbox above)
parameterTrain(1).trainDataType = 'skel';
parameterTrain(1).trainFile = '/zdata/manuel/sync/fromLap/L4_dense_skeletons.nml';
parameterTrain(2).trainDataType = 'vol';
parameterTrain(2).trainFile = '/zdata/manuel/sync/fromLap/L4_dense_volSeg.mat';

%% SAVE EVERYTHING
pT = parameterTrain;
p = parameter;
save([parameter(end).stateFolder 'parameter.mat'], 'p', 'pT');

end

