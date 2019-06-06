function varargout = loadData(obj,fname)
    % Load results previously saved by saveData
    %
    % out = diffusersensor.loadData(fname)
    %
    % Purpose
    % Loads a TIFF stack containing the data from a previous measurement. 
    % Also imports the meta-data and converts to a structure. Plots results
    % to screen. Optionally returns results as a structure. 
    %
    % Inputs
    % fname - relative or absolute to a dws tiff stack
    %
    % Outputs
    % out - structure containing the loaded data
    %
    % Also see
    % dws.loadData - loads data independently of the diffusersensor object


    if nargin<2
        fname='';
    end

    % TODO: bring up a loading UI if the user didn't supply a file name

    if ~exist(fname,'file')
        fprintf('File %s is not present. Can not load data\n', fname)
        return
    end

    out = dws.loadData(fname);

    % Import data
    tFields = fields(out);
    for ii=1:length(tFields)
        if ~isprop(obj, tFields{ii})
            continue
        end
        obj.(tFields{ii}) = out.(tFields{ii});
    end

    obj.getPhase;

    if nargout>0
        varargout{1}=out;
    end


end
