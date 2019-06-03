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

        end % close constructor


        function delete(obj)
            delete(obj.vid)
        end % close destructor

        function im=snapFrame(obj)
            obj.vid.FramesPerTrigger = 1;
            obj.vid.TriggerRepeat=inf;
            start(obj.vid) %Slow so better done elsewhere
            trigger(obj.vid)
            im=getdata(obj.vid);
        end

    end

end

% Connect to a camera





% Following are temporary functions to set up a known camera
function vid=basler
    vid = videoinput('gentl', 1, 'Mono8');
    vid.FramesPerTrigger = 1;

    src.AcquisitionFrameRateEnable = 'True';
    src.AcquisitionFrameRate = 25;
end


function vid=macbook
    vid = videoinput('macvideo', 1, 'YCbCr422_1280x720');
    vid.FramesPerTrigger = 1;
end