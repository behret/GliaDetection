function [] = findGlia(seg,raw,p,glia,nonGlia,skel)
%ISSUES
% calc features for every object directly and drop pixellist => memory,
% parallel!

%%  get segments

if(nargin == 2)
    skelPath = 'R:\Benjamin\GliaDetection\data\dense\dense.nml';
    skel = readNml(skelPath,1);

    %
    % group nodes, delete check in getPixelLists
    %

    tic
    [glia,nonGlia] = getSegments(skel,seg,p);
    toc

    save('R:\Benjamin\GliaDetection\data\dense\inputs_mito','-v7.3');
end

%% calculate features
%load('G:\Benjamin\dense\inputs');

featureFlag = [0 0 0 1];

tic
glia = calcFeatures(glia,featureFlag,raw);
toc
tic
nonGlia = calcFeatures(nonGlia,featureFlag,raw);
toc

%save('G:\Benjamin\dense\features','glia','nonGlia','-v7.3');




%% plot distinction

featureMatGlia = cell2mat({glia.features});
featureMatGlia = reshape(featureMatGlia,length(glia(1).features),length(glia));

featureMatNonGlia = cell2mat({nonGlia.features});
featureMatNonGlia = reshape(featureMatNonGlia,length(nonGlia(1).features),length(nonGlia));

for i=1:size(featureMatGlia,1)   
    fig = getHist(featureMatGlia(i,:)',featureMatNonGlia(i,:)',['feature' num2str(i)]);
    path = ['R:\Benjamin\GliaDetection\data\' strrep(datestr(now),':','')];
    mkdir(['R:\Benjamin\GliaDetection\data\' strrep(datestr(now),':','')]);
    print(fig, '-dpdf', [path '\feature' num2str(i)]);
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









