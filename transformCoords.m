function [ coords ] = transformCoords( point,p,local )
%TRANSFORMCOORDS Summary of this function goes here
%   Detailed explanation goes here

    if local
        coords = point + p.bboxBig(:,1)' - [2 2 2];
    end
    if ~local
        coords = point - p.bboxBig(:,1)' + [2 2 2];
    end
end

