function [ result ] = selectFeatures( SVMStruct, sigma, C )

C = C(1);

%get bound SVs (sth wrong???)
sv = SVMStruct.SupportVectors;
bsv = sv(abs(SVMStruct.Alpha) == C,:);  


for i=1:length(bsv)
    
    grad = 0;
    
    for vec = 1:length(sv)
        % *sign...???
        grad = grad + SVMStruct.Alpha(vec)*sign(SVMStruct.Alpha(vec)) * ...
            (2*(sv(vec,:) - bsv(i,:))/sigma) * ...
            exp(- pdist([sv(vec,:) ; bsv(i,:)]) / sigma);
    end    

    
    for j = 1:size(sv,2)
        
        e = zeros(1,size(sv,2));
        e(j) = 1;
        
        alpha(i,j) =  min( acos( grad* e'/ norm(grad)) );
        
    end

    
    
end

for i=1:size(alpha,2)
    weights(i) = 1 - (2/pi) * (sum(alpha(:,i))/size(alpha,1));
end


[sor,idx] = sort(weights,'descend');
result = idx(1:80);

