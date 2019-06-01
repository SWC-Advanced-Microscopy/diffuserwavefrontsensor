classdef diffusersensor < handle

    properties
        hFig     % The handle of the figure window
        hImAx    % The handle of the image axes
        hImLive  % The handle of the streaming camera image in the image axes
        cam      % The camera class

    end

    properties (SetObservable)
        resizeBy = 1    % Scaling factor for images before they are processed
        pixSize = 4.65  % Pixel size of camera  <-- TODO: can we extract from camera class?
        lambda = 550    % Illumination wavelength in nm
        camDistance = 1 % Distance from camera to diffuser in mm 

        refImage   % An optional previously loaded reference image 
        phaseImage % The wavefront image will be stored here

        zernNames  % Names of the Zernike coefs
        zernCoefs  % Zernike coefs
    end

    properties (Hidden)
        figTagName = 'wavSenseGUI';
        FFT  % Anonmynous function handle
        IFFT % Anonmynous function handle

        demons % The first output of the demon registration
    end


    methods
        function obj = diffusersensor(camToStart)
            if nargin<1
                camToStart=[];
            end

            % Make anonymous functions
            obj.FFT  = @(x) fftshift(fft2(fftshift(x)));
            obj.IFFT = @(x) ifftshift(ifft2(ifftshift(x)));

            % Connect to the camera
            obj.cam = dws.camera(camToStart);

            % Build figure window: make a new one or clear an existing one and re-use it.
            f=findobj('tag',figTagName);
            if isempty(f)
                obj.hFig=figure;
                obj.hFig.Tag=obj.figTagName;
            else
                obj.hFig=f;
            end

            clf(obj.hFig)
            obj.imAx=axes(obj.hFig);
            rPos = obj.cam.vid.ROIPosition;
            obj.hImLive = image(zeros(rPos(3),rPos(4),3),'Parent',ax)
            axis equal


            preview(obj.cam.vid,obj.hImLive)
        end

        function delete(obj)
        end


    end % Close methods

end % close diffusersensor