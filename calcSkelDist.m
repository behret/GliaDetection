function [ output_args ] = calcSkelDist(PixelList)
%CALCSKELDIST Summary of this function goes here
%   Detailed explanation goes here
    
    cube = visualizeSegment(PixelList);
    skel =  skeleton3D(cube);

end

