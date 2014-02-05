function weights = featureDesign(parameter, segments, input, idx, tracing)

%profile on;

if idx ~= 0 
	type = parameter.filter{idx}{1};
	load([parameter.tracings(tracing).filterdCubesDir input type '.mat']);
else
	if strcmp(input, 'raw')
        load(parameter.tracings(tracing).cubeFile,'raw');
	    imfeats{1} = single(raw);
	end
	if strcmp(input, 'aff')
        load(parameter.tracings(tracing).cubeFile,'classification');
	    imfeats{1} = single(classification);
	end
end

weights = zeros(size(segments,2),5*length(imfeats));
for i=1:size(segments,2)
	for j=1:length(imfeats)
		temp = imfeats{j}(segments(i).PixelIdxList);
		weights(i,(j-1)*5+1) = max(temp);
		weights(i,(j-1)*5+2) = min(temp);
		weights(i,(j-1)*5+3) = mean(temp);
		weights(i,(j-1)*5+4) = median(temp);
		weights(i,(j-1)*5+5) = std(temp);
	end
end

%profile off;
%profsave(profile('info'), [parameter.feature.root 'profiles\' input num2str(idx)]);

end

