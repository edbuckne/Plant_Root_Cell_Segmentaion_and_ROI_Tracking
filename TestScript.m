maskNum = (2^16)-1; %Images described by a 16 bit number
threshold = 9000;
dataWidth = 20;
fileStrings = '04050607080910';
fileName1 = 'SPM01_TM0001_CM2_CHN00_PLNxx.tif';
fileName2 = 'SPM01_TM0001_CM1_CHN00_PLNxx.tif';
newFile = fileName1;

for i=1:7
    newFile = [fileName1(1:26) fileStrings(i*2-1) fileStrings(i*2) fileName1(29:32)];
    [WBim,map1]=imread(newFile); %Wide-band image
    newFile = [fileName2(1:26) fileStrings(i*2-1) fileStrings(i*2) fileName2(29:32)];
    [GFPim,map2]=imread(newFile); %GFP image
   
    WBimC = histeq(WBim);
    WBimC2 = wiener2(WBimC,[20 20]);
    redWBimC = greyToRGB(WBimC2,1,'inv'); %Creates an inverted red image of the wide-band image
    greenGFPim = greyToRGB(GFPim,2,'inv'); %Filters out everything that isn't showing floresence of the GFP image
    [boundIm,cellLocation] = drawBounds(redWBimC,dataWidth,0); %Draws the boundaries on the red wideband image
    orig=greyToRGB(WBim,1,'reg');
    J = mergeOrig(orig,cellLocation);
    mergedImage = mergeCellIms(J,greenGFPim,0.85); %Merges the two images
    %imshow(mergedImage);
    %imwrite(mergedImage,'./boundTesting/test5.tif');
    imwrite(mergedImage,['./boundTesting/' newFile])
    disp([newFile ' Finished']);
end
%%
A = imread('SPM01_TM0001_CM2_CHN00_PLN01.tif');
I = greyToRGB(histeq(A),1,'inv');
SZ = size(I);

column=325;
for column=1:SZ(2)
data=I(:,column,2);
N = length(data);
dp = 0:1/N:1-1/N;
fildata = filter([0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1],1,data);
for i=1:length(fildata)
    if fildata(i) > 0.9
        fildata(i)=1;
    end
    if fildata(i) > 0.6
        fildata(i)=(fildata(i))^2;
        
    end
end
derData = diff(filData);
N = length(derData);
dpd = 0:1/N:1-1/N;
dataSet=[fildata [derData; 0]];


I(:,column,2) = fildata;
I(:,column,3) = fildata;
end
imshow(I)
% Ifilt = I;
% for i=1:SZ(2)
%     data = I(:,i,2);
%     N = length(data);
%     dp = 0:1/N:1-1/N;
%     filData = filter([0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05],1,data);
%     Ifilt(:,i,2) = filData;
%     Ifilt(:,i,3) = filData;
% end
% Ifilt2=Ifilt;
% for i=1:SZ(1)
%     data = Ifilt2(i,:,2);
%     N = length(data);
%     dp = 0:1/N:1-1/N;
%     filData = filter([0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05],1,data);
%     Ifilt(i,:,2) = filData;
%     Ifilt(i,:,3) = filData;
% end
% figure(1)
% imshow(I)
% figure(2)
% imshow(Ifilt)
%%
I = imread('SPM01_TM0001_CM2_CHN00_PLN01.tif');
sz = size(I);
XStart = 1;
YStart = 1;
Inc = 30;
I2 = histeq(I);
I3 = greyToRGB(I2,1,'inv');
I4 = I3;

for YLocal = 1:30:1890
    YLocal/1890
    for XLocal = 1:30:690
        
        Y = YLocal:YLocal+Inc-1;
        X = XLocal:XLocal+Inc-1;
        
        min = I3(Y(1),X(1),2);
        max = I3(Y(1),X(1),2);
        
        for A=X
            for B=Y
                if(I3(B,A,2)<min)
                    min = I3(B,A,2);
                    areaB = B;
                    areaA = A;
                end
                if(I3(B,A,2)>max)
                    max = I3(B,A,2);
                end
            end
        end
%         m = (double(max)-double(min));
%         m = 1.00/m;
%         B = -m*double(min);
        I4(areaB,areaA,1) = 0;
        I4(areaB,areaA,2) = 0;
        I4(areaB,areaA,3) = 0;
        
    end
end
figure(1)
imshow(I3);
figure(2)
imshow(I4);