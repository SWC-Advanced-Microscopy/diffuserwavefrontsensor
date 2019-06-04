function calcZernike(obj)
    % Calculate Zernike coefs and store in object

	if isempty(obj.phaseImage)
		return
	end
    obj.phaseImage=obj.phaseImage-mean(obj.phaseImage(:)); %Get rid of most of the piston

    % Resize the phase image for claculation only if it's larger than the target 
    % resized image size.
    if size(obj.phaseImage) > obj.zernImSize
        tmpIm = imresize(obj.phaseImage,[obj.zernImSize, nan]);
    else
        tmpIm = obj.phaseImage;
    end

    [obj.zernCoefs,obj.zernNames]=dws.zernike_coeffs(tmpIm, obj.nZernPoly, obj.printZernCoefs);

    obj.zernCoefs(1)=0; %Force to zero since we can't measure it

end