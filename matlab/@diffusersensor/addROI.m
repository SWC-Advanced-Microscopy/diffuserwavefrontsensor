function addROI(obj)
    % Add a square ROI to the image
    %
    % diffusersensor.addROI

    if isempty(obj.testImage)
        return
    end

    if isa(obj.hRect,'imrect') && isvalid(obj.hRect)
        delete(obj.hRect)
    end

    %Display the rectangle
    imSize = size(obj.testImage,1);
    dCrop = round(imSize*0.125);
    obj.hRect = imrect(obj.hImAx,[dCrop dCrop imSize-dCrop*2 imSize-dCrop*2]);

    % Make use the rectangle remains square and it can't leave the axes
    setFixedAspectRatioMode(obj.hRect,true)
    fcn = makeConstrainToRectFcn('imrect',get(obj.hImAx,'XLim'),get(obj.hImAx,'YLim'));
    setPositionConstraintFcn(obj.hRect,fcn); 

end