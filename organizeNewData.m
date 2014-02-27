
for i = parameter.tracingsToUse
    
    
    load(['G:\Benjamin\dataGraph\tracing' num2str(i) '\graphDataAll']);
    
    if i == 1
        seg = segNew(257:257+639,257:257+767,129:129+200);
        raw = raw(257:257+639,257:257+767,129:129+200);
        classification = class(257:257+639,257:257+767,129:129+200);
    else
        seg = segNew(257:257+300,257:257+300,129:129+300);
        raw = raw(257:257+300,257:257+300,129:129+300);
        classification = class(257:257+300,257:257+300,129:129+300);
    end
    
    save(parameter.tracings(i).cubeFile,'seg','raw','classification');
       
    save(parameter.tracings(i).graphFile,'pNew','edgesNew');
    
end