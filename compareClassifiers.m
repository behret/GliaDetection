function [ output_args ] = compareClassifiers( input_args )
%COMPARECLASSIFIERS Summary of this function goes here
%   Detailed explanation goes here


load('G:\Benjamin\dataGraph\results\RVM\resultFeatureFilter90.mat','pred');
RVMpred = pred;
load('G:\Benjamin\dataGraph\results\RVM\forComparison.mat');
SVMpred = pred;

concurr = RVMpred(:,1) == 1 & SVMpred(:,1) == 1 & RVMpred(:,3) == 1;
concurr = RVMpred(:,1) == 1 & SVMpred(:,1) == 1 & RVMpred(:,3) == 0;

end

