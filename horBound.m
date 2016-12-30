function [ horBoundIm ] = horBound( image, data, row )

SZ = size(image); %Size of the image
y = row; %This stays constant for going down a single row
N = length(data); %How many points are in data
horBoundIm = image;

for i=1:N
    horBoundIm(y,data(i),1) = 0; %Wherever there was a negative zero crossing, make black
    horBoundIm(y,data(i),2) = 0;
    horBoundIm(y,data(i),3) = 0;
end

end

