function out = FFT(x)
    % Calculate 2d FFT of image x
    out = fftshift(fft2(fftshift(x)));
end
