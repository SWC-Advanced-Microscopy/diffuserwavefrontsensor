function dws=testAbsRef
    % Simulate an absolute reference that needs to be translation corrected 
    %
    % dws is an instance of diffusersensor
    % run from root directory of matlab code


    imRef = imread('../example_images/ref.bmp');
    imTst = imread('../example_images/lens.bmp');

    imTst = circshift(imTst,[2,30]);

    ind = 50:950;

    dws=diffusersensor;
    dws.stopVideo;

    dws.refImage = imRef(ind,ind);
    dws.testImage = imTst(ind,ind);

    % Looks crappy as expected
    dws.transCor=false; %ensure it's false
    dws.getPhase

    disp('Press return to try translation correction')
    pause
    % Now is perfect
    dws.transCor=true;
    dws.getPhase; 