function yStacks( SPM, TM, Z_STACKS, CM)

if(CM==1)
    fileName = './normalized/SPM0x/TM000x/SPM0x_TM000x_CM01_CHN00.corrected.tif'; %Location of .tif files
elseif (CM==2)
    fileName = './normalized/SPM0x/TM000x/SPM0x_TM000x_CM02_CHN00.corrected.tif'; %Location of .tif files
else
    error('Please enter either a 1 or 2 for the camera option');
end

Ltm = length(TM); %length of time periods
spmStr = num2str(SPM); %Turns specimen number into a string
mkdir xz_images
savePath = './xz_images/xz_TM'; %Path to save the resulting images

for t = TM %t=1:Ltm %Each time stamp
    disp(['Creating y stacks for time stamp ' num2str(t)]);
    tmStr = num2str(t);
    
    digits = log(t)/log(10); %Creates a new file name for each time stamp
    digitInt = uint8(digits-0.5)+1;
    fileName = [fileName(1:17) spmStr fileName(19:25-digitInt) tmStr fileName(26:30) spmStr fileName(32:38-digitInt) tmStr fileName(39:end)]; %Inserts parameter information
    
    %Read the first image to get a size measurement
    Itmp=imread(fileName, 1); %Image read
    s = size(Itmp); %Size of image
    inImages = zeros(s(1),s(2),Z_STACKS);
    OUT_IMAGES = zeros(Z_STACKS,s(2),s(1)/2);
    
    for z=1:Z_STACKS %Each z stack, take in the images
        inImages(:,:,z) = im2double(imread(fileName,z));
    end
    
    for y=1:2:s(1)
        for z=1:Z_STACKS
            OUT_IMAGES(z,:,y) = inImages(y,:,z); %Create new images
        end
        imwrite(OUT_IMAGES(:,:,y),[savePath tmStr '.tif'],'WriteMode','append');
    end
    disp(['Created ' num2str(s(1)) ' y stacks']);
end

end

