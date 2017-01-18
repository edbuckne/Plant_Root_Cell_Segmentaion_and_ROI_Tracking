fileName = 'SPM01_TM0001_CM2_CHN00_PLN10.tif';
I = imread(fileName);
%I = I(50:550,100:300);
I2 = im2double(I);
szI2 = size(I2);

h = fspecial('disk',8);
I3 = imfilter(I2,h,'replicate');
szI3 = size(I3);
I4 = zeros(szI3(1),szI3(2));

for j=1:szI3(2)
    data = I3(:,j);
    data2 = filter([0.125 0.125 0.125 0.125 0.125 0.125 0.125 0.125],1,data);
    data3 = diff(data2);
    
    A = findZCrossing(data3,1);
    lenA = length(A);
    B = findZCrossing(data3,0);
    lenB = length(B);
    
    if (lenA>lenB)
        differ = lenA-lenB;
        endMat = zeros(differ,1);
        B = [B; endMat];
    elseif (lenB>lenA)
        differ = lenB-lenA;
        endMat = zeros(differ,1);
        A = [A; endMat];
    end
    newData = zeros(length(data),1);
    
    AB = [A B];
    
    for i=2:lenB-2
        if (A(i)>B(i))
            Thalf = B(i-1)-A(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = 0.2.*cos(2*pi*f*t)+0.5;
            newData(A(i):B(i-1)-1)=dataIns;
        else
            Thalf = B(i)-A(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = 0.2.*cos(2*pi*f*t)+0.5;
            newData(A(i):B(i)-1)=dataIns;
        end
    end
    
    for i=1:lenB-2
        if (B(i)>A(i))
            Thalf = A(i+1)-B(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = -0.2.*cos(2*pi*f*t)+0.5;
            newData(B(i):A(i+1)-1)=dataIns;
        else
            Thalf = A(i)-B(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = (-0.2.*cos(2*pi*f*t))+0.5;
            newData(B(i):A(i)-1)=dataIns;
        end
    end
    I4(:,j) = newData;
end
        


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%


I5 = zeros(szI3(1),szI3(2));

for j=1:szI3(1)
    data = I3(j,:);
    data2 = filter([0.125 0.125 0.125 0.125 0.125 0.125 0.125 0.125],1,data);
    data3 = diff(data2);
    
    A = findZCrossing(data3,1);
    lenA = length(A);
    B = findZCrossing(data3,0);
    lenB = length(B);
    
    if (lenA>lenB)
        differ = lenA-lenB;
        endMat = zeros(differ,1);
        B = [B; endMat];
    elseif (lenB>lenA)
        differ = lenB-lenA;
        endMat = zeros(differ,1);
        A = [A; endMat];
    end
    newData = zeros(length(data),1);
    
    
    for i=2:lenB-2
        if (A(i)>B(i))
            Thalf = B(i-1)-A(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = 0.2.*cos(2*pi*f*t)+0.5;
            newData(A(i):B(i-1)-1)=dataIns;
        else
            Thalf = B(i)-A(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = 0.2.*cos(2*pi*f*t)+0.5;
            newData(A(i):B(i)-1)=dataIns;
        end
    end
    
    for i=1:lenB-2
        if (B(i)>A(i))
            Thalf = A(i+1)-B(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = -0.2.*cos(2*pi*f*t)+0.5;
            newData(B(i):A(i+1)-1)=dataIns;
        else
            Thalf = A(i)-B(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = (-0.2.*cos(2*pi*f*t))+0.5;
            newData(B(i):A(i)-1)=dataIns;
        end
    end
    I5(j,:) = newData;
end

I6 = I4.*I5;
I7 = imfilter(I6,h,'replicate');
BW = 1.00 - imregionalmax(I7);
I8 = I2.*BW;
szI8 = size(I8);
cellLoc = [];
RGBGrey = zeros(szI2(1),szI2(2),3);
RGBGrey(:,:,1)=I2; RGBGrey(:,:,2)=I2; RGBGrey(:,:,3)=I2;

for x = 1:szI8(2)
    for y = 1:szI8(1)
        if (~(BW(y,x)==0))
        else
            cellLoc = [cellLoc; y x];
        end
    end
end
I9 = mergeOrig(RGBGrey, cellLoc);



% figure(2)
% plot(1:length(data),data);
% hold on
% plot(1:length(data2),data2);
% hold on
% plot(1:length(newData),newData);
% figure(1)
% imshow(I)
% figure(1)
% imshow(I7)
% figure(2)
% imshow(I9)

szI7 = size(I7);

I10 = zeros(szI7(1),szI7(2));
for x = 1:szI7(2)
    for y = 1:szI7(1)
        if (I7(y,x) > 0.3)
            I10(y,x) = 1;
        end
    end
end
I11 = I10.*I9(:,:,1);

imwrite(I11,['./region/Y' fileName]);
imwrite(I9,['./region/' fileName]);
