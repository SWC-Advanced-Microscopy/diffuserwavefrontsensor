function calcZernike(obj)

    obj.phaseImage=obj.phaseImage-mean(obj.phaseImage(:)); %Get rid of most of the piston
    n=12; % how many coefs to return    
    [obj.zernCoefs,obj.zernNames]=zernike_coeffs(imresize(obj.phaseImage,[512,512]),n,true);
    obj.zernCoefs(1)=0; %Force to zero since we can't measure it

end