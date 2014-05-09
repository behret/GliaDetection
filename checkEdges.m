%segments without edges at the borders of region
%how does this happen..?
%find edges with overlap?

segNewSmall = segNew(257:557,257:457,129:429);
noEdges = setdiff(unique(segNewSmall),unique(edgesNew));

for i = 1:length(noEdges)
    segNewSmall(segNewSmall == noEdges(i)) = 0;
end
KLEE_v4('stack',segNewSmall);