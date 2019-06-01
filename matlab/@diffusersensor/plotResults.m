function plotResults(obj)
    % Plot the wavefront

    subplot(2,2,1,'parent',obj.hFig)
    imagesc(obj.demons(:,:,1))
    title('GradientX') 
    axis equal tight

    subplot(2,2,2,'parent',obj.hFig))
    imagesc(obj.demons(:,:,2))
    title('GradientY')
    axis equal tight

    subplot(2,2,3,'parent',obj.hFig))
    imagesc(obj.phaseImage)
    axis off
    title('phase (rad)') 
    colorbar
    axis equal tight


    obj.calcZernike
    subplot(2,2,4,'parent',obj.hFig))
    n=length(obj.zernNames);
    barh(obj.zernCoefs)
    set(gca,'YTick',1:n,'YTickLabel',obj.zernNames)
    ylim([1.5,n+0.5])
    grid on

end