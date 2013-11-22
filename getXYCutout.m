function im = getXYCutout(point,volume,type,vid)

range = 100;
if(vid)

    
    vid = volume(point(1)-range:point(1)+range, point(2)-range:point(2)+range, point(3)-range:point(3)+range);
    for i = 1:(size(vid,3))
        vid(:,:,i) = vid(:,:,i)';
    end
        
    if(strcmp(type,'raw'))    
        im = implay(uint8(vid));
    end
    if(strcmp(type,'seg'))    
        im = implay(vid);
        set(findall(0,'tag','spcui_scope_framework'),'position',[150 150 700 550]);
    end
    if(strcmp(type,'mito'))    
        im = implay(single(vid));
    end
else

pic = volume(point(1)-range:point(1)+range, point(2)-range:point(2)+range, point(3));
pic = pic';
im = imagesc(pic);
    if(strcmp(type,'raw'))
        colormap(gray);
    end
% saveas(im,'R:\Benjamin\GliaDetection\mitoPic.pdf');

end