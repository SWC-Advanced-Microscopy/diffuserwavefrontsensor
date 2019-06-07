function distanceEstimateTheory
    % function dws.demo.distanecEstimateTheory
    %
    %
    % Purpose
    % Simulate a series of measurements of wavefront curvature at known
    % distances from a point source. Determine the difference in wavefront 
    % curvature between the first measurement and the rest.
    % Use those differences to determine the relative distance to the point
    % source.


    sensorSizeInMM = 10;

    sourceDistancesInMM = [500,400,370,366,363,361,360.5,360.25,360];

    out = dws.fibrephase(sourceDistancesInMM*1E-3, sensorSizeInMM);

    % Make matrix for fitting the circle
    spd=[];
    for ii=1:size(out.phaseDelay,3)
        X = out.sensorPosX(:,:,ii);
        Y = out.sensorPosY(:,:,ii);
        Z = out.curvatureInmm(:,:,ii);

        spd = cat(3, spd, [X(:),Y(:),Z(:)]);
    end

    % Report the curvatures
    for ii=1:size(out.phaseDelay,3)
        [~,rFit(ii)] = dws.sphereFit(spd(:,:,ii));
    end

    f=dws.focusNamedFig(mfilename);
    figure(f)
    clf

    subplot(1,3,1)
    plot(sourceDistancesInMM,rFit,'ob','markerfacecolor',[0.5,0.5,1])
    grid on
    hold on
    unityLine
    xlabel('Actual distance (mm)')
    ylabel('Fitted distance (mm)')




    %Now we determine the difference in radius
    % Report the curvatures

    for ii=1:size(out.phaseDelay,3)-1
        spdEND = spd(:,:,end);
        spdEND(:,3) = spdEND(:,3)-spd(:,3,ii);
        [~,dr(ii)] = dws.sphereFit(spdEND); %difference in radius
        disp(dr(ii))
    end


    % Determine the original radius by:
    % 1) Making a wavefront out of each value of dr
    % 2) Adding this wavefront to the reference (last wavefront)
    % 3) Fit to determine radius
    for ii=1:size(out.phaseDelay,3)-1
        tWaveFront = dws.fibrephase(dr(ii)/1000, sensorSizeInMM);
        simuWaveFront = spd(:,:,end);
        simuWaveFront(:,3) = simuWaveFront(:,3)-tWaveFront.curvatureInmm(:);
        [~,est(ii)] = dws.sphereFit(simuWaveFront); %difference in radius
    end
    est

    subplot(1,3,2)
    plot(sourceDistancesInMM(1:length(est)),est,'ob','markerfacecolor',[0.5,0.5,1])
    grid on
    hold on
    xlabel('Actual distance (mm)')
    ylabel('Derived distance (mm)')
    unityLine

    % I think the errors here come from the fact that we aren't 
    % evaluating the sphere at exactly the same x and y coords
    % at different distances. 
    subplot(1,3,3)
    resid=sourceDistancesInMM(1:length(est))-est;
    plot(sourceDistancesInMM(1:length(est)),resid*1E6,'ob','markerfacecolor',[0.5,0.5,1])
    ylabel('residuals (nm)')
    xlabel('Actual distance (mm)')