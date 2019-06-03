function vid=basler
    vid = videoinput('gentl', 1, 'Mono8');
    src.AcquisitionFrameRateEnable = 'True';
    src.AcquisitionFrameRate = 1;
end
