function rates = varyFeaturesRVM

parameter = setParam;
featureNums = [158 120 90 60 30];  

for i = 1:length(featureNums)

    parameter.numFeatures = featureNums(i);    
    parameter.testResultFile = ['G:\Benjamin\dataGraph\results\RVM\resultFeatureFilter' num2str(parameter.numFeatures)];

    [rates(i,1:2) pred rates(i,3) SVs]  = RVMcross(parameter,4,8);
end

x =1;

end