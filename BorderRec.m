function [ AC11, AC22, AC1, AC2 ] = BorderRec( TM, VIEW )
%Creates the maximum gradient projection and sends it to the simplified
%active contour segmentation algorithm.  It also return the modified
%contours and the original contours.

sigma = 6;
CM = 2;
p=99;

load('zStacks')
load('data_config')
mkdir ROOT_BORDER

viewN = VIEW;

[I1,~] = microImInputRaw(spm,TM,CM,1); %Take in 3D Brightfield images
if(viewN==2)
    [I2,~] = microImInputRaw(spm,TM,CM,2);
elseif(viewN==1)
    I2 = I1; %Just duplicate the first view if we don't have a second one
else
    error('Must have either 1 or 2 views');
end

s1 = size(I1); %Size of images
s2 = size(I2);

Igrad1 = zeros(s1); %Getting the gradients of both images
for z=1:s1(3) %Getting the gradient of a gaussian filtered image
    [Igrad1(:,:,z),~] = imgradient(imgaussfilt(I1(:,:,z),sigma));
end
Igrad2 = zeros(s2);
for z=1:s2(3) 
    [Igrad2(:,:,z),~] = imgradient(imgaussfilt(I2(:,:,z),sigma));
end

%Find the percentile of the data

%View 1
data = zeros(s1(1)*s1(2)*s1(3),1);
i=1;
for row=1:s1(1)
    for col=1:s1(2)
        for z=1:s1(3)
            data(i) = Igrad1(row,col,z); %Put pixels in a data vector
            i=i+1;
        end
    end
end
y1 = prctile(data,p);
%View 2
data = zeros(s2(1)*s2(2)*s2(3),1);
i=1;
for row=1:s2(1)
    for col=1:s2(2)
        for z=1:s2(3)
            data(i) = Igrad2(row,col,z); %Put pixels in a data vector
            i=i+1;
        end
    end
end
y2 = prctile(data,p);

%Threshold the image with the percentile
Ith1 = zeros(s1(1),s1(2));
Ith2 = zeros(s2(1),s2(2));

for z=1:s1(3)
    Ith1(:,:,z) = im2bw(Igrad1(:,:,z),y1);
end
for z=1:s2(3)
    Ith2(:,:,z) = im2bw(Igrad2(:,:,z),y2);
end

Ith1 = im2double(Ith1);
Ith2 = im2double(Ith2);
Imax1 = max(Ith1,[],3);
Imax2 = max(Ith2,[],3);
imwrite(Imax1,[pwd '/ROOT_BORDER/GRAD_TH_' num2str(TM) '_v' num2str(1) '.tif']);
imwrite(Imax2,[pwd '/ROOT_BORDER/GRAD_TH_' num2str(TM) '_v' num2str(2) '.tif']);

%Create a contour for both views
[AC1, MidLine1, maxX1] = acSeg(Imax1,'none');
[AC2, MidLine2, maxX2] = acSeg(Imax2,'none');

if(viewN==1) %If only one view
    maxY2 = max(AC2(2,:)); %Max y value
    AC2tmp = AC2;
    AC2tmp(2,:) = maxY2-AC2tmp(2,:); %Flip it over the y.
    xm = (AC2tmp(1,1)+AC2tmp(1,end))/2;
    ym = AC2tmp(2,1);
    m = xm/ym; %slope with respect to y axis
    for i=1:size(AC2,2)
        AC2(1,i) = AC2(1,i)-(maxY2-AC2(2,i))*m;
    end
    MidLine2(1,:) = zeros(1,size(MidLine2,2));
end

%Creates a reconstruction image of the specimen
[AC11,AC22] = create3DRec(AC1,AC2,MidLine1,MidLine2);
axis([-s1(1)/2 s1(1)/2 -s1(1)/2 s1(1)/2 0 s1(2)]);

AC1(1,:) = AC1(1,:)+maxX1;
AC2(1,:) = AC2(1,:)+maxX2;

save([pwd '/ROOT_BORDER/Border_Data_TM' num2str(TM,'%.4u')],'AC11','AC22','AC1','AC2');
end

