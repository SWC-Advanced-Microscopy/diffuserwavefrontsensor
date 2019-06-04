function [out,str] = returnResults(obj)
    % Return results of the measurements as a structure 
    %
    % Outputs
    % out - A structure containing the test and reference images
    %       phase plot, etc
    % str - A formated string containing Zernike coefs, acquisition time, etc.
    %       This output is a duplicate of some of the data in out. 


    % Build an output structure
    varsToExport={'refImage', 'testImage', 'phaseImage', ...
                  'zernCoefs', 'zernNames', 'gradients'};

    for ii=1:length(varsToExport);
        out.(varsToExport{ii}) = obj.(varsToExport{ii});
    end

    % Time stamp the structure
    out.timeAcquired = datestr(obj.lastPhaseImTime,'YYYY-mm-dd HH-MM-SS');

    % Store camera info
    out.cameraName = obj.cam.vid.Name;


    if nargout>1
        str='';
        str = [str, sprintf('time_acquired: %s\n', out.timeAcquired)];
        str = [str, sprintf('camera_name: %s\n', out.cameraName)];

        for ii=1:length(out.zernNames)
            str = [str, sprintf('%s: %0.4f\n', out.zernNames{ii}, out.zernCoefs(ii))];
        end
    end

end