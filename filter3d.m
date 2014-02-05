function filter3d(parameter, input, idx,tracing)

%filter3d: gives back the filtered image(s) imfeats of the input image I
%the applied filter is specified by type and the siz parameter (two in the
%case of the structure tensor), the filters are created with fspecial3

%profile on;

type = parameter.filter{idx}{1};
sizs = parameter.filter{idx}{2};
siz2s = parameter.filter{idx}{3};
if strcmp(input,'raw')
    load(parameter.tracings(tracing).cubeFile,'raw');
	I = single(raw);
end
if strcmp(input,'aff')
    load(parameter.tracings(tracing).cubeFile,'classification');
	I = single(classification);
end

if ~isa(I, 'single')  %uniform data type
    I=single(I);
end

imfeats=cell(length(sizs),1);
for u=1:length(sizs)
	siz=sizs(u);	
	switch type
	    case 'intensitygaussiansmoothed'
	        %create gaussian filter
	        h=fspecial3('gaussianFWHMhalfSize',siz);
	        imfeat=imfilter(I,h);
	        
	    case 'gaussiansmoothedgradmagnitude'
	        hx=fspecial3('gaussgradient1',siz,1);
	        hy=fspecial3('gaussgradient1',siz,2);
	        hz=fspecial3('gaussgradient1',siz,3);
	        
	        Ix=imfilter(I,hx);
	        Iy=imfilter(I,hy);
	        Iz=imfilter(I,hz);
	        
	        imfeat=sqrt(Ix.^2+Iy.^2+Iz.^2);
        
	    case 'laplaceofgaussian'
	        h=fspecial3('log',siz); 
        	imfeat=imfilter(I,h);
        
	    case 'differenceofgaussians'
	        h=fspecial3('dog',siz);
	        imfeat=imfilter(I,h);
	        
	    case 'sortedeigenvalueshessian'
	        %start by creating 6 filter for each entry in the Hessian
	        hxx=fspecial3('gaussgradient2',siz,11);
	        hyy=fspecial3('gaussgradient2',siz,22);
	        hzz=fspecial3('gaussgradient2',siz,33);
	        hxy=fspecial3('gaussgradient2',siz,12);
	        hxz=fspecial3('gaussgradient2',siz,13);
	        hyz=fspecial3('gaussgradient2',siz,23);
	        
	        %apply the filter to the image, ignoring boundaries, i.e. intensity outside
	        %the image is set to zero
	        Ixx=imfilter(I,hxx); 
 	        Iyy=imfilter(I,hyy);
 	        Izz=imfilter(I,hzz);
 	        Ixy=imfilter(I,hxy);
 	        Ixz=imfilter(I,hxz);
 	        Iyz=imfilter(I,hyz);
 	       
	        %Calculate eigenvectors and eigenvalues of the Hessian for each point
	        [a,b,c]=size(I);
	        imfeat=cell(3,1);
	        newSize = [1 1 a*b*c];
	        Ieigen= eig3([reshape(Ixx, newSize) reshape(Ixy, newSize) reshape(Ixz, newSize); ...
	            reshape(Ixy, newSize) reshape(Iyy, newSize) reshape(Iyz, newSize); ...
	            reshape(Ixz, newSize) reshape(Iyz, newSize) reshape(Izz, newSize)]);
	        Ieigen = sort(Ieigen,1);
	        imfeat{1}=reshape(Ieigen(1,:), [a b c]);
	        imfeat{2}=reshape(Ieigen(2,:), [a b c]);
      	 	imfeat{3}=reshape(Ieigen(3,:), [a b c]); 
        
        	% normalize gradient
        	maxValue = max(imfeat{3}(:));
        	imfeat{1} = imfeat{1} ./ maxValue;
        	imfeat{2} = imfeat{2} ./ maxValue;
        	imfeat{3} = imfeat{3} ./ maxValue;  
	    case 'sortedeigenvaluesstructure'
        	if isempty(siz2s)
        	    error('The structure tensor needs two size parameters!');
        	else
        	    siz2=siz2s(u);
        	    %calculate gradients with fspecial3 using size siz2
        	    hx=fspecial3('gradient',siz2,1);
        	    hy=fspecial3('gradient',siz2,2);
        	    hz=fspecial3('gradient',siz2,3);

        	    Ix=imfilter(I,hx);
        	    Iy=imfilter(I,hy);
        	    Iz=imfilter(I,hz);
        	    
            	%calculate elements of the structure tensor
            	h=fspecial3('gaussianFWHMhalfSize',siz2); %window function
            	Ixx=imfilter(Ix.^2,h);
            	Ixy=imfilter(Ix.*Iy,h);
            	Ixz=imfilter(Ix.*Iz,h);
            	Iyy=imfilter(Iy.^2,h);
            	Iyz=imfilter(Iy.*Iz,h);
            	Izz=imfilter(Iz.^2,h);

            	%calculate the eigenvalues of the structure tensor
            	[a,b,c]=size(I);
            	imfeat=cell(3,1);
            	newSize = [1 1 a*b*c];
            	Ieigen = eig3([reshape(Ixx, newSize) reshape(Ixy, newSize) reshape(Ixz, newSize); ...
            	    reshape(Ixy, newSize) reshape(Iyy, newSize) reshape(Iyz, newSize); ...
            	    reshape(Ixz, newSize) reshape(Iyz, newSize) reshape(Izz, newSize)]);
            	Ieigen = sort(Ieigen,1);
            	imfeat{1}=reshape(Ieigen(1,:), [a b c]);
            	imfeat{2}=reshape(Ieigen(2,:), [a b c]);
            	imfeat{3}=reshape(Ieigen(3,:), [a b c]);            
           
        	end
        
        	% normalize gradient
        	maxValue = max(imfeat{3}(:));
        	imfeat{1} = imfeat{1} ./ maxValue;
        	imfeat{2} = imfeat{2} ./ maxValue;
        	imfeat{3} = imfeat{3} ./ maxValue;
   	 otherwise 
   	     error('Unknown feature type!');
	end 
imfeats{u}=imfeat;
end

if strcmp(type,'sortedeigenvaluesstructure') || strcmp(type, 'sortedeigenvalueshessian')
	imfeats = cat(1,imfeats{:});
end

save([parameter.tracings(tracing).filterdCubesDir input type '.mat'], 'imfeats', '-v7.3');

% profile off;
% profsave(profile('info'), [parameter.tracings(tracing).filterdCubesDir 'profilesFilter\' input type  '/']);

end

