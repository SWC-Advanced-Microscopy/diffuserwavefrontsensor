function calcZernike(obj)
    % Calculate Zernike coefs
    %
    % diffusersensor.calcZernike
    %
    % Purpose
    % Calculate Zernike coefs and store the results in the object's properties


    if isempty(obj.phaseImage)
        return
    end


    % Resize the phase image for claculation only if it's larger than the target 
    % resized image size.
    if size(obj.phaseImage) > obj.zernImSize
        tmpIm = imresize(obj.phaseImage,[obj.zernImSize, nan]);
    else
        tmpIm = obj.phaseImage;
    end


    % Fit the phase image using Zernike polynomials
    [obj.zernCoefs,obj.zernNames]=dws.zernike_coeffs(tmpIm, obj.nZernPoly, obj.printZernCoefs);

    obj.zernCoefs(1)=0; %Force to zero since we can't measure it

end
