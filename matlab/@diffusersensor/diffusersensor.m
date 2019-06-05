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
    %
    %
    % References
    % This project is based on the work of Berto, et al. 2017
    % https://www.osapublishing.org/ol/abstract.cfm?uri=ol-42-24-5117
    %
    %
    % Rob Campbell - SWC 2019



    % The following properties relate to settings the user can modify to alter the behavior of the class
    properties
        cam      % The camera class

        % -----------------
        % NOTE: If you wish to edit these properties you should edit the dws_settings.m file
        %       which is created the first time the software is run.      
        pixSize     % Pixel size of camera
        lambda      % Illumination wavelength in nm
        camDistance % Distance from camera to diffuser in mm 
        % -----------------


        refImage   % An optional previously loaded reference image 
        testImage  % Last acquired frame

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

        % The following are tag names for reusing figure windows
        figTagName = 'wavSenseGUI'
        resultsFigName = 'phaseResults'

        % The following two properties are used by the method diffusersebsir.dispImage 
        % for the purpose of returning square images
        rowsToKeep
        colsToKeep

        % Properties that contain results. These may be returned using the method
        % diffusersensor.returnResults and saved with diffusersensor.saveData
        phaseImage % The wavefront image will be stored here
        zernNames  % Names of the Zernike coefs
        zernCoefs  % Zernike coefs
        gradients  % The first output of the demon registration: the deformations in x and y

        lastPhaseImTime % The time at which the phase image was last calculated
    end



    % Constructor and destructor
    methods

        function obj = diffusersensor(camToStart)
            % diffusersensor constructor
            %
            % obj = diffusersensor(camToStart)
            %
            % Inputs
            % camToStart - Optional input argument defining which camera is to be connected to on startup
            %


            % Load camera/sensor settings from file
            out = dws.readSettings;
            obj.pixSize = out.pixSize;
            obj.lambda = out.lambda;
            obj.camDistance = out.camDistance;

            if nargin<1
                camToStart = out.camToStart;
            end

            % Connect to the camera and bail out if this fails
            try
                obj.cam = dws.camera(camToStart);

                % Build figure window: make a new one or clear an existing one and re-use it.
                obj.hFig = dws.focusNamedFig(obj.figTagName);
                obj.hFig.CloseRequestFcn = @obj.closeFig;
                clf(obj.hFig)
                obj.hImAx=axes(obj.hFig);
                rPos = obj.cam.vid.ROIPosition;

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

                % Populate the figure window for displaying preview images
                obj.hImLive = image(zeros(m,m,3),'Parent',obj.hImAx);
                obj.hTitle = title('');
                axis equal tight

                obj.cam.vid.FramesAcquiredFcn = @obj.dispImage;
                obj.cam.startVideo
            catch ME
                delete(obj)
                rethrow(ME)
            end
        end % Close constructor


        function delete(obj)
            % Destructor
            delete(obj.cam)
            delete(obj.hFig)
        end % Close destructor

    end % Close block containing constructor and destructor



    % Short methods
    methods

        function getPhase(obj)
            % Find the wavefront shape and graph it
            obj.calcPhase
            obj.plotWavefront
        end % Close getPhase

        function setReference(obj)
            % Assign the last acquired image as the reference image
            obj.refImage = obj.testImage;
        end % Close setReference

        function clearReference(obj)
            % Wipe the reference image
            obj.refImage=[];
        end % Close clearReference

        function updateLiveImage(obj)
            % If a reference image does not exist, plot last acquired frame in
            % grayscale. If a reference image does exist, overlay it on top of
            % the last acquired image in red/green
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
        end % Close updateLiveImage

    end % Close block containing short methods



    % Callback functions
    methods

        function closeFig(obj,~,~)
            obj.delete
        end

        function dispImage(obj,~,~)
            % This callback is run every time a given number of frames have been 
            % acquired by the video device
            if obj.cam.vid.FramesAvailable==0
                return
            end

            tmp=obj.cam.getLastFrame;
            obj.testImage = tmp(obj.rowsToKeep,obj.colsToKeep);

            obj.cam.flushdata
            obj.updateLiveImage
        end % dispImage

    end % Close block containing callbacks


end % close diffusersensor

