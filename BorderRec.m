function [ ] = BorderRec( SPM, TM )
sigma = 6;
p=90;

load zStacks
mkdir ROOT_BORDER

[I1,~] = microImInputRaw(SPM,TM(1),1,zStacks(TM(1))); %Take in 3D Brightfield images
[I2,~] = microImInputRaw(SPM,TM(2),1,zStacks(TM(2)));

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
imwrite(Imax1,[pwd '/ROOT_BORDER/GRAD_TH_' num2str(TM(1)) '_2.tif']);
imwrite(Imax2,[pwd '/ROOT_BORDER/GRAD_TH_' num2str(TM(2)) '_2.tif']);

%Create a contour for both views
[AC1, MidLine1] = acSeg(Imax1,'show');
[AC2, MidLine2] = acSeg(Imax2,'show');

%Creates a reconstruction image of the specimen
[AC1,AC2] = create3DRec(AC1,AC2,MidLine1,MidLine2);
end

