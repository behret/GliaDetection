function featureVal = calcConcavity(PixelList,number)

    for i = 1:3

        sliceVals = unique(PixelList(:,i));
        sums = [];
        for j = 1:length(sliceVals)
            sums(j) = sum(PixelList(:,i) == sliceVals(j));
        end
        [sorted,idx] = sort(sums,'descend');    
        number = min(number,length(sliceVals));
        for j=1:number

            val = sliceVals(idx(j));
            coordsIn2D = PixelList(find(PixelList(:,i) == val),sort([mod(i+1,3)+1 mod(i,3)+1]));
            %make sure theres only one cc 
            coordsIn2D = [coordsIn2D(:,1) - (min(coordsIn2D(:,1))-1)  coordsIn2D(:,2) - (min(coordsIn2D(:,2))-1)];
            BW = false(max(coordsIn2D(:,1)),max(coordsIn2D(:,2)));
            BW(sub2ind(size(BW),coordsIn2D(:,1),coordsIn2D(:,2))) = 1;
            cc = bwconncomp(BW);
            if length(cc.PixelIdxList) > 1               
                 %find biggest component
                 compSize = 0;
                 compIdx = 0;
                 for comp = 1: length(cc.PixelIdxList)
                     if length(cc.PixelIdxList{comp}) > compSize
                         compSize = length(cc.PixelIdxList{comp});
                         compIdx = comp;
                     end
                 end      
                 [x,y] = ind2sub(size(BW),cc.PixelIdxList{compIdx});
                 coordsIn2D = [x y];
            end
            
            if length(coordsIn2D) < 20 
                continue;
            end
            try
                [K,v] = convhull(coordsIn2D(:,1),coordsIn2D(:,2));
            catch
                continue;
            end
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
    
    if exist('ratios')
        featureVal = sum(ratios)/sum(ratios ~= 0);
    else
        featureVal = 0.92; %mean of value
    end


end

