function [] = findGlia(seg,p,glia,nonGlia,skel)
%ISSUES
% calc features for every object directly and drop pixellist => memory,
% parallel!

%%  get segments

% skelPath = 'R:\Benjamin\GliaDetection\data\dense\dense.nml';
% skel = readNml(skelPath,1);
% 
% %
% % group nodes, delete check in getPixelLists
% %
% 
% tic
% [glia,nonGlia] = getSegments(skel,seg,p);
% toc

%save('R:\Benjamin\GliaDetection\data\dense\inputs_mito','-v7.3');



%% calculate features
%load('G:\Benjamin\dense\inputs');

tic
glia = calcFeatures(glia);%,raw,mito);
toc
tic
nonGlia = calcFeatures(nonGlia);%,raw,mito);
toc

%save('G:\Benjamin\dense\features','glia','nonGlia','-v7.3');




%% plot distinction

featureMatGlia = cell2mat({glia.features});
featureMatGlia = reshape(featureMatGlia,length(glia(1).features),length(glia));

featureMatNonGlia = cell2mat({nonGlia.features});
featureMatNonGlia = reshape(featureMatNonGlia,length(nonGlia(1).features),length(nonGlia));

for i=1:size(featureMatGlia,1)   
    fig = getHist(featureMatGlia(i,:)',featureMatNonGlia(i,:)',['feature' num2str(i)]);
    print( fig, '-dpdf', ['R:\Benjamin\GliaDetection\histos\feature' num2str(i)] );
end





% plot intensities
% 
% PixelList = cell(1);
% PixelList{1} = cell2mat({glia.PixelList}');
% PixelList{2} = cell2mat({nGlia.PixelList}');
% intensities = cell(1);
% intensities{1} = raw(sub2ind(size(raw),PixelList{1}(:,1),PixelList{1}(:,2),PixelList{1}(:,3)));
% intensities{2} = raw(sub2ind(size(raw),PixelList{2}(:,1),PixelList{2}(:,2),PixelList{2}(:,3)));
% figure
% cdfplot(intensities{1})
% hold on
% cdfplot(intensities{2})
% 
% figure
% hist(intensities{1},50);
% figure 
% hist(intensities{2},50);



end









