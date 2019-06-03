function out=readSettings
    % outSettings=dws.readSettings
    %
    % Purpose
    % Reads defaults settings for the sensor. Makes settings file if none existsBrings to focus the figure with the tag name 'figTagName'
    % Creates the figure if it does not exist. Default settings are stored in the private code director
    % in +dws and copied to the root directory of the software. 
    % 

    codeDir = fileparts(fileparts( which(['dws.',mfilename]) ));
    fname=fullfile(codeDir,'dws_settings.m');

    if ~exist(fname)
        fprintf('Creating default settings file in %s\n', codeDir)
        defaultSettings = which('defaultSettings.m');
        copyfile(defaultSettings,fname)
    end

    [out.pixSize,out.lambda,out.camDistance,out.camToStart]=dws_settings;


end