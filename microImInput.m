function microImInput( spm, tm, num )
%Takes in .tif files and creates .mat files in a folder called "image_data"
% with the microscopy image data.

mkdir image_data
Ltm = length(tm);

for j=1:Ltm
    %Variables
    spmStr = num2str(spm); %Turns specimen number into a string
    tmStr = num2str(tm(j)); %Turns time number into a string
    saveFileName = ['./image_data/imageData' tmStr '.mat']; %File names as will be saved
    fileStrings = '01020304050607080910111213141516171819202122232425262728293031323334353637383940'; %Used for z stack notations
    fileNameWB = './SPM0x/TM000x/SPM0x_TM000x_CM2_CHN00_PLNxx.tif'; %Location of .tif files
    fileNameGFP = './SPM0x/TM000x/SPM0x_TM000x_CM1_CHN00_PLNxx.tif';
    
    %Variable Calculations
    digits = log(tm(j))/log(10); %This does a round down opperation
    digitInt = uint8(digits-0.5)+1;
    fileNameWB = [fileNameWB(1:6) spmStr fileNameWB(8:14-digitInt) tmStr fileNameWB(15:19) spmStr fileNameWB(21:27-digitInt) tmStr fileNameWB(28:end)]; %Inserts parameter information
    fileNameGFP = [fileNameGFP(1:6) spmStr fileNameGFP(8:14-digitInt) tmStr fileNameGFP(15:19) spmStr fileNameGFP(21:27-digitInt) tmStr fileNameGFP(28:end)];
    
    %Read the first image to get a size measurement
    newFile = [fileNameWB(1:41) fileStrings(1*2-1) fileStrings(1*2) fileNameWB(44:end)];
    IC2=imread(newFile); %Wide-band image read
    szI = size(IC2); %Size of image
    
    IC1array = zeros(szI(1),szI(2),num); %Create blank image arrays for each camera
    IC2array = zeros(szI(1),szI(2),num);
    
    %Take in all .tif files
    for i=1:num
        newFile = [fileNameGFP(1:41) fileStrings(i*2-1) fileStrings(i*2) fileNameGFP(44:end)];
        IC1array(:,:,i)=im2double(imread(newFile)); %GFP image read
        newFile = [fileNameWB(1:41) fileStrings(i*2-1) fileStrings(i*2) fileNameWB(44:end)];
        IC2array(:,:,i)=im2double(imread(newFile)); %Wide-band image read
        disp(['Reading...' newFile(16:end)]); %Displays to the user the status of each picture
    end
    disp(['Saving Time stamp ' tmStr ' image data to file']);
    
    save(saveFileName,'IC1array','IC2array');
end
end