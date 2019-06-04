function varargout= saveData(obj,fname)
    % Save data as a multipage TIFF with meta-data in the TIFF header
    %
    % Purpose
    % Saves to current directory the results of the last wavefront 
    % measurement as a multi-TIFF. The pages are:
    % 1) Reference Image
    % 2) Test Image
    % 3 & 4) Gradients from demon registration
    % 5) Phase plot
    % 
    % If the gradients and phase plot were downsampled (which is likely) 
    % they will be up-sampled to the same size as the raw images for saving.
    %
    % The description field for each frame contains all mete-data and 
    % also the identity if the image in that frame.
    %
    %
    % Inputs
    % fname - optional file name. Final file name will be of the form:
    %         'dws_DATEANDTIME_fname.tiff' if fname is not supplied
    %         it is just ommited from the above file name string


    if nargin<2
        fname='';
    end

    [data,metadataString] = obj.returnResults;

    fnameHead = ['dws_',out.timeAcquired]; % we will tag the file this way

    if length(fname)==0
        fname = [fnameHead,'.tiff'];
    else
        fname = [fnameHead,'_',fname,'.tiff'];
    end

    s=size(data.testImage);
    options={'compression','packbits'};



    % Write the data
    descriptionStr = sprintf('imageID: reference image\n%s',metadataString);
    imwrite(data.refImage,fname,'tiff','writemode','overwrite','Description',descriptionStr,options{:})  

    descriptionStr = sprintf('imageID: test image\n%s',metadataString);
    imwrite(data.testImage,fname,'tiff','writemode','append','Description',descriptionStr,options{:})  

    descriptionStr = sprintf('imageID: gradient 1\n%s',metadataString);
    imwrite(imresize(data.gradients(:,:,1),s),fname,'tiff','writemode','append','Description',descriptionStr,options{:})  

    descriptionStr = sprintf('imageID: gradient 2\n%s',metadataString);
    imwrite(imresize(data.gradients(:,:,2),s),fname,'tiff','writemode','append','Description',descriptionStr,options{:})  

    descriptionStr = sprintf('imageID: wavefront\n%s',metadataString);
    imwrite(imresize(phaseImage,s),fname,'tiff','writemode','append','Description',descriptionStr,options{:}) 


end