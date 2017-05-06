function [ I ] = brightfieldRaw( TM, CM )
microData = bfopen();
camStack = getCameraData(microData, CM, TM);

s = size(camStack);
I = zeros(s);

for z=1:s(3)
    I2 = im2double(camStack(:,:,z));
    
    minP = min(I2(:));
    I2 = I2-minP;
    maxP = max(I2(:));
    I2 = I2./maxP;
    
    I(:,:,z) = I2;
end
end

