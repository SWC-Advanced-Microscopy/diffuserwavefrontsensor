function out = IFFT(x)
    % Calculate 2d inverse FFT of image x
    out = ifftshift(ifft2(ifftshift(x)));
end
