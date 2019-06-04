function out = parseMetaData(metaDataText)
    % Convert the tiff ImageDescription field produced by diffuserwavefrontsensor.saveData to a structure
    %
    % Purpose
    % Parse and import meta-data text from saved sensor data.
    %
    % Inputs
    % metaDataText - text string to parse
    %
    % Outputs
    % out - structure containing the parsed data



    if nargin<1
        fprintf('dws.%s requires a string containing text data to parse\n', mfilename)
        return
    end

    metaDataText = strsplit(metaDataText,'\n'); %Break up into lines

    out.zernNames={};
    out.zernCoefs=[];

    for ii=1:length(metaDataText)
        tData = strsplit(metaDataText{ii},':');
        if length(tData) ~= 2
            fprintf('dws.%s finds unknown meta-data line: %s. SKIPPING\n', ...
                mfilename, metaDataText{ii})
            continue
        end

        if isempty(strfind(tData{1},'zernCoef '))
            %If it's not a zernike coef, we just add to the output structure
            if isempty(str2num(tData{2})) %Then it's a string
                out.(tData{1}) = tData{2};
            else
                out.(tData{1}) = str2num(tData{2});
            end

        else
            % If it's a zernike coef we make cell arrays of zernike names
            % and coef magnitude in the same way as we had in the original
            % diffusersensor object

            zName = strrep(tData{1},'zernCoef ',''); %Remove the leading text;
            out.zernNames = [out.zernNames,zName];
            out.zernCoefs = [out.zernCoefs,str2num(tData{2})];
        end


    end

end