function [ out ] = divideLabelStruct( in, idx )

out.labels = in.labels(idx);
out.ids = in.ids(idx,:);
if isfield(out,'inGraph')
    out.inGraph = in.inGraph(idx);
end
end

