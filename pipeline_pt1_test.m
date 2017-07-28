%This section of the script opens the czi files, performs a type of
%histogram equalization, and prints those images as .tif files to directories.

TM = 1;
zStacks = [];

fileN = input('Please enter the number of CZI files to be used: ');
tNum = zeros(fileN,1); %enter the number of time stamps per file into an array

spm = input('Please enter the number of the specimen: ');
dirName = ['SPM' num2str(spm,'%.2u')];
mkdir(dirName);

for f=1:fileN
    tNum(f) = input(['Please enter the number of time stamps in file ' num2str(f) ': ']);
end

for f=1:fileN
    microData = bfopen(); %Open the czi file
    
    for t=1:tNum(f)
        tmStr = ['TM' num2str(TM,'%.4u')];
        mkdir([dirName '/' tmStr]);
        
        cam1Stack = im2double(getCameraData(microData, 1, t));
        cam2Stack = im2double(getCameraData(microData, 2, t));
        
        s1 = size(cam1Stack);
        s2 = size(cam2Stack);
        zStacks = [zStacks; s1(3)];
        
        disp(['Spreading the range and printing camera 1 data for time stamp ' num2str(TM)]);
        I1 = min(cam1Stack,[],3); %Spreading the range of the camera 1 3D image
        minp = min(I1(:));
        cam1Stack = cam1Stack-minp;
        I1 = max(cam1Stack,[],3);
        maxp = max(I1(:));
        cam1Stack = cam1Stack./maxp;
        for z=1:s1(3) %Write camera 1 images in a directory
            imwrite(cam1Stack(:,:,z),[pwd '/' dirName '/' tmStr '/' tmStr '_CM1_Z' num2str(z,'%.3u') '.tif']);
        end
        
        disp(['Spreading the range and printing camera 2 data for time stamp ' num2str(TM)]);
        I1 = min(cam2Stack,[],3); %Spreading the range of the camera 2 3D image
        minp = min(I1(:));
        cam2Stack = cam2Stack-minp;
        I1 = max(cam2Stack,[],3);
        maxp = max(I1(:));
        cam2Stack = cam2Stack./maxp;
        for z=1:s2(3) %Write camera 1 images in a directory
            imwrite(cam2Stack(:,:,z),[pwd '/' dirName '/' tmStr '/' tmStr '_CM2_Z' num2str(z,'%.3u') '.tif']);
        end
        
        TM = TM+1;
    end
end
%%
disp('Creating multi-image files');
for t=4:TM-1 %Go pack in and balance the histogram of camera 1
    [I,~] = microImInputRaw(spm,t,1,zStacks(t));
    for z=1:zStacks(t)
        imwrite(I(:,:,z),['I_3D_SPM' num2str(spm,'%.2u') '_TM' num2str(t,'%.4u') '_CM1.tif'],'writemode','append');
    end
end
save('zStacks','zStacks','spm')
%%
%This section takes in a list of images and their names and renames them
%according to what's in this section's code.
% load zStacks

spm = 4;
z = 1;
v = 1;
t = 3;
cm = 2;
offset = 33;
numZ = 12;
interpN = 3;

SPMstr = num2str(spm,'%.2u');
TMstr = num2str(t,'%.4u');
VIEWstr = num2str(v);
Zstr = num2str(z,'%.3u');
CMstr = num2str(cm);

%Must edit this code to change parameters
InputPath = [pwd '/Heatshock_cycb11_38_After_shock_1_G4(' num2str(t) ')_v' VIEWstr 'z' num2str(z+offset,'%.2u') 'c' CMstr '_ORG.tif'];
OutputPath = [pwd '/TM' TMstr '_CM' CMstr '_Z' Zstr '_v' VIEWstr '.tif'];

%Input first image to get size
Iinit = imread(InputPath);
s = size(Iinit);
I = zeros(s(1),s(2),numZ);

%Take in images to RAM
for z = 1:numZ
    Zstr = num2str(z+offset,'%.2u');
    InputPath = [pwd '/Heatshock_cycb11_38_After_shock_1_G4(' num2str(t) ')_v' VIEWstr 'z' num2str(z+offset,'%.2u') 'c' CMstr '_ORG.tif'];
    I(:,:,z) = im2double(imread(InputPath));
end
% I = spreadPixelRange(I); %Spreads the pixel range to 0-1.
I = interp3DIm(I,interpN,'none');

for z = 1:numZ*interpN
    Zstr = num2str(z,'%.3u');
    OutputPath = [pwd '/TM' TMstr '_CM' CMstr '_Z' Zstr '_v' VIEWstr '.tif'];
    imwrite(I(:,:,z),OutputPath);
end
%%
%Included for 3D images
spm = 4;
z = 1;
v = 1;
t = 3;
cm = 1;

SPMstr = num2str(spm,'%.2u');
TMstr = num2str(t,'%.4u');
VIEWstr = num2str(v);
Zstr = num2str(z,'%.3u');
CMstr = num2str(cm);
for z = 1:numZ*interpN
    OutputPath = [pwd '/TM' TMstr '_CM' CMstr '_3D.tif'];
    imwrite(I(:,:,z),OutputPath,'writemode','append');
end

%%
%Getting information from the user
clear all
spm = input('What is the specimen number? ');
tmStart = input('Which time stamp do you want to be evaluated first? ');
tmEnd = input('Which time stamp do you want to be evaluated last? ');
TH = zeros(tmEnd-tmStart+1,1);
for t=tmStart:tmEnd
    TH(t) = input(['What is the 8 bit threshold of the GFP activity for time ' num2str(t) '? '])/255;
end
xPix = input('What is the pixel distance in microns for the x and y directions? ');
yPix = xPix;
zPix = input('What is the pixel distance in microns for the z direction? ');
xyratz = zPix/xPix;
save('data_config');
%%
%This section looks at each set of GFP images, segments the regions
mkdir 3D_SEG
load('data_config');
disp('Segmenting GFP cluster information');
clInfo = []; %Holds the information concerning the activity location 
zStacks = zeros(tmEnd-tmStart+1,3);
timeArray = zeros(tmEnd-tmStart+1,2);

sigma = 8;

for t=tmStart:tmEnd
    t
    tmStr = num2str(t,'%.4u'); %Create a new directory to put the segmented images in
    mkdir([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/TM' tmStr]);
    
    [I,zNum] = microImInputRaw(spm,t,1,1); %Get the images
    zStacks(t,:) = [size(I,1) size(I,2) zNum];
    [Ireg,CL] = gseg3(I,TH(t),sigma,xyratz); %Segment the regions
    CLnum = size(CL);
    clInfo = [clInfo; CL zeros(CLnum(1),1)+t];
    timeArray(t,:) = [size(clInfo,1)-size(CL,1)+1 size(clInfo,1)];
    for z=1:zStacks(t,3)
        imwrite(Ireg(:,:,z),[pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/TM' tmStr '/SEG_IM.tif'],'writemode','append');
    end
end
save([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/cell_location_information'],'clInfo','timeArray');
save('zStacks','zStacks');
%%
%This section obtains the shape information from the image regions
clear all

load('data_config');
load('zStacks');

load([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/cell_location_information']);
sCL = size(clInfo);
shapeInfo = zeros(sCL(1),9);
statsTot = zeros(tmEnd-tmStart-1,4);

disp('Doing mathematical shape representation of each cluster');
for t=tmStart:tmEnd
    t
    timeTot = 0;
    timeTotCount = 0;
    tmStr = num2str(t,'%.4u');
    
    [I,~] = microImInputRaw(spm,t,1,1); %Get the original image
    sI = size(I);
    Ireg = zeros(sI);
    for z=1:sI(3)
        Ireg(:,:,z) = im2double(imread([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/TM' tmStr '/SEG_IM.tif'],z));
    end
    
    for i=1:sCL(1) %Look at each element
        if~(clInfo(i,10)==t) %Don't consider an element when it's not in the current time stamp
            continue;
        end
        secVal = Ireg(clInfo(i,2),clInfo(i,1),clInfo(i,3)); %Get the value of the section from the COM
        tot = 0; %Used to sum up all pixle values in the region to normalize the curve
        totCount = 0;
        for x=clInfo(i,4):clInfo(i,5)
            for y=clInfo(i,6):clInfo(i,7)
                for z=clInfo(i,8):clInfo(i,9)
                    if(Ireg(y,x,z)==secVal)
                        timeTot = timeTot+I(y,x,z);
                        tot = tot+I(y,x,z);
                        timeTotCount = timeTotCount+1;
                        totCount = totCount+1;
                    end
                end
            end
        end
        
        Ex = clInfo(i,1); %All of the expected values
        Ey = clInfo(i,2); 
        Ez = clInfo(i,3);
        Vx = 0; %Variences
        Vy = 0;
        Vz = 0;
        Cxy = 0; %Covariences
        Cxz = 0;
        Cyz = 0;
        
        Ilog = Ireg==secVal; %Used as a mask for the regions
        Ishape = Ilog.*I; 
        y=clInfo(i,6);
        z=clInfo(i,8);
        for x=clInfo(i,4):clInfo(i,5) %Go through them again getting the covarience information            
            for y=clInfo(i,6):clInfo(i,7)                                
                for z=clInfo(i,8):clInfo(i,9)
                    Vx = Vx+((x-Ex)^2)*Ilog(y,x,z); %V(X)
                    Vy = Vy+((y-Ey)^2)*Ilog(y,x,z); %V(Y)
                    Vz = Vz+((z-Ez)^2)*Ilog(y,x,z); %V(Z)
                    Cxy = Cxy+(x-Ex)*(y-Ey)*Ilog(y,x,z); %C(XY)
                    Cxz = Cxz+(x-Ex)*(z-Ez)*Ilog(y,x,z); %C(XZ)
                    Cyz = Cyz+(y-Ey)*(z-Ez)*Ilog(y,x,z); %C(YZ)
                end
            end
        end
        shapeInfo(i,1) = Vx/totCount; %Vx,Vy,Vz,Cxy,Cxz,Cyz
        shapeInfo(i,2) = Vy/totCount;
        shapeInfo(i,3) = Vz/totCount;
        shapeInfo(i,4) = Cxy/totCount;
        shapeInfo(i,5) = Cxz/totCount;
        shapeInfo(i,6) = Cyz/totCount;
        shapeInfo(i,7) = totCount; %Total number of voxels effected
        shapeInfo(i,8) = tot/totCount; %Average voxel intensity
        shapeInfo(i,9) = tot; %Sum of voxel intensities
         
    end
    statsTot(t,:) = [timeTotCount timeTot/timeTotCount timeTot timeTotCount*(2*xPix+zPix)]; %Total voxels effected, total average, total sum
end
mkdir SHAPE_INFO
save([pwd '/SHAPE_INFO/shape_info'],'shapeInfo','statsTot');

%%
%This section finds the root borders from the Brightfield images
clear all
load('data_config');
load('zStacks');
CP = [];
Np = 100;
alpha = 0.1;
beta = 0.1;
We = 250; %500 was used before
It = 1000;

mkdir ROOT_BORDER

for t=tmStart:tmEnd
    disp(['Indicating border segmentation for time stamp ' num2str(t)])
    [I,~] = microImInputRaw(spm,t,2,zStacks(t)); %Take in the brightfield
    [CPtmp,Ibf] = bfBorderInd(I,alpha,beta,We,It,Np,'show',10);
    imwrite(Ibf,[pwd '/ROOT_BORDER/SPM' num2str(spm,'%.2u') '_R_PROJ_TM' num2str(t,'%.4u') '.tif']);
    
    sCont = size(CPtmp);
end

save([pwd '/ROOT_BORDER/Active_Contour_Points_TM' num2str(t,'%.4u')],'CPtmp')
%%
%This section is used for when there are 90 degree views of the specimen
%defined as view 1 and view 2 in the nomenclature.
mkdir ROOT_BORDER
load('data_config')
viewN = input('Enter the number of orthogonal Brightfield views: ');

spm = 1;

for t=tmStart:tmEnd
    t
OutputPath = [pwd '/ROOT_BORDER/AC_Multiview_Info_TM' num2str(t,'%.4u')];

[ACV1,ACV2,ACRAWV1,ACRAWV2] = BorderRec(t,viewN);
save(OutputPath,'ACV1','ACV2','ACRAWV1','ACRAWV2')
end
%%
maxDis = zeros(1,3);
maxDis(1) = input('What is the max shift distance in the x direction? ');
maxDis(2) = input('What is the max shift distance in the y direction? ');
maxDis(3) = input('What is the max shift distance in the z direction? ');

load data_config
load zStacks
%This section takes the points and executes the point matching image
%registration algorithm
CLt0start = 1; %Indices for cell location and contour points
CLtoend = 0;
CPtostart = 1;
CPtoend = 0;
r = 5;

load([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/cell_location_information.mat']); %load the cell location information
% load([pwd '/ROOT_BORDER/Active_Contour_Points.mat']);

sCL = size(clInfo);
timeDiff = tmEnd-tmStart; %How many time points are we looking at?
delSet = zeros(timeDiff,5); %As of right now only looking at the translation

%Find the starting time stamps points
i=CLt0start;
while(clInfo(i,10)==tmStart)
    i=i+1;
end
CLt0end = i-1;

for t=tmStart+1:tmEnd
    t
    minValxz = 1e9;
    disp(['Registering point matching for time ' num2str(t-1) ' to ' num2str(t)]);
    CLt1start = i; %Algorithm on pg. 69 of personal notebook on finding time stamp points
    while(clInfo(i,10)==t && i<sCL(1))
        i=i+1;
    end
    CLt1end = i-1;
    
    CLt0 = clInfo(CLt0start:CLt0end,1:3)'; %All of the t0 COM points
    CLt1 = clInfo(CLt1start:CLt1end,1:3)'; %All of the t1 COM points
    delSet(t-1,1:3) = regPM3D(CLt0,CLt1,r,maxDis,xyratz); %3D point matching image registration
    
    CLt0start = CLt1start; %Next time stamp
    CLt0end = CLt1end;
    
end

mkdir IMAGE_REGISTRATION
save([pwd '/IMAGE_REGISTRATION/delta_set'],'delSet');

%%
%Tracking information
load('zStacks');
load('data_config');
load([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/cell_location_information.mat']); %Get the cell information
load([pwd '/IMAGE_REGISTRATION/delta_set']); %Image registration data

mkdir TRACKING

T = eye(4);
THDist = 40;
i = 1;
s = size(clInfo);

timeArray = zeros(tmEnd-tmStart+1,2); %This holds the time separation info of clInfo 
PC = zeros(s(1),2); %holds the parent/child relationships and their distances

for t=tmStart:tmEnd
    timeArray(t,1) = i; %The beginning pointer of this time stamp
    while(clInfo(i,10)==t && i<s(1))
        i=i+1; %Increment i to continue looking for the end of this time stamp
    end
    if~(i==s(1))
        timeArray(t,2) = i-1;
    else
        timeArray(t,2) = i;
    end
end

i=1;
for t=tmStart:tmEnd-1 %Get the points from the clInfo array
    t0Points = clInfo(timeArray(t,1):timeArray(t,2),1:3)'; %COM points first time point
    t1Points = clInfo(timeArray(t+1,1):timeArray(t+1,2),1:3)'; %COM points second time point
    
    T(1:3,4) = delSet(t,1:3)'; %Transformation matrix
    
    dMat = disMat(t0Points,t1Points,T);
    dSize = size(dMat); %Get the size of the distance matrix
    
    for N=1:dSize(1) %Going through all of the distance matrix
        childI = 0; %Child index
        minDist = 100;
        for M=1:dSize(2)
            if(dMat(N,M)<THDist && abs(t0Points(3,N)-t1Points(3,M))<=abs(T(3,4))+5)
                if(dMat(N,M)<minDist)
                    childI=M;
                    minDist = dMat(N,M);
                end
            end
        end        
        if(childI>0) %We have found a PC relationship
            PC(i,1) = childI+timeArray(t+1)-1;
        else
            PC(i,1)=0;
        end
        i=i+1;
    end
end
for i=1:s(1) %Now find the parents to each 
    found = 0;
    j = 1;
    while(j<=s(1) && ~(PC(j,1)==i))
        j=j+1;
    end
    if~(j>=s(1))
        PC(i,2) = j;
    end
end
save([pwd '/TRACKING/PC_Relationships'],'PC');