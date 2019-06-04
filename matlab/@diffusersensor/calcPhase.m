function calcPhase(obj)
    % diffusersensor.calcphase
    %
    % Calculate the phase plot and fit Zernike polynomials to it

    if isempty(obj.refImage)
        return
    end

    %Stop the acquisition if it's running (and restart at the end)
    vidRunning=isrunning(obj.cam.vid);
    if vidRunning
        obj.stopVideo
    end
    verbose=true;

    % Convert to meters
    pixSize = obj.pixSize * 1E-6;
    lambda  = obj.lambda  * 1E-9; 
    camDistance= obj.camDistance * 1E-3;

    lastFrame=obj.lastFrame;
    refImage =obj.refImage;



    if obj.resizeBy<=1 && obj.resizeBy>0.1
        pixSize = pixSize / obj.resize; %Correct the pixel size
        lastFrame = imresize(lastFrame,obj.resizeBy);
        refImage = imresize(refImage,obj.resizeBy);
    end

    if obj.transCor
        if verbose
            fprintf('Doing translation correction...')
        end
        [lastFrame,shiftBy]=dws.apply_ffttrans(lastFrame,refImage);
        cropBy = ceil(max(abs(shiftBy)));
        if cropBy>1
            lastFrame = lastFrame(cropBy:end-cropBy,cropBy:end-cropBy);
            refImage= refImage(cropBy:end-cropBy,cropBy:end-cropBy);
            %Plot it so we know for sure what we're doing
            tmp = repmat(refImage,[1,1,3]);
            tmp(:,:,2) = lastFrame; %which has been registered
            tmp(:,:,3) = 0;
            obj.hImLive.CData = tmp;
            obj.hTitle.String = 'OVERLAY OF REGISTERED IMAGE';
            drawnow
        end
        if verbose
            fprintf('done\n')
        end
    else
        obj.updateLiveImage
    end





    %----------  non-rigid image registration  ----------
    PL=3;
    if verbose
        fprintf('Running demon registration....')
    end
    obj.demons=imregdemons(lastFrame,refImage,10*ones(PL,1),'AccumulatedFieldSmoothing',3,'PyramidLevels',PL,'DisplayWaitbar',false);
    % obj.demons is the displacement field along rows and columns used to align the fixed to the moving image
    if verbose
        fprintf('done\n')
    end

    % We can resize the gradient images further, as they should be smooth
    if obj.gradientImDownscaleFactor<1 && obj.gradientImDownscaleFactor>0.1
        pixSize = pixSize / obj.gradientImDownscaleFactor;
        obj.demons = imresize(obj.demons,obj.gradientImDownscaleFactor 0.5);
    end

    %----------   symetrization for gradient integration   ----------
    if verbose
        fprintf('Fourier integration...')
    end

    M=size(obj.demons,1);
    N=size(obj.demons,2);
    D2=zeros(2*M,2*N,2);
    D2([1:M],[1:N],:)=obj.demons;
    D2(M+[1:M],[1:N],:)=flipud(obj.demons);
    D2([1:M],N+[1:N],:)=fliplr(obj.demons);
    D2(M+[1:M],N+[1:N],:)=rot90(obj.demons,2);


    %----------   Fourier integration   ----------
    % Make anonymous functions
    obj.FFT  = @(x) fftshift(fft2(fftshift(x)));
    obj.IFFT = @(x) ifftshift(ifft2(ifftshift(x)));

    [Kx,Ky]=meshgrid([-N:N-1],[-M:M-1]);
    Kx=Kx*pi/N; 
    Ky=Ky*pi/M;
    S=Kx+1i*Ky;
    Ks=zeros(2*M,2*N); Ks(S~=0)=1./S(S~=0);

    prov=real( obj.IFFT( -1i*Ks.*obj.FFT(D2(:,:,1)+1i*D2(:,:,2)) ) );

    if verbose
        fprintf('done\n')
    end
    % ----------   phase scaling factor   ----------
    SF=2*pi*pixSize^2/(lambda*camDistance); %scaling factor
    obj.phaseImage=SF*prov([1:M],[1:N]);



    % Fit Zernikes
    if obj.doFitZernike
        obj.calcZernike
    else
        obj.zernCoefs=[];
        obj.zernNames=[];
    end
        

    if vidRunning
        obj.startVideo
    end
end
