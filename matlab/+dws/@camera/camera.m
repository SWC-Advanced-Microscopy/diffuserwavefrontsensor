classdef camera < handle

    properties
        vid   % Holds the camera object
        src   % Holds the camera-specific properties
    end




    methods
        function obj = camera(camToStart)
            if nargin<1 || isempty(camToStart)
                camToStart=[];
            end

            % Find which adapters are installed
            cams=imaqhwinfo;
            if isempty(cams.InstalledAdaptors)
                fprintf('NO CAMERAS FOUND by dws.camera\n');
                delete(obj)
                return
            end

            % Loop through each combination of camera and formats and build commands to start each
            constructorCommands = {};
            for ii=1:length(cams.InstalledAdaptors)
                tDevice = imaqhwinfo(cams.InstalledAdaptors{ii});
                formats = tDevice.DeviceInfo.SupportedFormats;
                con = tDevice.DeviceInfo.VideoInputConstructor;
                for jj=1:length(formats)
                    tCom = tDevice.DeviceInfo.VideoInputConstructor; % command to connect to device
                    tCom = strrep(tCom,')',[', ''',formats{jj},''')'] );
                    constructorCommands = [constructorCommands,tCom];
                end

            end

            if length(constructorCommands)==1
                constructorCommand = constructorCommands{1};
            elseif length(constructorCommands)>1 && isempty(camToStart)
                for ii=1:length(constructorCommands)
                    fprintf('%d  -  %s\n',ii,constructorCommands{ii})
                end
            elseif length(constructorCommands)>1 && length(camToStart)==1
                fprintf('Available interfaces:\n')
                for ii=1:length(constructorCommands)
                    fprintf('%d  -  %s\n',ii,constructorCommands{ii})
                end
                fprintf('\nConnecting to number %d\n', camToStart)
                constructorCommand = constructorCommands{camToStart};
            else
                fprintf('NO CAMERAS FOUND by dws.camera\n');             
            end


            %Runs one of the camera functions in the camera private sub-directory
            obj.vid = eval(constructorCommand);
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

