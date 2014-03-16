function h = fspecial3(type,siz,dir)
% Created by Manuel Berning to produce 3D filters

%added: 
%dog: difference of gaussians, second gaussian has a width that is 2/3 of
%the first one
%gaussiangradient1/2: filter that applied to an image gives the
%first/second derivative wrt to dir (two direction to be specified for the
%second derivative) of the gaussian-smoothed image

if nargin < 3
    dir = [];
end


switch type
    case 'cubeAverage'
        h = ones(siz,siz,siz)/prod([siz siz siz]);
        
    case 'sphereAverage'
        R = siz/2;
        R(R==0) = 1;
        h = ones(siz,siz,siz);
        siz = (siz-1)/2;
        [x,y,z] = ndgrid(-siz:siz,-siz:siz,-siz:siz);
        I = (x.*x/R^2+y.*y/R^2+z.*z/R^2)>1;
        h(I) = 0;
        h = h/sum(h(:));
        
    case 'gaussianFWHMhalfSize'
        sig = siz/(4*sqrt(2*log(2)));
        siz   = (siz-1)/2;
        [x,y,z] = ndgrid(-siz:siz,-siz:siz,-siz:siz);
        h = exp(-(x.*x/2/sig^2 + y.*y/2/sig^2 + z.*z/2/sig^2));
        h = h/sum(h(:));
        
    case 'laplacian'
        if siz < 3
            error('Discrete Laplacian with size per dimension < 3 not defined');
        else
            siz = siz + [2 2 2];
            h = zeros(siz);
            h([1 end],:,:) = 1;
            h(:,[1 end],:) = 1;
            h(:,:,[1 end]) = 1;
            h = bwdist(h);
            h([1 end],:,:) = [];
            h(:,[1 end],:) = [];
            h(:,:,[1 end]) = [];
            if rem(siz,2) == 0
                mid = (siz-2)/2;
                h(mid:mid+1, mid:mid+1, mid:mid+1) = 0;
                h(mid:mid+1, mid:mid+1, mid:mid+1) = repmat(-sum(h(:)),[2 2 2]);
                h = double(h);
            else
                mid = ceil((siz-2)/2);
                h(mid, mid, mid) = 0;
                h(mid, mid, mid) = sum(-h(:));
                h = double(h);
            end
        end

    case 'log'
        if siz < 3
            error('Laplacian of Gaussian Filter with size per dimension < 3 not defined');
        else
            sig = siz/(4*sqrt(2*log(2)));
            siz   = (siz-1)/2;
            [x,y,z] = ndgrid(-siz:siz,-siz:siz,-siz:siz);
            h = exp(-(x.*x/2/sig^2 + y.*y/2/sig^2 + z.*z/2/sig^2));
            h = h/sum(h(:));
            arg = (x.*x/sig^4 + y.*y/sig^4 + z.*z/sig^4 - ...
                (1/sig^2 + 1/sig^2 + 1/sig^2));
            h = arg.*h;
            h = h/sum(h(:));
        end
        
    case 'dog'
        sig1=siz/(4*sqrt(2*log(2)));
        sig2=sig1*0.66;
        dsig=sig1-sig2;
        
        siz=(siz-1)/2;
        [x,y,z] = ndgrid(-siz:siz,-siz:siz,-siz:siz);
        
        h1 = exp(-(x.*x/2/sig1^2 + y.*y/2/sig1^2 + z.*z/2/sig1^2));
        h1 = h1/sum(h1(:));
        h2 = exp(-(x.*x/2/sig2^2 + y.*y/2/sig2^2 + z.*z/2/sig2^2));
        h2 = h2/sum(h2(:));
        
        h=(sig1-dsig/2)/dsig*(h1-h2);
        
    case 'gradient'    
        if siz < 3
            error('Gradient Filter with size per dimension < 3 not defined');
        elseif isempty(dir)
            error('Specifiy direction for gradient!');
        else
            if rem(siz,2) == 0
                mid = siz/2-0.5;
                a= (-mid:mid)';
            else
                mid = floor(siz/2);
                a = (-mid:mid)';
            end
            b = ones(1,siz,1);
            switch dir
                case 1
                    h = repmat(a * b, [1 1 siz]);   
                case 2
                    h = repmat(reshape(a * b, 1, siz, siz), [siz 1 1]);
                case 3
                    h = repmat(reshape((a * b)', 1, siz, siz), [siz 1 1]);
                otherwise
                    error('Only implemented for 3 axis aligned dimensions.')
            end    
        end       
    case 'gaussgradient1'
        if isempty(dir)
            error('Specify direction for gradient!');
        else 
            sig = siz/(4*sqrt(2*log(2)));
            siz   = (siz-1)/2;
            [x,y,z] = ndgrid(-siz:siz,-siz:siz,-siz:siz);
            h = exp(-(x.*x/2/sig^2 + y.*y/2/sig^2 + z.*z/2/sig^2));
            h = h/sum(h(:));
            switch dir
                case 1
                    h=-x.*h/sig^2;
                case 2
                    h=-y.*h/sig^2;
                case 3
                    h=-z.*h/sig^2;
                otherwise
                    error('Only implemented for 3 axis aligned dimensions.')
            end
        end
        
    case 'gaussgradient2'
        if isempty(dir)
            error('Specify direction of the gradient!');
        else 
            sig = siz/(4*sqrt(2*log(2)));
            siz   = (siz-1)/2;
            [x,y,z] = ndgrid(-siz:siz,-siz:siz,-siz:siz);
            h = exp(-(x.*x/2/sig^2 + y.*y/2/sig^2 + z.*z/2/sig^2));
            h = h/sum(h(:));
            switch dir
                case 11
                   h=h.*(x.^2-sig^2)/sig^4;
                case 22
                    h=h.*(y.^2-sig^2)/sig^4;
                case 33
                    h=h.*(z.^2-sig^2)/sig^4;
                case 12
                    h=h.*(x.*y)/sig^4;
                case 13
                    h=h.*(x.*z)/sig^4;
                case 23
                    h=h.*(y.*z)/sig^4;
                otherwise
                    error('For a second derivative two directions have to be specified.')
            end
        end
        
    otherwise
        error('Unknown filter type.')
        
end

        