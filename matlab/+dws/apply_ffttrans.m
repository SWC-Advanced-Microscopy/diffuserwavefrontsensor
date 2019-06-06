function varargout=apply_ffttrans(movingIm,target,params)
% function [registered,out]=apply_ffttrans(movingIm,target,params)
%
% Purpose
% Apply fft-based translation correction of one image to another.
%
% Inputs
% movingStack - A single image which will be aligned with target. 
%
% target - The image used as the reference to which to align
%          movingImage.
%
% params - structure containing parameter values (structure
%          fields) and parameter values (structure field values)
%          for the image registation routines. If not specified,
%          defaults are used. See comments in main code (sorry).
%
% Rob Campbell - August 2019
%
% For details on the algorithm:
% http://www.mathworks.com/matlabcentral/fileexchange/18401


% This function is a wrapper which allows us to conduct the fft-based
% translation correction. We will register each frame with the
% baseline image to within 0.1 pixels by specifying an upsampling
% parameter of 10. Setting this to <2 will screw up the align over
% reps. Very little speed gain will be achieved by changing this
% value.

%----------------------------------------------------------------------
% Handle default options and parameters
p.usfac=2; %upsampling factor higher values can produce finer
           %registrations but they also will smear the shot
           %noise. A value of 1 is not sub-pixel and can induce jittering
p.verbose=0;
if nargin>2
    f=fields(params);
    for ii=1:length(f)
        p.(f{ii})=params.(f{ii});
    end
end



%----------------------------------------------------------------------
% Call the registration routine
targetFFT=fft2(target);
movingFFT=fft2(movingIm);

[output,Greg,phase] = dws.dftregistration(targetFFT,movingFFT,p.usfac);
OffsetPixel=output([3,4]);
registered=abs(ifft2(Greg));
   

%----------------------------------------------------------------------
if nargout>0
    varargout{1}=registered;
end
if nargout>1
    varargout{2}=OffsetPixel;
end