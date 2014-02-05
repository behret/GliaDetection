function miniFilter(parameter,tracing)

jm = parcluster;
job = createJob(jm);

for i=1:length(parameter.filter)
	createTask(job, @filter3d, 0, {parameter 'aff' i tracing});
end
for i=1:length(parameter.filter)
	createTask(job, @filter3d, 0, {parameter 'raw' i tracing});
end

submit(job)
wait(job);
destroy(job);

end

