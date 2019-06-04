function [pixSize, lambda, camDistance, camToStart] = defaultSettings

	% Settings for sensor 
    pixSize = 5;      % Pixel size of camera
    lambda = 635;     % Illumination wavelength in nm
    camDistance = 10; % Distance from camera to diffuser in mm 

    % Camera type
    camToStart = '';   % String of camera name to start. See dws.camera
