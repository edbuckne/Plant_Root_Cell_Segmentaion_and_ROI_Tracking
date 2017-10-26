function [ zRange ] = calcZShift( I, TH, sigma )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
s = size(I); %Get size of image
zMark = [];
for z=1:s(3)
    I2 = uint8(imgaussfilt(I(:,:,z),sigma)>TH); %Filter and threshold for gfp

    %If the logic is 1, gfp is present in this z stack
    pres = max(I2(:)); 
    if(pres)
        zMark = [zMark; z];
    end
end
zRange = [min(zMark) max(zMark)]; %Range of z stacks where information is found

end

