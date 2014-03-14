function plotDistinction(parameter)

load(parameter.featureFile);

path = ['G:\Benjamin\combi\histos\' strrep(datestr(now),':','')];
mkdir(path);

for i=1:size(featureMat,2)   
    fig = getHist(featureMat(find(labels),i),featureMat(find(imcomplement(labels)),i),['feature' num2str(i)]);   
    if(i == 1)
        print(fig, '-dpsc2', [path '\distinction']);
    else
        print(fig, '-dpsc2', [path '\distinction'], '-append'); 
    end
end


end

