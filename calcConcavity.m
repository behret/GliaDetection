function featureVal = calcConcavity(PixelList,number)
    for i = 1:3

        sliceVals = unique(PixelList(:,i));
        sums = [];
        for j = 1:length(sliceVals)
            sums(j) = sum(PixelList(:,i) == sliceVals(j));
        end
        [sorted,idx] = sort(sums,'descend');    
        
        for j=1:number

            val = sliceVals(idx(j));
            coordsIn2D = PixelList(find(PixelList(:,i) == val),sort([mod(i+1,3)+1 mod(i,3)+1]));
            [K,v] = convhull(coordsIn2D(:,1),coordsIn2D(:,2));
            %calc area of convhull
            wholeArea = [sort(repmat([min(coordsIn2D(:,1)):max(coordsIn2D(:,1))]',length(min(coordsIn2D(:,2)):max(coordsIn2D(:,2))),1)) ...
                repmat([min(coordsIn2D(:,2)):max(coordsIn2D(:,2))]',length(min(coordsIn2D(:,1)):max(coordsIn2D(:,1))),1)];
            in = inpolygon(wholeArea(:,1),wholeArea(:,2),coordsIn2D(K,1),coordsIn2D(K,2));
            areaConvhull = sum(in == 1);           
%             figure
%             plot(coordsIn2D(K,1),coordsIn2D(K,2),'r-',coordsIn2D(:,1),coordsIn2D(:,2),'b+')            
            ratios((i-1)*number+j) = length(coordsIn2D)/areaConvhull;
        end

    end
    featureVal = sum(ratios)/length(ratios);
end



% concavity makes no sense for projection...        
%             projOnPlane = projPointOnPlane(PixelList,[zeros(1,3) COEFF(:,1)' COEFF(:,2)']);
%             coordsIn2D = projOnPlane*COEFF(:,1:2);
%             coordsIn2D = unique(round(coordsIn2D),'rows'); 