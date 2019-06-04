function out = returnResults(obj)
    % Return results of the measurements as a structure 


    % Build an output structure
    varsToExport={'refImage', 'testImage', 'phaseImage', ...
                  'zernCoefs', 'zernNames', 'gradients'};

    for ii=1:length(varsToExport);
        out.(varsToExport{ii}) = obj.(varsToExport{ii});
    end

    out.timeAcquired = datestr(obj.lastPhaseImTime,'YYYY-mm-dd HH:MM:SS');

    % Store camera info
    out.cameraName = obj.cam.vid.Name;

end