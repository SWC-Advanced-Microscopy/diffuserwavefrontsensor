function varargout=measure_wavefront(refImage,testImage,varargin)
% function varargout=measure_wavefront(refImage,testImage,varargin)
%
% Implements a wavefront sensor based on a thin diffuser after Berto, et al. 2017
% Compares an image to a reference and plots the phase shift across the pupil.
% Also fits Zernike coefs to the phase plot and reports the strength of
% each coefficient. 
%
% Inputs
% If run with no input arguments an example showing the effect of defocus is displayed.
% Otherwise the user must supply at least two inputs that are images of the same size. 
% >> measure_wavefront(referenceImage, testImage)
%
% Further optional input arguments supplied as parameter/value pairs
% 'resizeBy' - 1 by default, meaning no downsampling. If less the 1 the images are 
%              downsampled by this factor. 
% pixSize - pixel size in microns. Default is 4.65 um
% lambda - wavelength in nanometers. Default is 550 nm
% camDistance - distance between camera and diffuser in mm. Default is 1 mm
%
% Outputs
% phase - the phase plot
%
%
% Rob Campbell - SWC 2019


if nargin==0  || (isempty(refImage) && isempty(testImage))
    fprintf('Running demo\n')
    Ref=importdata('../example_images/ref.bmp');
    refImage=Ref.cdata;
    Im=importdata('../example_images/lens.bmp');
    testImage=Im.cdata;
end

if nargin==1
    fprintf('%s requires at least two input arguments\n', mfilename)
    return
end

if ~all(size(refImage) == size(testImage))
    fprintf('Image sizes must match\n')
    return
end


%Make images square
tSize = size(refImage);
if tSize(1) ~= tSize(2)
    inds=1:min(tSize);
    indsRows = inds + round((tSize(1)-min(tSize))/2);
    indsCols = inds + round((tSize(2)-min(tSize))/2);
    refImage = refImage(indsRows,indsCols);
    testImage = testImage(indsRows,indsCols);
end



% Parse optional inputs
P=inputParser;
P.CaseSensitive=false;
P.addParamValue('resizeBy', 1)
P.addParamValue('pixSize',4.65)
P.addParamValue('lambda',550)
P.addParamValue('camDistance',1)
P.parse(varargin{:});

resizeBy=P.Results.resizeBy;

% ----------   optical parameters   ----------
pixSize=P.Results.pixSize * 1E-6; % Convert to meters
lambda=P.Results.lambda * 1E-9; % Convert to meters
camDistance=P.Results.camDistance * 1E-3; % Convert to meters


if resizeBy < 1
    refImage = imresize(refImage,resizeBy);
    testImage = imresize(testImage,resizeBy);
end




[M,N]=size(testImage);

FFT=@(x) fftshift(fft2(fftshift(x)));
IFFT=@(x) ifftshift(ifft2(ifftshift(x)));

%----------  non-rigid image registration  ----------
PL=3;
fprintf('Running demon registration....')
D=imregdemons(testImage,refImage,10*ones(PL,1),'AccumulatedFieldSmoothing',3,'PyramidLevels',PL,'DisplayWaitbar',false);
% D is the displacement field along rows and columns used to align the fixed to the moving image
fprintf('done\n')

%----------   symetrization for gradient integration   ----------
fprintf('Fourier integration...')
D2=zeros(2*M,2*N,2);
D2([1:M],[1:N],:)=D;
D2(M+[1:M],[1:N],:)=flipud(D);
D2([1:M],N+[1:N],:)=fliplr(D);
D2(M+[1:M],N+[1:N],:)=rot90(D,2);


%----------   Fourier integration   ----------
[Kx,Ky]=meshgrid([-N:N-1],[-M:M-1]);
Kx=Kx*pi/N; 
Ky=Ky*pi/M;
S=Kx+1i*Ky;
Ks=zeros(2*M,2*N); Ks(S~=0)=1./S(S~=0);

prov=real( IFFT( -1i*Ks.*FFT(D2(:,:,1)+1i*D2(:,:,2)) ) );
fprintf('done\n')
% ----------   phase scaling factor   ----------
SF=2*pi*pixSize^2/(lambda*camDistance); %scaling factor
phase=SF*prov([1:M],[1:N]);

if nargout>0
    varargout{1}=phase;
end
%%
clf
subplot(2,2,1)
imagesc(D(:,:,1))
title('GradientX') 
axis equal tight

subplot(2,2,2)
imagesc(D(:,:,2))
title('GradientY')
axis equal tight

subplot(2,2,3)
imagesc(phase)
axis off
title('phase (rad)') 
colorbar
axis equal tight


phase=phase-mean(phase(:));
n=12;
[zc,zn]=zernike_coeffs(imresize(phase,[512,512]),n,true);

zc(1)=0; %Force to zero since we can't measure it
subplot(2,2,4)
barh(zc)
set(gca,'YTick',1:n,'YTickLabel',zn)
ylim([1.5,n+0.5])
grid on