function [ BFCL ] = cellLocationInfo2DBF( SPM, TM, STA, ACT_LOC )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
SD_DIST = 5;
TH = 0.15;
MAX_DIS = 5;

I1 = microImInput(SPM,TM,STA,1);
I2 = microImInput(SPM,TM,STA,2); %Take in images
h = fspecial('disk',8);

%Creating the mask image
fileNameProj = './normalized/SPM0x/TM000x/SPM0x_TM000x_CM01_CHN00_xyProjection.corrected.tif';
digits = log(TM)/log(10);
digitInt = uint8(digits-0.5)+1;
fileNameProj = [fileNameProj(1:17) num2str(SPM) fileNameProj(19:25-digitInt) num2str(TM) fileNameProj(26:30) num2str(SPM) fileNameProj(32:38-digitInt) num2str(TM) fileNameProj(39:end)];        Iproj = imfilter(im2double(imread(fileNameProj)),h,'replicate');
avgMI = mean(mean(Iproj));
SDMI = sqrt(var(var(Iproj)));
maskTH = avgMI-(SD_DIST*SDMI);
maskIm = im2bw(Iproj,maskTH);

sim = size(I2); %Find the size of the image and the location data
sd = size(ACT_LOC);
BFCL = []; %Brightfield cell location info matrix

ALI = 1; %Activity location index
CLI = 1; %Cell location index
for z=1:sim(3) %Let's go through each z stack, one at a time
    disp(['Locating cellular activity in brightfield channel for z stack ' num2str(z)]);
    %Perform the LEE algorithm on each image
    I = I2(:,:,z);
    [~, I2r] = partitionImage2D(I,'row');
    [~, I2c] = partitionImage2D(I,'col');
    I2o = I2r.*I2c;
    I2o = imfilter(I2o,h,'replicate');
    [~, I2r] = partitionImage2D(I2o,'row');
    [~, I2c] = partitionImage2D(I2o,'col');
    I2o = I2r.*I2c;
    I3 = I2o.*maskIm;
    
    while(ACT_LOC(ALI,5)<=z) %As long as we are talking about this z-stack
        
        if(ACT_LOC(ALI,5)==0) %If the location info is a false positive
            ALI = ALI+1; %Increase the index
            if(ALI<sd(1)) %If we are still within the constraints of the location list
                continue;
            else
                break;
            end
        end
        %Get the brightfield super pixel
        R = ACT_LOC(ALI,6);
        L = ACT_LOC(ALI,7);
        T = ACT_LOC(ALI,8);
        B = ACT_LOC(ALI,9);
        
        for x=L:R %Go through the super pixel looking for peaks
            for y=T:B
                if(I3(y,x)==1) %look for cell locations
                    BFCL = [BFCL; CLI TM x y z 0 0 0 0];
                    CLI = CLI+1;
                end
            end
        end
        
        %Getting rid of false positives (NEW NEW NEW NEW)
        if(CLI>1)
            PTR = CLI-1; %Pointer to look through and get rid of false positives
        else
            PTR = 1;
        end
        
        while(BFCL(PTR,5)==z&&PTR>0) %While we are looking at the right stack and haven't gone out of bounds
            if(PTR>1)
                D_PTR = PTR-1; %Dynamic (Moving) pointer
            else
                break;
            end
            while(BFCL(D_PTR,5)==z&&D_PTR>0) %While we are looking at the right stack and haven't gone out of bounds
                x1 = BFCL(PTR,3);
                y1 = BFCL(PTR,4);
                x2 = BFCL(D_PTR,3);
                y2 = BFCL(D_PTR,4);
                COMDist = sqrt((x1-x2)^2+(y1-y2)^2);
                if(COMDist<MAX_DIS) %If those two points are really close together, get rid of one
                    BFCL(PTR,:)=[0 0 0 0 0 0 0 0 0];
                end
                D_PTR=D_PTR-1;
                if(D_PTR==0) %Break if we get to the end
                    break;
                end
            end
            PTR=PTR-1;
        end
        
        %Increase index and break if index exceeds the list
        ALI = ALI+1;
        if (ALI>sd(1))
            break;
        end
    end
    if (ALI>sd(1)) %Break if we have exceeded the index
        break;
    end
    ALI = ALI-1;
    if (ALI==0)
        ALI = 1;
    end
end
%This will be a function call to segment the cell areas.
%Inputs
% BFCL = BFCL;
% I2 = I2;

%Variables
filterCoeff = 8;
TH = 0.2;
PDist = 0.1; %Pixel distance

s = size(BFCL); %Get the size of the cell location matrix
sim = size(I2); %Get the size of the 3D image data of the brightfield channel
h=fspecial('disk',filterCoeff);

i = 1; %Index pointer
disp(['Segmenting cells that indicate GFP activity']);
for z=1:sim(3) %Go through each z stack
    %Perform the LEE algorithm on each image
    I = I2(:,:,z);
    [~, I2r] = partitionImage2D(I,'row');
    [~, I2c] = partitionImage2D(I,'col');
    I2o = I2r.*I2c;
    I2o = imfilter(I2o,h,'replicate');
    [~, I2r] = partitionImage2D(I2o,'row');
    [~, I2c] = partitionImage2D(I2o,'col');
    I2o = I2r.*I2c;
    I2o = imfilter(I2o,h,'replicate');
    I2th = im2bw(I2o,TH);
    I2rz = im2bw(I2r,0.01);
    I2cz = im2bw(I2c,0.01);
    Ilog = I2rz.*I2cz;
    %     figure
    %     imshow(Ilog);
    
    Imask = zeros(sim(1),sim(2)); %For each z-stack create a mask image to keep track of segmented areas
    
    for j=i:s(1) %Starting at beginning of stack, look until you see a new z-stack
        disp([num2str(j/s(1).*100,'%2.1d') ' Percent segmented']);
        if(BFCL(j,5)>z) %If we get to the next z stack, exit
            i=j; %Point i to the beginning of the next z-stack
            break;
        end
        X = BFCL(j,3); %Get the coordinate of the region of interest
        Y = BFCL(j,4);
        [~,T]=findRegion(Ilog,X,Y,1);
        [~,B]=findRegion(Ilog,X,Y,2);
        [R,~]=findRegion(Ilog,X,Y,3);
        [L,~]=findRegion(Ilog,X,Y,4);
        BFCL(j,6:9)=[R L T B];
    end
end

end

