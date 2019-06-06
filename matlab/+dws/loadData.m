function out = loadData(fname)
    % Load results previously saved by diffusersensor
    %
    % out = dws.loadData(fname)
    %
    % Purpose
    % Loads a TIFF stack containing the data from a previous measurement. 
    % Also imports the meta-data and converts to a structure. 
    %
    %
    % Inputs
    % fname - relative or absolute to a dws tiff stack
    %
    % Outputs
    % out - structure containing the loaded data

    if nargin<1
        fname='';
    end

    % TODO: bring up a loading UI if the user didn't supply a file name

    if ~exist(fname,'file')
        fprintf('File %s is not present. Can not load data\n', fname)
        return
    end

    imageInfo = imfinfo(fname);
    numFrames=length(imageInfo);

    %Extract the meta-data
    out = dws.parseMetaData(imageInfo(1).ImageDescription);

    out = rmfield(out,'imageID');

    out.refImage = imread(fname,1);
    out.testImage = imread(fname,2);


end
