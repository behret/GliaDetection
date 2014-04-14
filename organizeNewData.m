for i = parameter.tracingsToUse
     
    load(['R:\denseGraph\kDbBefore20140228T111611-0000' num2str(i)]);
    
    seg = segNew;
    classification = class;
    bboxBig = p.bboxBig;
    bboxSmall = p.bboxSmall;
    
    save(parameter.tracings(i).cubeFile,'seg','raw','classification','bboxBig','bboxSmall','-v7.3');
    save(parameter.tracings(i).graphFile,'pNew','edgesNew','-v7.3');
    clearvars -except parameter
end