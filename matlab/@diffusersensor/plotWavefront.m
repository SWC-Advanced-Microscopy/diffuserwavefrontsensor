function plotWavefront(obj)
    % Plot the wavefront

    if isempty(obj.phaseImage)
        return
    end
    vidRunning=isrunning(obj.cam.vid);
    if vidRunning
        obj.stopVideo
    end


    tFig=dws.focusNamedFig('resultsFigName');
    plotGradients=true;

    if plotGradients
        subplot(2,2,1,'parent',tFig)
        imagesc(obj.demons(:,:,1))
        title('GradientX') 
        axis equal tight

        subplot(2,2,2,'parent',tFig)
        imagesc(obj.demons(:,:,2))
        title('GradientY')
        axis equal tight
    end

    if plotGradients
        subplot(2,2,3,'parent',tFig)
    else
        subplot(2,1,1,'parent',tFig)
    end
    imagesc(obj.phaseImage)

    title('phase (rad)') 
    colorbar
    axis equal tight


    % Fit Zernikes
    obj.calcZernike


    if plotGradients
        subplot(2,2,4,'parent',tFig)
    else
        subplot(2,1,2,'parent',tFig)
    end
    n=length(obj.zernNames);
    barh(obj.zernCoefs)
    set(gca,'YTick',1:n,'YTickLabel',obj.zernNames)
    ylim([1.5,n+0.5])
    grid on


    if vidRunning
        obj.startVideo
    end

end