function [ result ] = selectFeatures( SVMStruct, sigma, C )

C = unique(C);

%get margin SVs
SVs = SVMStruct.SupportVectors;
if length(C) == 1
    marginSVs = SVs(abs(SVMStruct.Alpha) ~= C,:);
else
    marginSVs = SVs(C(1) ~= abs(SVMStruct.Alpha) & C(2) ~= abs(SVMStruct.Alpha)   ,:);
end


for i=1:length(marginSVs)
    
    grad = 0;
    
    for vec = 1:length(SVs)
        grad = grad + SVMStruct.Alpha(vec)*sign(SVMStruct.Alpha(vec)) * ...
            (2*(SVs(vec,:) - marginSVs(i,:))/sigma) * ...
            exp(- norm(SVs(vec,:) - marginSVs(i,:))^2 / sigma);
    end    

    
    for j = 1:size(SVs,2)
        
        e = zeros(1,size(SVs,2));
        e(j) = 1;
        
        alpha(i,j) =  min( pi-acos( grad* e'/ norm(grad)),acos( grad* e'/ norm(grad)) );
        
    end   
    
end

for i=1:size(alpha,2)
    weights(i) = 1 - (2/pi) * (sum(alpha(:,i))/size(alpha,1));
end


[sor,idx] = sort(weights,'descend');
result = idx(1:80);

