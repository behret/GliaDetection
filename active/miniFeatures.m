function weights = miniFeatures(parameter)

% load segments with pixellists
segments = load(parameter.segmentFile);

%%%generate segments
segments = tracings(2).segments;
for segm=1:length(segments)
    segments(segm).PixelIdxList = sub2ind(size(tracings(2).raw),segments(segm).PixelList(:,1),segments(segm).PixelList(:,2),segments(segm).PixelList(:,3));    
end
%%%

jm = parcluster;
job = createJob(jm);

inputCell = {parameter, segments, 'aff'};
for j=0:length(parameter.filter)
	inputCell{4} = j;
	createTask(job, @featureDesign, 1, inputCell);
end

inputCell{3} = 'raw';
for j=0:length(parameter.filter)
	inputCell{4} = j;
	createTask(job, @featureDesign, 1, inputCell);
end

% Start Job
submit(job);

% Postprocessing
wait(job);
data = fetchOutputs(job);
weightsToAdd = cat(2,data{:});
load(parameter.weightFile);
weights = cat(2, weights, weightsToAdd);
% Reomve imaginary part of weights (happens for e.g. eigenvalue calculation)
weights = real(weights);
% add constant weight
destroy(job);

end
