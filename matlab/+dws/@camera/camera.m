classdef camera < handle

    properties
        vid   % Holds the camera object
        src   % Holds the camera-specific properties
    end




    methods
        function obj = camera(camToStart)
            if nargin<1 || isempty(camToStart)
                camToStart='basler';
            end

            obj.vid = eval(camToStart);
            obj.src = getselectedsource(obj.vid);

            % Set up the camera so that it is manually triggerable an 
            % unlimited number of times. 
            triggerconfig(obj.vid,'manual')
            vid.TriggerRepeat=inf;
            obj.vid.FramesPerTrigger = inf;
            obj.vid.FramesAcquiredFcnCount=5; %Run frame acq fun every frame

        end % close constructor


        function delete(obj)
            delete(obj.vid)
        end % close destructor


    end

end

% Connect to a camera





% Following are temporary functions to set up a known camera
function vid=basler
    vid = videoinput('gentl', 1, 'Mono8');
    src.AcquisitionFrameRateEnable = 'True';
    src.AcquisitionFrameRate = 1;
end


function vid=macbook
    vid = videoinput('macvideo', 1, 'YCbCr422_1280x720');
    vid.FramesPerTrigger = 1;
end