function [ GV ] = calcGrowthVec( I0, I1 )
% This function calculates the XY growth vector of two 3D brightfield images
% of the Arabidopsis root.  This is done by getting a tip estimation point
% and taking a small roi image from I0's maximum gradient projection.  This
% roi image from I0 is compared to the full maximum gradient projection
% image from I1 and the normal cross correlation is found between the two.
% The point in which we find the maximum of the cross correlation function
% is the point that describes the best fit image registration shift.
% Inputs:
%   I0 - 3D brightfield image of time equals t-1
%   I1 - 3D brightfield image of time equals t
% Outputs:
%   GV - 2X1 vector describing the image shift in the x and y directions
%   (Units: pixels)
% 
% Author: Eli Buckner - North Carolina State University, Raleigh, NC

sigma = 4; %Variance for gaussian filter
roiScaler = 1/4; %This is the scaled image size that holds the roi
tipScale = 4; %Used to reduce the image size to find the root tip
p = 99; %Statistical threshold for logical images

s0 = size(I0); %Size of images
s1 = size(I1);

disp('Getting gradient of first image')
Igrad0 = zeros(s0); %Getting the gradients of both images
for z=1:s0(3) %Getting the gradient of a gaussian filtered image
    [Igrad0(:,:,z),~] = imgradient(imgaussfilt(I0(:,:,z),sigma));
end
Igrad0 = uint16(Igrad0); %Saves memory
Igrad1 = zeros(s1);
disp('Getting gradient of second image')
for z=1:s1(3) 
    [Igrad1(:,:,z),~] = imgradient(imgaussfilt(I1(:,:,z),sigma));
end
Igrad1 = uint16(Igrad1);

y0 = double(prctile(Igrad0(:),p))/(2^16); %Finds the percentile p in the image data

Imp0 = max(Igrad0,[],3); %Projects the maximum gradient
Imp1 = max(Igrad1,[],3);

Ith0 = im2double(im2bw(Imp0,y0)); %Threshold the images
Ith1 = im2double(im2bw(Imp1,y0));

fi = ones(300)./300^2; %Filter kernal for the image

Ith00 = imfilter(Ith0,fi); %Filter the images
Ith11 = imfilter(Ith1,fi);

m0 = max(Ith00(:)); %find the max pixel value for images
[row0, col0] = find(Ith00==m0);
m1 = max(Ith11(:)); %find the max pixel value for images
[row1, col1] = find(Ith11==m1);

sth0 = size(Ith0);
sth1 = size(Ith1);
Ith0 = imresize(Ith0,sth0./tipScale);
Ith1 = imresize(Ith1,sth1./tipScale);

%Region grow the images to create a mask
disp('Region growing for first image')
Irg0 = rgTestbw(Ith0,round(col0(1)/tipScale),round(row0(1)/tipScale)); %Region grow from the points that was found
disp('Region growing for second image')
Irg1 = rgTestbw(Ith1,round(col1(1)/tipScale),round(row1(1)/tipScale));

%Estimate the root tip from the low quality images
sSmall0 = size(Irg0);
xtip = 0;
ytip = 0;
for row = 1:sSmall0(1)
    for col = 1:sSmall0(2)
        if(Irg0(row,col)==1 && row>ytip)
            ytip = row;
            xtip = col;
        end
    end
end
Irg0 = im2double(im2bw(imresize(Irg0,[s0(1) s0(2)]),0.5)); %Size the region growing images back to original size
Irg1 = im2double(im2bw(imresize(Irg1,[s1(1) s1(2)]),0.5));
Imp1 = im2uint16(im2double(Imp1).*Irg1);

ytip = ytip*tipScale; %This is used to scale the coordinates back to original image
xtip = xtip*tipScale;
stip0 = s0*roiScaler; %Size of the roi image

if ytip+round(stip0(1)/2)>s0(1) %Make sure the roi doesn't go outside of the image
    ydown = s0(1);
    yup = ydown-stip0(1);
else
    ydown = ytip+round(stip0(1)/2);
    yup = ytip-round(stip0(1)/2);
end 
if xtip+round(stip0(2)/2)>s0(2) %Make sure the roi doesn't go outside of the image
    xright = s0(2);
    xleft = xright-stip0(2);
else
    xright = xtip+round(stip0(2)/2);
    xleft = xtip-round(stip0(2)/2);
end 

Imp02 = im2double(Imp0).*Irg0; %Multiply the masked image with Imp0
Imp0 = im2uint16(Imp02); %Cast Imp02 back to an unsigned integer image
Itip0 = Imp0(yup:ydown,xleft:xright); 

rowVal1 = Imp1(end,:);%Extending I1 to avoid false correlations when the root is close to the bottom of the image
Imp1 = [Imp1; ones(sSmall0(1),s1(2))];
for row=s1(1)+1:s1(1)+sSmall0(1)
    Imp1(row,:) = rowVal1;
end

where = normxcorr2(Itip0,Imp1); %Correlation of two images
[ypeak, xpeak] = find(where==max(where(:)));
yoffSet = ypeak - sSmall0(1)+1;
xoffSet = xpeak - sSmall0(2)+1;
yoffSetIdeal = yup;
xoffSetIdeal = xleft;
% xoffSetIdeal = xtip-sSmall0(2)/2;

GV = [xoffSet-xoffSetIdeal yoffSet-yoffSetIdeal];
end

