function [ cube ] = visualizeSegment(PixelList,play,raw)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    

    borders = [max(PixelList(:,1)) - min(PixelList(:,1)) max(PixelList(:,2)) - min(PixelList(:,2)) max(PixelList(:,3)) - min(PixelList(:,3))];
    cube = zeros(borders+[1 1 1]);

    if(nargin == 1)
        PixelList = [PixelList(:,1)-min(PixelList(:,1))+1,PixelList(:,2)-min(PixelList(:,2))+1,PixelList(:,3)-min(PixelList(:,3))+1];
        idxLoc = sub2ind(size(cube),PixelList(:,1),PixelList(:,2),PixelList(:,3));
        cube(idxLoc) = 1; 
    else
        idxGlob = sub2ind(size(raw),PixelList(:,1),PixelList(:,2),PixelList(:,3));
        PixelList = [PixelList(:,1)-min(PixelList(:,1))+1,PixelList(:,2)-min(PixelList(:,2))+1,PixelList(:,3)-min(PixelList(:,3))+1];
        idxLoc = sub2ind(size(cube),PixelList(:,1),PixelList(:,2),PixelList(:,3));
        cube(idxLoc) = raw(idxGlob);
        %meanIntensity = mean(raw(idxGlob));
        %cube(cube == 0) = 255;
        cubeRight = zeros([size(cube,2),size(cube,1),size(cube,3)]);
        for i = 1:(size(cube,3))
            cubeRight(:,:,i) = cube(:,:,i)';
        end
        cube = cubeRight;
        if play
            implay(uint8(cube));
        end
    end
end

