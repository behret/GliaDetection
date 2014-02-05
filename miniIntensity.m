function weights = miniIntensity(parameter,segments,tracing)

jm = parcluster;
job = createJob(jm);

inputCell = {parameter, segments, 'aff'};
for j=0:length(parameter.filter)
	inputCell{4} = j;
    inputCell{5} = tracing;
	createTask(job, @featureDesign, 1, inputCell);
end

inputCell{3} = 'raw';
for j=0:length(parameter.filter)
	inputCell{4} = j;
    inputCell{5} = tracing;
	createTask(job, @featureDesign, 1, inputCell);
end

submit(job);

% Postprocessing
wait(job);
data = fetchOutputs(job);
weights = cat(2,data{:});
% Reomve imaginary part of weights (happens for e.g. eigenvalue calculation)
weights = real(weights);
destroy(job);

end

