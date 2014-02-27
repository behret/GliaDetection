function [ out ] = divideLabelStruct( in, idx )

out.labels = in.labels(idx);
out.ids = in.ids(idx,:);
out.inGraph = in.inGraph(idx);

end

