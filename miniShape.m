function mat = miniShape(parameter,segments,tracing)

% get PixelList 
siz = (parameter.tracings(tracing).bbox(:,2)-parameter.tracings(tracing).bbox(:,1)+1)';
for i=1:length(segments)
    [x,y,z] = ind2sub(siz,segments(i).PixelIdxList);
    segments(i).PixelList = [x y z];
    segments(i).features = [];
end
segments = rmfield(segments,'PixelIdxList');

jm = parcluster;
job = batch(jm,@calcShape,1,{segments},'MatlabPool',8);
wait(job);
mat = fetchOutputs(job);
mat = cell2mat(mat);
destroy(job);
