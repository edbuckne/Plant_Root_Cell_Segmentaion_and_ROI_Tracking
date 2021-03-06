function [ OUT_MATRIX, rgbTest ] = cellLocationInfo2D( SPM, TM, STACKS, CM, OPT, I3D, I_PROJ, TH_VAL )
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
%       5. OPT - OPTions
%           > 'print' - prints out images of the segmentation and cell
%           center of mass sections.
%   Output:
%       1. OUT_MATRIX - matrix that posesses the cell location information

%Variables
OUT_MATRIX = [];
SD_DIST = 5;
ID = 1;
ADD_INDEX = 0;
if(CM==1)
    h = fspecial('disk',10);
else
    h = fspecial('disk',8);
end
h2 = fspecial('disk',6);
%fileNameProj = './normalized/SPM0x/TM000x/SPM0x_TM000x_CM01_CHN00_xyProjection.corrected.tif';
%Idata1 = microImInput(SPM,TM,STACKS,1);

% if(strcmp(OPT1,'z')||strcmp(OPT1,'int'))
%     if(CM==1)
%         fileName = './normalized/SPM0x/TM000x/SPM0x_TM000x_CM01_CHN00.corrected.tif'; %Location of .tif files
%         h = fspecial('disk',10);
%     elseif (CM==2)
%         fileName = './normalized/SPM0x/TM000x/SPM0x_TM000x_CM02_CHN00.corrected.tif'; %Location of .tif files
%     else
%         error('Please enter either a 1 or 2 for the camera OPTion');
%     end
% elseif(strcmp(OPT1,'y'))
%     fileName = './xz_images/xz_TM';
%     if(~(CM==1))
%         error('y stack OPTion much have the camera 1 OPTion');
%     else
%         h = fspecial('disk',4);
%     end
% else
% end

printOPT = strcmp(OPT,'print');
mkdir segmentation

    disp(['Evaluating time stamp ' num2str(TM)]);
    
% %     if(strcmp(OPT1,'z')||strcmp(OPT1,'int')) %Z stack OPTion
%         digits = log(t)/log(10); %Creates a new file name for each time stamp
%         digitInt = uint8(digits-0.5)+1;
%         fileName = [fileName(1:17) spmStr fileName(19:25-digitInt) tmStr fileName(26:30) spmStr fileName(32:38-digitInt) tmStr fileName(39:end)]; %Inserts parameter information
%         fileNameProj = [fileNameProj(1:17) spmStr fileNameProj(19:25-digitInt) tmStr fileNameProj(26:30) spmStr fileNameProj(32:38-digitInt) tmStr fileNameProj(39:end)];
        
        
        %Create the mask image
        I_PROJ = imfilter(histeq(I_PROJ),h,'replicate');
%         avgMI = mean(mean(I_PROJ));
%         SDMI = sqrt(var(var(I_PROJ)));
%         maskTH = avgMI-(SD_DIST*SDMI);
        maskIm = im2bw(I_PROJ,0.3);
        
        %Read the first image to get a size measurement
        Itmp=I3D(:,:,1);
        s = size(Itmp); %Size of image
%     elseif(strcmp(OPT1,'y')) %Y stack OPTion
%         fileName = [fileName(1:17) tmStr '.tif'];
%         
%         %Read the first image to get a size measurement
%         Itmp=imread(fileName, 1); %Image read
%         s = size(Itmp); %Size of image
%         maskIm = zeros(s(1),s(2))+1;
%     end
    
    
    
    
    for z=1:STACKS %Each z stack
        
        %Take in the new image to work with
        I = I3D(:,:,z);
        if(CM==1)
            I = imfilter(I,h,'replicate');
        end
        
        
        
        
        
        %Runs the LEE and watershed segmentation algorithms
        [I1r, I2r] = partitionImage2D(I,'row',1);
        [I1c, I2c] = partitionImage2D(I,'col',1);
        I2 = I2r.*I2c;
        I2 = imfilter(I2,h2,'replicate');
        [I1r, I2r] = partitionImage2D(I2,'row',1);
        [I1c, I2c] = partitionImage2D(I2,'col',1);
        I2 = I2r.*I2c;
        I22 = imfilter(I2,h2,'replicate');
        I3 = I2.*maskIm;
        if(CM==1) %Special if GFP channel
            th_image = im2bw(I,TH_VAL);
            I2r = I2r.*th_image;
            I2c = I2c.*th_image;
            I3 = I3.*th_image;
        elseif(CM==2) %Special if Brightfield channel
            I4 = im2double(watershed(1-I22));
            maxP = max(I4(:));
            I5 = im2bw(I4./maxP,0.001);
            Ilog = I5;%.*im2bw(imfilter(I3,h,'replicate'),TH_VAL);
        end
        
        
        
        
        
        
        %Finds the cells COM by finding the pixels that have a value of 1
        binImage = zeros(s);
        cLoc = zeros(100000,2);
        i=1;
        for x=1:s(2)
            for y=1:s(1)
                if (I3(y,x)>=0.9999)
                    cLoc(i,:) = [x y];
                    binImage(y,x) = 1;
                    i=i+1;
                end
            end
        end
        cLoc = cLoc(1:i-1,:);
        s2 = size(cLoc); %Finds how many cells were found
        I2r = I2r.*maskIm;
        I2c = I2c.*maskIm;
        
        disp(['Finding partitioning data and cell location data for z stack ' num2str(z)]);
        
        

        
        
        

            rgbTest = zeros(s(1),s(2),3);
            rgbTest(:,:,1) = I.*maskIm; rgbTest(:,:,2) = I.*maskIm; rgbTest(:,:,3) = I.*maskIm;

        %Purge out the false positives
        testIm = zeros(s(1),s(2));
        for i=1:s2(1)
            if(CM==1) %Segmenting the GFP channel
                %If the cell location is in a region, ignore it and continue
                OUT_MATRIX = [OUT_MATRIX; zeros(1,9)];
                if(testIm(cLoc(i,2),cLoc(i,1))==1)%||Idata1(cLoc(i,2),cLoc(i,1),z)<TH_VAL)
                    continue
                end
                OUT_MATRIX(i+ADD_INDEX,1:2) = [ID TM];
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
            elseif(CM==2) %Special for camera 2
                OUT_MATRIX = [OUT_MATRIX; zeros(1,9)];
                if(testIm(cLoc(i,2),cLoc(i,1))==1)
                    continue
                end
                OUT_MATRIX(i+ADD_INDEX,1:2) = [ID TM];
                OUT_MATRIX(i+ADD_INDEX,5) = z;
                ID = ID+1;
                X = cLoc(i,1);
                Y = cLoc(i,2);
                OUT_MATRIX(i+ADD_INDEX,3:4) = [X Y];

                [~,OUT_MATRIX(i+ADD_INDEX,8)]=findRegion(Ilog,X,Y,1);
                [~,OUT_MATRIX(i+ADD_INDEX,9)]=findRegion(Ilog,X,Y,2);
                [OUT_MATRIX(i+ADD_INDEX,6),~]=findRegion(Ilog,X,Y,3);
                [OUT_MATRIX(i+ADD_INDEX,7),~]=findRegion(Ilog,X,Y,4);
            end
            
            R = OUT_MATRIX(i+ADD_INDEX,6);
            L = OUT_MATRIX(i+ADD_INDEX,7);
            T = OUT_MATRIX(i+ADD_INDEX,8);
            B = OUT_MATRIX(i+ADD_INDEX,9);
            dimRows = B-T;
            dimCols = R-L;
            testIm(T:B,L:R) = zeros(dimRows+1,dimCols+1)+1;
            
            
            if (printOPT)
%                 rgbTest(T:B,L,1) = zeros(dimRows+1,1)+1; %Left Line
%                 rgbTest(T:B,R,1) = zeros(dimRows+1,1)+1; %Right Line
%                 rgbTest(T,L:R,1) = zeros(1,dimCols+1)+1; %Top Line
%                 rgbTest(B,L:R,1) = zeros(1,dimCols+1)+1; %Bottom Line
%                 rgbTest(T:B,L,2) = zeros(dimRows+1,1); %Left Line
%                 rgbTest(T:B,R,2) = zeros(dimRows+1,1); %Right Line
%                 rgbTest(T,L:R,2) = zeros(1,dimCols+1); %Top Line
%                 rgbTest(B,L:R,2) = zeros(1,dimCols+1); %Bottom Line
%                 rgbTest(T:B,L,3) = zeros(dimRows+1,1); %Left Line
%                 rgbTest(T:B,R,3) = zeros(dimRows+1,1); %Right Line
%                 rgbTest(T,L:R,3) = zeros(1,dimCols+1); %Top Line
%                 rgbTest(B,L:R,3) = zeros(1,dimCols+1); %Bottom Line
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
        

        if (printOPT)
            %imwrite(rgbTest,['./segmentation/SEG_CM' num2str(CM) '_TM' num2str(t) '.tif'],'WriteMode','Append');
            imwrite(rgbTest,['./segmentation/SEG_CM' num2str(CM) '_TM' num2str(TM) num2str(z) '.PNG']);
        end
        
        if(s2(1)>0)
            ADD_INDEX = ADD_INDEX+i;
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
