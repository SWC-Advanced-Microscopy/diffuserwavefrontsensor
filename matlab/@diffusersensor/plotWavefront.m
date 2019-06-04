function plotWavefront(obj)
    % Plot the wavefront

    if isempty(obj.phaseImage)
        return
    end

    vidRunning = obj.cam.isrunning;
    if vidRunning
        obj.stopVideo
    end


    tFig=dws.focusNamedFig('resultsFigName');
    plotGradients=true;


    % Optionally plot the gradient images
    if plotGradients
        subplot(2,2,1,'parent',tFig)
        imagesc(obj.gradients(:,:,1))
        title('GradientX') 
        axis equal tight

        subplot(2,2,2,'parent',tFig)
        imagesc(obj.gradients(:,:,2))
        title('GradientY')
        axis equal tight
    end


    % Plot the phase image
    if plotGradients
        subplot(2,2,3,'parent',tFig)
    else
        subplot(2,1,1,'parent',tFig)
    end
    imagesc(obj.phaseImage)

    title('phase (rad)') 
    colorbar
    axis equal tight


    % Plot the zernike coefs
    if plotGradients
        subplot(2,2,4,'parent',tFig)
    else
        subplot(2,1,2,'parent',tFig)
    end
    if ~isempty(obj.zernNames)
        n=length(obj.zernNames);
        barh(obj.zernCoefs)
        set(gca,'YTick',1:n,'YTickLabel',obj.zernNames)
        ylim([1.5,n+0.5])
        grid on
    end


    if vidRunning
        obj.startVideo
    end

end