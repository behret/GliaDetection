function miniEdges(parameter)

jm = parcluster;
job = createJob(jm);

for i=1:length(parameter.filter)
	createTask(job, @filter3d, 0, {parameter 'aff' i});
end
for i=1:length(parameter.filter)
	createTask(job, @filter3d, 0, {parameter 'raw' i});
end

submit(job)
wait(job);
destroy(job);

end

