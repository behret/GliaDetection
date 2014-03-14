function [ output_args ] = saveFig( name )

if strcmp(name,'ROC_PR_SVM') || strcmp(name,'ROC_PR_RVM')
    set(gcf, 'PaperPosition', [0 0 12 5]); %Position plot at left hand corner with width 5 and height 5.
    set(gcf, 'PaperSize', [12 5]); %Set the paper to have width 5 and height 5
else
    set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height5.
    set(gcf, 'PaperSize', [5 5]); %Set the paper to have width 5 and height 5.

end
saveas(gcf, ['C:\Users\behret\Dropbox\BachelorArbeit\thesis_1\Figures\' name], 'pdf') %Save figure
end

