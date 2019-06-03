function vid=macbook01
    vid = videoinput('macvideo', 1, 'YCbCr422_1280x720');
    vid.FramesPerTrigger = 1;
end