point = [4604, 4864, 2506]; % ves
point = [4417, 4600, 2309]; % no ves
point = [4562, 4993, 2312]; % mito
point = [1477, 4760, 911]; % leaf like
transformCoords(point, p.bboxBig,0)
%num = find(cell2mat({glia.id}) == seg(306  , 287  , 242));
num = find(cell2mat({glia.id}) == seg(62,23,23));
myseg = visualizeSegment(glia(num).PixelList,1,raw);

eroded = imerode(logical(myseg),ones(5,5,5));

implay(bw);


myseg(myseg == 0) = 255;
myseg(myseg < 120) = NaN;
myseg(~isnan(myseg)) = 1;
myseg(isnan(myseg)) = 0;

mysegEroded = myseg;
mysegEroded(~eroded) = 1;

closed = imclose(myseg,(ones(2,2,2)));
bwconncomp(imcomplement(closed));
implay(closed)

for i=1:length(nonGlia)
    calcIntensities(nonGlia(i).PixelList,raw);
end