for i = parameter.tracingsToUse
     
    load(['kDbBefore20140228T111611-0000' num2str(i)]);
    
    if i == 1
        seg = segNew(257:257+639,257:257+767,129:129+200);
        raw = raw(257:257+639,257:257+767,129:129+200);
        classification = class(257:257+639,257:257+767,129:129+200);
    elseif i == 2
        seg = segNew(257:257+300,257:257+300,129:129+300);
        raw = raw(257:257+300,257:257+300,129:129+300);
        classification = class(257:257+300,257:257+300,129:129+300);
    else
        seg = segNew(257:257+300,257:257+200,129:129+300);
        raw = raw(257:257+300,257:257+200,129:129+300);
        classification = class(257:257+300,257:257+200,129:129+300);         
    end
    
    save(parameter.tracings(i).cubeFile,'seg','raw','classification','-v7.3');
    save(parameter.tracings(i).graphFile,'pNew','edgesNew','-v7.3');
    clearvars -except parameter
end