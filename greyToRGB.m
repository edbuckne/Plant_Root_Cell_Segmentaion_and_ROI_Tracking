function [ colorImage ] = greyToRGB( WBim, RGB, Inv )
%gretyToRGB takes a tif grey image and transforms it to either a red image,
%green image, or a blue image.
%3 parameters
%   1. WBim - Wide-band image matrix
%   2. RGB - option for red, green, or blue
%       1 - Red
%       2 - Green
%       3 - Blue
%   3. Inv - option for inverted picture or regular
%       'inv' - invert the image
%       'reg' - don't invert the image
%1 output
%   1. colorImage - returns a 3 demension matrix in the form of an RGB
%   image.  n x m x 3 matrix where n x m is the demensions of pixels in the
%   image and the 3rd demension describes the R,G,and B values for each
%   pixel.
%
%   By Eli Buckner
maskNum = (2^16)-1; %Images described by a 16 bit number

if (~strcmp(Inv,'inv') && ~strcmp(Inv,'reg'))
    disp('ERROR: wrong input for the Inv variable (please put "inv" or "reg")');
    return;
end
    

SZ1 = size(WBim);  %Gets the demensions of the tif image
colorImage = zeros(SZ1(1),SZ1(2),3); %Creates an empty matrix for the RGB image

switch RGB
    case 1 %Red image
        switch Inv
            case 'inv'
                for x=1:SZ1(1)
                    for y=1:SZ1(2)
                        colorImage(x,y,1) = 1;
                        colorImage(x,y,2) = 1-double(WBim(x,y))/double(maskNum);
                        colorImage(x,y,3) = 1-double(WBim(x,y))/double(maskNum);
                    end
                end
            case 'reg'
                for x=1:SZ1(1)
                    for y=1:SZ1(2)
                        colorImage(x,y,1) = 1;
                        colorImage(x,y,2) = double(WBim(x,y))/double(maskNum);
                        colorImage(x,y,3) = double(WBim(x,y))/double(maskNum);
                    end
                end
        end
    case 2 %Green image
        switch Inv
            case 'inv'
                for x=1:SZ1(1)
                    for y=1:SZ1(2)
                        colorImage(x,y,1) = 1-double(WBim(x,y))/double(maskNum);
                        colorImage(x,y,2) = 1;
                        colorImage(x,y,3) = 1-double(WBim(x,y))/double(maskNum);
                    end
                end
            case 'reg'
                for x=1:SZ1(1)
                    for y=1:SZ1(2)
                        colorImage(x,y,1) = double(WBim(x,y))/double(maskNum);
                        colorImage(x,y,2) = 1;
                        colorImage(x,y,3) = double(WBim(x,y))/double(maskNum);
                    end
                end
        end
    case 3 %Blue image
        switch Inv
            case 'inv'
                for x=1:SZ1(1)
                    for y=1:SZ1(2)
                        colorImage(x,y,1) = 1-double(WBim(x,y))/double(maskNum);
                        colorImage(x,y,2) = 1-double(WBim(x,y))/double(maskNum);
                        colorImage(x,y,3) = 1;
                    end
                end
            case 'reg'
                for x=1:SZ1(1)
                    for y=1:SZ1(2)
                        colorImage(x,y,1) = double(WBim(x,y))/double(maskNum);
                        colorImage(x,y,2) = double(WBim(x,y))/double(maskNum);
                        colorImage(x,y,3) = 1;
                    end
                end
        end
    otherwise
        disp('ERROR: Please enter a value for RGB between 1-3');
end
end

