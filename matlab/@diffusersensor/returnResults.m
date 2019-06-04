function [out,str] = returnResults(obj)
    % Return results of the measurements as a structure 
    %
    % Outputs
    % out - A structure containing the test and reference images
    %       phase plot, etc
    % str - A formated string containing Zernike coefs, acquisition time, etc.
    %       This output is a duplicate of some of the data in out. 


    % Build an output structure
    varsToExport={'pixSize', 'lambda','camDistance', 'refImage', 'testImage', 'phaseImage', ...
                  'zernCoefs', 'zernNames', 'gradients', 'frameDownscaleFactor', ...
                  'gradientImDownscaleFactor', 'zernImSize'};

    for ii=1:length(varsToExport);
        out.(varsToExport{ii}) = obj.(varsToExport{ii});
    end

    % Time stamp the structure
    out.timeAcquired = datestr(obj.lastPhaseImTime,'YYYY-mm-dd_HH-MM-SS');

    % Store camera info
    out.cameraName = obj.cam.vid.Name;

    if nargout>1
        str='';
        str = [str, sprintf('pixSize:%0.2f\n', out.pixSize)];
        str = [str, sprintf('lambda:%0.2f\n', out.lambda)];
        str = [str, sprintf('camDistance:%0.2f\n', out.camDistance)];
        str = [str, sprintf('time_acquired:%s\n', out.timeAcquired)];
        str = [str, sprintf('camera_name:%s\n', out.cameraName)];
        str = [str, sprintf('frameDownscaleFactor:%0.2f\n', out.frameDownscaleFactor)]; 
        str = [str, sprintf('zernImSize:%d\n', out.zernImSize)];
        for ii=1:length(out.zernCoefs)
            str = [str, sprintf('zernCoef %s:%0.3f', out.zernNames{ii}, out.zernCoefs(ii))];
            if ii<length(out.zernCoefs)
                str = [str, sprintf('\n')];
            end
        end
    end

end