slice = 90;

figure 
hold on
    subaxis(2,2,1, 'Spacing', 0, 'Padding', 0, 'Margin', 0);
imshow(uint8(raw(:,:,slice)));
axis tight
axis off
%saveFig('segErrorRaw')
freezeColors



    subaxis(2,2,3, 'Spacing', 0, 'Padding', 0, 'Margin', 0);
imshow(seg(:,:,slice));
axis tight
axis off
vals = unique(seg);
colormap(hsv(length(vals)));
cmap = colormap;
cmap = cmap(randsample(1:length(cmap),length(cmap)),:);
cmap(1,:) = [0 0 0];
colormap(cmap);
%saveFig('segErrorSeg')
freezeColors

    
    subaxis(2,2,2, 'Spacing', 0, 'Padding', 0, 'Margin', 0);
imshow(classification(:,:,slice));
axis tight
axis off
%saveFig('segErrorClass')

    
    subaxis(2,2,4, 'Spacing', 0, 'Padding', 0, 'Margin', 0);
imshow(cubeGlia(:,:,slice));
axis tight
axis off
%saveFig('segErrorGlia')
