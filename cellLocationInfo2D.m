function [ OUT_MATRIX ] = cellLocationInfo2D( SPM, TM, STACKS, CM, PLANE, OPT, A )
%cellLocationInfo takes in the specimen number, time array, and the number
%of z stacks.  It find the cell location information for 2 dimensions.
%This includes the following columns:
%   1. Cell identifier
%   2. Time stamp
%   3. Cell location x
%   4. Cell location y
%   5. Cell location z
%   6. Right boundary
%   7. Left boundary
%   8. Top boundary
%   9. Bottom boundary
%The function takes in 4 inputs and puts out 1 output
%   Inputs:
%       1. SPM - specimen number (1, 2, 3, etc.)
%       2. TM - time vector (1:43, 3:12, 40:43, etc.)
%       3. STACKS - number of z stacks found in the data (43, 40, etc.)
%       4. CM - camera type (1 or 2)
%       5. OPT - options
%           > 'print' - prints out images of the segmentation and cell
%           center of mass sections.
%   Output:
%       1. OUT_MATRIX - matrix that posesses the cell location information

%Variables
OUT_MATRIX = [];
SD_DIST = 5;
ID = 1;
ADD_INDEX = 0;
TH_VAL = 0.15;
h = fspecial('disk',8);
h2 = fspecial('disk',4);
fileNameProj = './normalized/SPM0x/TM000x/SPM0x_TM000x_CM01_CHN00_xyProjection.corrected.tif';
%Idata1 = microImInput(SPM,TM,STACKS,1);

if(strcmp(PLANE,'z')||strcmp(PLANE,'int'))
    if(CM==1)
        fileName = './normalized/SPM0x/TM000x/SPM0x_TM000x_CM01_CHN00.corrected.tif'; %Location of .tif files
        h = fspecial('disk',10);
    elseif (CM==2)
        fileName = './normalized/SPM0x/TM000x/SPM0x_TM000x_CM02_CHN00.corrected.tif'; %Location of .tif files
    else
        error('Please enter either a 1 or 2 for the camera option');
    end
elseif(strcmp(PLANE,'y'))
    fileName = './xz_images/xz_TM';
    if(~(CM==1))
        error('y stack option much have the camera 1 option');
    else
        h = fspecial('disk',4);
    end
else
end

Ltm = length(TM); %length of time periods
spmStr = num2str(SPM); %Turns specimen number into a string
printOpt = strcmp(OPT,'print');
mkdir segmentation

for t = TM %t=1:Ltm %Each time stamp
    disp(['Evaluating time stamp ' num2str(t)]);
    tmStr = num2str(t); %Turns time number into a string
    
    if(strcmp(PLANE,'z')||strcmp(PLANE,'int')) %Z stack option
        digits = log(t)/log(10); %Creates a new file name for each time stamp
        digitInt = uint8(digits-0.5)+1;
        fileName = [fileName(1:17) spmStr fileName(19:25-digitInt) tmStr fileName(26:30) spmStr fileName(32:38-digitInt) tmStr fileName(39:end)]; %Inserts parameter information
        fileNameProj = [fileNameProj(1:17) spmStr fileNameProj(19:25-digitInt) tmStr fileNameProj(26:30) spmStr fileNameProj(32:38-digitInt) tmStr fileNameProj(39:end)];
        
        
        %Create the mask image
        Iproj = imfilter(im2double(imread(fileNameProj)),h,'replicate');
        avgMI = mean(mean(Iproj));
        SDMI = sqrt(var(var(Iproj)));
        maskTH = avgMI-(SD_DIST*SDMI);
        maskIm = im2bw(Iproj,maskTH);
        
        %Read the first image to get a size measurement
        Itmp=imread(fileName, 1); %Image read
        s = size(Itmp); %Size of image
    elseif(strcmp(PLANE,'y')) %Y stack option
        fileName = [fileName(1:17) tmStr '.tif'];
        
        %Read the first image to get a size measurement
        Itmp=imread(fileName, 1); %Image read
        s = size(Itmp); %Size of image
        maskIm = zeros(s(1),s(2))+1;
    end
    
    for z=1:STACKS %Each z stack
        if(strcmp(PLANE,'int'))
            I=A(:,:,z);
        else
            I = im2double(imread(fileName,z));
        end
        if(CM==1)
            I = imfilter(I,h,'replicate');
        end
        
        %Runs the LEE algorithm
        [I1r, I2r] = partitionImage2D(I,'row',1);
        [I1c, I2c] = partitionImage2D(I,'col',1);
        I2 = I2r.*I2c;
        I2 = imfilter(I2,h,'replicate');
        [I1r, I2r] = partitionImage2D(I2,'row',1);
        [I1c, I2c] = partitionImage2D(I2,'col',1);
        I2 = I2r.*I2c;
        I3 = I2.*maskIm;
        %For GFP channel threshold before everything else
        if(CM==1)
            th_image = im2bw(I,TH_VAL);
            I2r = I2r.*th_image;
            I2c = I2c.*th_image;
            I3 = I3.*th_image;
        end
        
        %Finds the cells COM by finding the pixels that have a value of 1
        binImage = zeros(s);
        cLoc = [];
        for x=1:s(2)
            for y=1:s(1)
                if (I3(y,x)>=0.9999)
                    cLoc = [cLoc; x y];
                    binImage(y,x) = 1;
                end
            end
        end
        
        
        s2 = size(cLoc); %Finds how many cells were found
        I2r = I2r.*maskIm;
        I2c = I2c.*maskIm;
        
        disp(['Finding partitioning data and cell location data for z stack ' num2str(z)]);
        
        if (printOpt)
            rgbTest = zeros(s(1),s(2),3);
            rgbTest(:,:,1) = I.*maskIm; rgbTest(:,:,2) = I.*maskIm; rgbTest(:,:,3) = I.*maskIm;
        end
        %Purge out the false positives
        testIm = zeros(s(1),s(2));
        for i=1:s2(1)
            %If the cell location is in a region, ignore it and continue
            OUT_MATRIX = [OUT_MATRIX; zeros(1,9)];
            if(testIm(cLoc(i,2),cLoc(i,1))==1)%||Idata1(cLoc(i,2),cLoc(i,1),z)<TH_VAL)
                continue
            end
            OUT_MATRIX(i+ADD_INDEX,1:2) = [ID t];
            OUT_MATRIX(i+ADD_INDEX,5) = z;
            ID = ID+1;
            
            xPt = cLoc(i,1);
            yPt = cLoc(i,2);
            OUT_MATRIX(i+ADD_INDEX,3:4) = [xPt yPt];
            %Horizontal
            %Right side
            while (I2r(yPt,xPt)>0) %&&testIm(yPt,xPt)==0
                xPt=xPt+1;
            end
            OUT_MATRIX(i+ADD_INDEX,6) = xPt;
            xPt = cLoc(i,1);
            %Left side
            while (I2r(yPt,xPt)>0)
                xPt=xPt-1;
            end
            OUT_MATRIX(i+ADD_INDEX,7) = xPt;
            xPt = cLoc(i,1);
            %Vertical
            %Top
            while (I2c(yPt,xPt)>0&&yPt>1)
                yPt=yPt-1;
            end
            OUT_MATRIX(i+ADD_INDEX,8) = yPt;
            yPt = cLoc(i,2);
            %Bottom
            while (I2c(yPt,xPt)>0)
                yPt=yPt+1;
            end
            OUT_MATRIX(i+ADD_INDEX,9) = yPt;
            %Paint the test image
            R = OUT_MATRIX(i+ADD_INDEX,6);
            L = OUT_MATRIX(i+ADD_INDEX,7);
            T = OUT_MATRIX(i+ADD_INDEX,8);
            B = OUT_MATRIX(i+ADD_INDEX,9);
            dimRows = B-T;
            dimCols = R-L;
            testIm(T:B,L:R) = zeros(dimRows+1,dimCols+1)+1;
            if (printOpt)
                rgbTest(T:B,L,1) = zeros(dimRows+1,1)+1; %Left Line
                rgbTest(T:B,R,1) = zeros(dimRows+1,1)+1; %Right Line
                rgbTest(T,L:R,1) = zeros(1,dimCols+1)+1; %Top Line
                rgbTest(B,L:R,1) = zeros(1,dimCols+1)+1; %Bottom Line
                rgbTest(T:B,L,2) = zeros(dimRows+1,1); %Left Line
                rgbTest(T:B,R,2) = zeros(dimRows+1,1); %Right Line
                rgbTest(T,L:R,2) = zeros(1,dimCols+1); %Top Line
                rgbTest(B,L:R,2) = zeros(1,dimCols+1); %Bottom Line
                rgbTest(T:B,L,3) = zeros(dimRows+1,1); %Left Line
                rgbTest(T:B,R,3) = zeros(dimRows+1,1); %Right Line
                rgbTest(T,L:R,3) = zeros(1,dimCols+1); %Top Line
                rgbTest(B,L:R,3) = zeros(1,dimCols+1); %Bottom Line
                CT = OUT_MATRIX(i+ADD_INDEX,4)-2;
                CB = OUT_MATRIX(i+ADD_INDEX,4)+2;
                CL = OUT_MATRIX(i+ADD_INDEX,3)-2;
                CR = OUT_MATRIX(i+ADD_INDEX,3)+2;
                if(CT*CB>0&&CL*CR>0)
                    rgbTest(CT:CB,CL:CR,1)=zeros(5);
                    rgbTest(CT:CB,CL:CR,2)=zeros(5);
                    rgbTest(CT:CB,CL:CR,3)=zeros(5)+1;
                end
            end
        end
        

        if (printOpt)
            imwrite(rgbTest,['./segmentation/SEG_CM' num2str(CM) '_TM' num2str(t) '.tif'],'WriteMode','Append');
        end
        
        if(s2(1)>0)
            ADD_INDEX = ADD_INDEX+i;
        end
    end
end
% s = size(OUT_MATRIX);
% 
% Idata1 = microImInput(SPM,TM,STACKS,1);
% for i=1:s(1)
%     x = OUT_MATRIX(i,3);
%     y = OUT_MATRIX(i,4);
%     z = OUT_MATRIX(i,5);
%     if (x==0)
%         continue;
%     end
%     if (Idata1(y,x,z)<0.15)
%         OUT_MATRIX(i,:) = zeros(1,9);
%     end
% end
end
