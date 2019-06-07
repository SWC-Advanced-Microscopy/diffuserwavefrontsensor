function varargout=fibrephase(fDist,pupilSize,lambda)
    % Determine the phase delay of a spherical wave hitting a pupil from a known distance
    %
    % out = dw.fibrephase(fDist,pupilSize,lambda)
    %
    % Purpose
    % This function is intended to be used to calculate the phase delay across the sensor
    % when illuminated by a single-mode fibre at a known distance. A plot is produced unless
    % the user opts to return data, in which case no plot is produced. 
    %
    %
    % Inputs
    % fDist - distance between fibre tip and sensor in meters. Default is 1 m. Can also be a
    %         vector, in which case the delay for multiple distances is evaluated.
    % pupilSize - the size of the chip in mm along the shortest dimension. Default is 10 mm
    % lambda - the wavelength of the illumination light in nm. Default is 635 nm.
    %
    %
    % Outputs (optional)
    % out - A structure with the phase curves and inputs used to produce them. 2D phase plots
    %       are returned. 
    %
    %
    % Examples
    % >> dws.fibrephase
    % >> dws.fibrephase(1:0.025:2)
    %
    %
    % Rob Campbell - SWC 2019



    if nargin<1 || isempty(fDist)
        fDist=1;
    end
    fDist = sort(fDist,'descend');

    if nargin<2 || isempty(pupilSize)
        pupilSize = 10;
    end

    if nargin<3 || isempty(lambda)
        lambda = 635;
    end


    X=[];
    Y=[];
    Z=[];
    for ii=1:length(fDist)
        % The half-angle subtended by the pupil
        theta = tan((1E-3*pupilSize/2)/fDist(ii));

        % Create a meshgrid of the points we will evaluate
        pts=linspace(-theta,theta,256);
        [xg,yg] = meshgrid(pts,pts);

        [z,x,y]=sph2cart(xg,yg,fDist(ii));

        X = cat(3,X,x);
        Y = cat(3,Y,y);
        Z = cat(3,Z,z);
    end



    % Convert coordinates to mm
    X=X*1E3;
    Y=Y*1E3;


    % Turn Z, which is the wavefront curvature, into a phase delay
    Z=bsxfun(@minus, Z, max(max(Z)) ); %To remove piston
    Zm=Z*1E3;  % This is useful to export
    Z=Z*1E9;    % From meters to nanometers
    Z=(Z/lambda)*2*pi; % Convert to radians

    % Prepare output arguments if necessary
    if nargout>0
        out.sensorPosX = X;
        out.sensorPosY = Y;
        out.phaseDelay = Z;
        out.curvatureInmm = Zm;
        out.lambda = lambda;
        out.pupilSize = pupilSize;
        out.fDist = fDist;
        varargout{1}=out;
        return
    end


    % Plot if no outputs were requested
    tFig=dws.focusNamedFig(mfilename);
    clf(tFig)

    subplot(1,2,1)
    doLinePlot(X,Z)
    ylabel('Phase delay')

    subplot(1,2,2)
    if length(fDist)>2
        doLinePlot(X,  bsxfun(@minus,Z,Z(:,:,1)) )
        ylabel('\Delta phase delay')
    else
        if length(fDist)==2
            zz = diff(Z,[],3);
        else
            zz = Z;
        end
        imagesc(zz-mean(zz(:)))
        axis square off
        title('\Delta phase (rad)')
        colorbar

    end




    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    % Internal functions follow
    function doLinePlot(X,Z)
        n=size(X,3); % The number of distances to plot
        if n>3
            set(gca,'ColorOrder',parula(n),'NextPlot', 'replacechildren');
        else
            set(gca,'ColorOrder',jet(n),'NextPlot', 'replacechildren');
        end
        midPoint = round(size(X,1)/2);
        xp = squeeze(X(1,:,:));
        zp = squeeze(Z(midPoint,:,:));
        plot(xp,zp,'-')
        axis tight
        box on
        grid on
        xlabel('Position on sensor (mm)')
