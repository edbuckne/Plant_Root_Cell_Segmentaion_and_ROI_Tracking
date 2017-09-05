function [ GV ] = calcGrowthVec( I0, I1 )

%~~~~~~~~~~~~~Active Contour on Max Projection Method~~~~~~~~~~~~~~~~~~~~~%
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
for z=1:s1(3) 
    [Igrad1(:,:,z),~] = imgradient(imgaussfilt(I1(:,:,z),sigma));
end
Igrad1 = uint16(Igrad1);

y0 = double(prctile(Igrad0(:),p))/(2^16); %Finds the percentile p in the image data
% y1 = double(prctile(Igrad1(:),p))/(2^16);

Igmp0 = max(Igrad0,[],3); %Projects the maximum gradient
Imp0 = Igmp0;
%clear Igrad0 %Free up memory of gradient image
Imp1 = max(Igrad1,[],3);
%clear Igrad1

Ith0 = im2double(im2bw(Igmp0,y0)); %Threshold the image

fi = ones(300)./300^2; %Filter kernal for the image

Ith00 = imfilter(Ith0,fi); %Filter the images

m0 = max(Ith00(:)); %find the max pixel value for images
[row0, col0] = find(Ith00==m0);
%clear Ith00 %Don't need these images anymore

sth0 = size(Ith0);
Ith0 = imresize(Ith0,sth0./tipScale);

disp('Region growing for first image')
Irg0 = rgTestbw(Ith0,round(col0(1)/tipScale),round(row0(1)/tipScale)); %Region grow from the points that was found

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
ytip = ytip*tipScale; %This is used to scale the coordinates back to original image
xtip = xtip*tipScale;
stip0 = s0*roiScaler; %Size of the roi image
Itip0 = Imp0(ytip-round(stip0(2)/2):ytip+round(stip0(2)/2),xtip-round(stip0(1)/2):xtip+round(stip0(1)/2));
where = normxcorr2(Itip0,Imp1); %Correlation of two images
[ypeak, xpeak] = find(where==max(where(:)));
yoffSet = ypeak - sSmall0(1)+1;
xoffSet = xpeak - sSmall0(2)+1;
yoffSetIdeal = ytip-sSmall0(1)/2;
xoffSetIdeal = xtip-sSmall0(2)/2;

GV = [xoffSet-xoffSetIdeal yoffSet-yoffSetIdeal];


figure(1)
imshow(Imp0)

figure(2)
imshow(Imp1)
hold on
line([xtip xtip+GV(1)],[ytip ytip+GV(2)])

%~~~~~~~~~~~~~Image Registration on BF Max Projection~~~~~~~~~~~~~~~~~~~~~%
% s0 = size(I0); %Size of images
% s1 = size(I1);
% 
% Imax0 = max(I0,[],3); %Find the maximum projection
% Imax1 = max(I1,[],3);
% 
% where = normxcorr2(Imax1,Imax0);
% 
% maxCorr = max(where(:)); %Find the value the represents the highest correlation
% [delY delX] = find(where==maxCorr)
% 
% 
% 
% %~~~~~~~~~~Image Registration on Gradient Max Projections~~~~~~~~~~~~~~~~~%
% sigma = 6; %Variance for gaussian filter
% 
% s0 = size(I0); %Size of images
% s1 = size(I1);
% 
% Igrad0 = zeros(s0); %Getting the gradients of both images
% for z=1:s0(3) %Getting the gradient of a gaussian filtered image
%     [Igrad0(:,:,z),~] = imgradient(imgaussfilt(I0(:,:,z),sigma));
% end
% Igrad0 = uint16(Igrad0); %Saves memory
% Igmax0 = max(Igrad0,[],3); %Maximum gradient projection image
% Igrad1 = zeros(s1);
% for z=1:s1(3) 
%     [Igrad1(:,:,z),~] = imgradient(imgaussfilt(I1(:,:,z),sigma));
% end
% Igrad1 = uint16(Igrad1);
% Igmax1 = max(Igrad1,[],3);
% 
% fi = ones(300); %Filter kernal for the image
end

