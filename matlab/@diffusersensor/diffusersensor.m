classdef diffusersensor < handle
    % diffusersensor
    %
    % Implements a basic wavefront sensor diffuser
    %
    % e.g.
    % d=diffusersensor
    % % Get a reference fov then:
    % d.setReference % Overlays the reference image in red/green
    % d.getPhase % calculates the wavefront shape
    %
    % % Now stop and start the video
    % d.stopVideo 
    % d.startVideo
    %
    % % Do a translation correction of the last acquired image to the 
    % % the reference before calculating the wavefront
    % d.transCor = true;
    % d.getPhase
    %
    % d.transCor = false; % return to default value
    %
    % % Speed up the calculation
    % d.resizeBy = 0.5;
    % d.getPhase
    %
    % % Calculate the phase shifts only by don't plot
    % d.calcPhase
    %
    % % Close the phase display window and re-make it without re-calculating
    % d.plotWavefront


    properties
        cam      % The camera class
    end

    % The following properties relate to settings the user can modify to alter the behavior of the class
    properties (SetObservable)
        % NOTE: If you wish to edit these properties you should edit the dws_settings.m file
        %       which is created the first time the software is run.      
        pixSize     % Pixel size of camera
        lambda      % Illumination wavelength in nm
        camDistance % Distance from camera to diffuser in mm 

        gradientImDownscaleFactor = 0.5 % Downscale the gradients by this factor (on top of raw image resize)

        frameDownscaleFactor = 1  % Scaling factor for images before they are processed. 
                                  % This will speed up processing at the cost of larger pixel size
        transCor=false %If true, perform a translation correction of last image to reference
                      %before calculating the wavefront 

        doFitZernike = true % If true we fit Zernike polynomials to the phase plot
        nZernPoly = 13   % Number of Zernike polynomials to return
        zernImSize = 512 %Use a square phase image of this size to calculate the zernike coefs. 
                         %zernImSize can be quite small compared to the original image as the 
                         %phase plot should be smooth
        printZernCoefs = false % If true the zernike coefs are printed to screen when calculated
    end

    properties (Hidden)
        hFig     % The handle of the figure window containing the camera stream
        hImAx    % The handle of the image axes
        hImLive  % The handle of the streaming camera image in the image axes
        hTitle   % Title of live image

        figTagName = 'wavSenseGUI'
        resultsFigName = 'phaseResults'

        % The following two properties are used by dispImage for returning square images
        rowsToKeep
        colsToKeep

        % Properties that conntain results
        refImage   % An optional previously loaded reference image 
        testImage  % Last acquired frame
        phaseImage % The wavefront image will be stored here
        zernNames  % Names of the Zernike coefs
        zernCoefs  % Zernike coefs
        gradients  % The first output of the demon registration: the deformations in x and y

        lastPhaseImTime % The time at which the phase image was last calculated
    end


    methods
        function obj = diffusersensor(camToStart)

            % Load camera/sensor settings from file
            out = dws.readSettings;
            obj.pixSize = out.pixSize;
            obj.lambda = out.lambda;
            obj.camDistance = out.camDistance;

            if nargin<1
                camToStart = out.camToStart;
            end

            % Connect to the camera
            try
                obj.cam = dws.camera(camToStart);

                % Build figure window: make a new one or clear an existing one and re-use it.
                obj.hFig = dws.focusNamedFig(obj.figTagName);
                obj.hFig.CloseRequestFcn = @obj.closeFig;
                clf(obj.hFig)
                obj.hImAx=axes(obj.hFig);
                rPos = obj.cam.vid.ROIPosition;
            catch ME
                delete(obj)
                rethrow(ME)
            end

            % We will want to acquire square images only otherwise zernike coefs can't be calculated
            m=min(rPos(3:4));
            if rPos(3)==m
                obj.colsToKeep=1:rPos(3);
            else
                d=round((rPos(3)-m)/2);
                obj.colsToKeep=(1:m)+d;
            end
            if rPos(4)==m
                obj.rowsToKeep=1:rPos(4);
            else
                d=round((rPos(4)-m)/2);
                obj.rowsToKeep=(1:m)+d;
            end




            obj.hImLive = image(zeros(m,m,3),'Parent',obj.hImAx);
            obj.hTitle = title('');
            axis equal tight

            obj.cam.vid.FramesAcquiredFcn = @obj.dispImage;
            obj.startVideo
        end


        function delete(obj)
            delete(obj.cam)
            delete(obj.hFig)
        end


        function getPhase(obj)
            % Find the wavefront shape and graph it
            obj.calcPhase
            obj.plotWavefront
        end


        function startVideo(obj)
            obj.cam.startVideo
        end


        function stopVideo(obj)
            obj.cam.stopVideo
        end


        function setReference(obj)
            obj.refImage = obj.testImage;
        end


        function clearReference(obj)
            obj.refImage=[];
        end


        function closeFig(obj,~,~)
            obj.delete
        end



        function dispImage(obj,~,~)
            if obj.cam.vid.FramesAvailable==0
                return
            end

            tmp=squeeze(peekdata(obj.cam.vid,1));
            obj.testImage = tmp(obj.rowsToKeep,obj.colsToKeep);

            flushdata(obj.cam.vid)
            obj.updateLiveImage
        end


        function updateLiveImage(obj)
            if isempty(obj.refImage)
                obj.hImLive.CData = repmat(obj.testImage,[1,1,3]);
            else
                tmpIm=repmat(obj.testImage,[1,1,3]);;
                tmpIm(:,:,1)=obj.refImage;
                tmpIm(:,:,3)=0;
                obj.hImLive.CData = tmpIm;
            end
            obj.hTitle.String = sprintf('%d frames acquired',obj.cam.framesAcquired);
            drawnow
        end


    end % Close methods

end % close diffusersensor