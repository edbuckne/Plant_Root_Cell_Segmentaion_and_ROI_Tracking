function imageData = microImInput( spm, tm, num, CM )
%Takes in .tif files and creates .mat files in a folder called "image_data"
% with the microscopy image data.
SD_DIST = 5;
FILT_PARAM = 10;

mkdir image_data
Ltm = length(tm);
h = fspecial('disk',FILT_PARAM);

for j=1:Ltm
    %Variables
    spmStr = num2str(spm); %Turns specimen number into a string
    tmStr = num2str(tm(j)); %Turns time number into a string
    saveFileName = ['./image_data/imageData' tmStr '.mat']; %File names as will be saved
    fileNameWB = './normalized/SPM0x/TM000x/SPM0x_TM000x_CM02_CHN00.corrected.tif'; %Location of .tif files
    fileNameGFP = './normalized/SPM0x/TM000x/SPM0x_TM000x_CM01_CHN00.corrected.tif';
    fileNameProj = './normalized/SPM0x/TM000x/SPM0x_TM000x_CM01_CHN00_xyProjection.corrected.tif';
    
    %Variable Calculations
    digits = log(tm(j))/log(10); %This does a round down opperation
    digitInt = uint8(digits-0.5)+1;
    fileNameWB = [fileNameWB(1:17) spmStr fileNameWB(19:25-digitInt) tmStr fileNameWB(26:30) spmStr fileNameWB(32:38-digitInt) tmStr fileNameWB(39:end)]; %Inserts parameter information
    fileNameGFP = [fileNameGFP(1:17) spmStr fileNameGFP(19:25-digitInt) tmStr fileNameGFP(26:30) spmStr fileNameGFP(32:38-digitInt) tmStr fileNameGFP(39:end)];
    fileNameProj = [fileNameProj(1:17) spmStr fileNameProj(19:25-digitInt) tmStr fileNameProj(26:30) spmStr fileNameProj(32:38-digitInt) tmStr fileNameProj(39:end)];
    
    %Read the first image to get a size measurement
    IC2=imread(fileNameWB, 1); %Wide-band image read
    szI = size(IC2); %Size of image
    
    IC1array = zeros(szI(1),szI(2),num); %Create blank image arrays for each camera
    IC2array = zeros(szI(1),szI(2),num);
    
    %Take in all .tif files
    for i=1:num
        IC1array(:,:,i)=im2double(imread(fileNameGFP, i)); %GFP image read
        IC2array(:,:,i)=im2double(imread(fileNameWB, i)); %Wide-band image read
        disp(['Reading... stack ' num2str(i)]); %Displays to the user the status of each picture
    end
    %Obtain the projection image to make the image mask
    projIm = imfilter(im2double(imread(fileNameProj)),h,'replicate');
    avgMI = mean(mean(projIm));
    SDMI = sqrt(var(var(projIm)));
    maskTH = avgMI-(SD_DIST*SDMI);
    maskIm = im2bw(projIm,maskTH);
    
    disp(['Saving Time stamp ' tmStr ' image data']);
    
    %save(saveFileName,'IC1array','IC2array','maskIm');
    if (CM==1)
        imageData = IC1array;
    elseif (CM==2)
        imageData = IC2array;
    else
        error('Please indicate either 1 or 2 for camera option');
    end
end
end