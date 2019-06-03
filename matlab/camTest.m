function vid=camTest

    % Connect to a camera
    vid = videoinput('gentl', 1, 'Mono8');
    src = getselectedsource(vid);

    vid.FramesPerTrigger = Inf;
    vid.FramesAcquiredFcn = @frameAcq;
    vid.FramesAcquiredFcnCount=1;
    src.AcquisitionFrameRateEnable = 'True';
    src.AcquisitionFrameRate = 40;



    figTagName='wavSenseGUI';
    f=findobj('tag',figTagName);
    if isempty(f)
        fig=figure;
        fig.Tag=figTagName;
    else
        fig=f;
    end

    fig.CloseRequestFcn = @figClose; 


    clf(fig)
    ax=axes(fig);
    rPos = vid.ROIPosition;
    hImage = image(zeros(rPos(4),rPos(3),3),'Parent',ax);
   %preview(vid,hImage)
    axis equal

    triggerconfig(vid,'manual')
    vid.FramesPerTrigger=1;
    vid.TriggerRepeat=inf;

    start(vid)

    
    colormap gray
    trigger(vid)





    %-----------------------------------------------
    function figClose(figHandle,closeEvent)
        %Runs when the window close button is pressed
        delete(figHandle)
        stop(vid)
        delete(vid)
    end

    function frameAcq(tVid,src)
        g=getdata(tVid);
        imagesc(g)
        title(sprintf('%d frames acquired',tVid.FramesAcquired))
    end
end

