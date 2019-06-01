function calcPhase(obj)
    % diffusersensor.calcphase
    %
    % Calculate the phase plot 

    verbose=true;

    % Convert to meters
    pixSize = obj.pixSize * 1E-6;
    lambda  = obj.lambda  * 1E-9; 
    camDistance= obj.camDistance * 1E-3;

    [M,N]=size(testImage); %TODO testImage is what?

    obj.FFT=@(x) fftshift(fft2(fftshift(x)));
    obj.IFFT=@(x) ifftshift(ifft2(ifftshift(x)));

    %----------  non-rigid image registration  ----------
    PL=3;
    if verbose
        fprintf('Running demon registration....')
    end
    obj.demons=imregdemons(testImage,refImage,10*ones(PL,1),'AccumulatedFieldSmoothing',3,'PyramidLevels',PL,'DisplayWaitbar',false);
    % D is the displacement field along rows and columns used to align the fixed to the moving image
    if verbose
        fprintf('done\n')
    end

    %----------   symetrization for gradient integration   ----------
    if verbose
        fprintf('Fourier integration...')
    end

    D2=zeros(2*M,2*N,2);
    D2([1:M],[1:N],:)=obj.demons;
    D2(M+[1:M],[1:N],:)=flipud(obj.demons);
    D2([1:M],N+[1:N],:)=fliplr(obj.demons);
    D2(M+[1:M],N+[1:N],:)=rot90(obj.demons,2);


    %----------   Fourier integration   ----------
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

end
