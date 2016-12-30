function [ virtBoundIm ] = virtBound( image, data, column )

SZ = size(image); %Size of the image
x = column; %This stays constant for going down a single column
N = length(data); %How many points are in data
virtBoundIm = image;

for i=1:N
    virtBoundIm(data(i),x,1) = 0; %Wherever there was a negative zero crossing, make black
    virtBoundIm(data(i),x,2) = 0;
    virtBoundIm(data(i),x,3) = 0;
end

end