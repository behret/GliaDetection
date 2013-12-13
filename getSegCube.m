function [ cube ] = getSegCube( PLstruct,sizeCube)
%GETSEGCUBE Summary of this function goes here
%   Detailed explanation goes here


% does not work if size bbox traced != seg / cube
cube = false(sizeCube);

for i=1:length(PLstruct)    
    cube(sub2ind(sizeCube,PLstruct(i).PixelList(:,1),PLstruct(i).PixelList(:,2),PLstruct(i).PixelList(:,3))) = 1;
end

%%%
% for k = 1 : size(ids_glia,2)
%     cube(cube == ids_glia(k)) = 10000;
% end
% cube(cube ~= 10000) = 0;
% cube(cube == 10000) = 1; 