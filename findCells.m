function cellLoc = findCells( spm, tm, num )
cellLoc = zeros(800,3,num);

spmStr = num2str(spm); %Turns specimen number into a string
tmStr = num2str(tm); %Turns time number into a string

digits = log(tm)/log(10); %This does a round down opperation
digitInt = uint8(digits-0.5)+1;

fileStrings = '01020304050607080910111213141516171819202122232425262728293031323334353637383940';
fileNameWB = 'SPM0x_TM000x_CM2_CHN00_PLNxx.tif';
fileNameGFP = 'SPM0x_TM000x_CM1_CHN00_PLNxx.tif';

fileNameWB = [fileNameWB(1:4) spmStr fileNameWB(6:12-digitInt) tmStr fileNameWB(13:end)];
fileNameGFP = [fileNameGFP(1:4) spmStr fileNameGFP(6:12-digitInt) tmStr fileNameGFP(13:end)];

dataWidth = 20;
agressive = 12;
mkdir cell_segmentation

for i=1:num
    newFile = [fileNameWB(1:26) fileStrings(i*2-1) fileStrings(i*2) fileNameWB(29:32)];
    WBim=imread(newFile); %Wide-band image read
    newFile = [fileNameGFP(1:26) fileStrings(i*2-1) fileStrings(i*2) fileNameGFP(29:32)];
    GFPim=imread(newFile); %GFP image read
    disp(['Reading...' newFile]); %Displays to the user the status of each picture
    
    WBimC = histeq(WBim); %Contrasts the image
    WBimC2 = wiener2(WBimC,[agressive agressive]); %Uses a wiener filtering algorithm for the picture
    redWBimC = greyToRGB(WBimC2,1,'inv'); %Creates an inverted red image of the wide-band image
    greenGFPim = greyToRGB(GFPim,2,'inv'); %Creates an inverted green image of the GFP image
    [boundIm,cellLocation] = drawBounds(redWBimC,dataWidth,0); %Draws the boundaries on the red wideband image
    orig=greyToRGB(WBim,1,'reg'); %Use the original image to create a red image of it
    J = mergeOrig(orig,cellLocation); %Plots the cells in their location
    mergedImage = mergeCellIms(J,greenGFPim,0.85); %Merges the two images
    
    imwrite(mergedImage,['./cell_segmentation/' newFile]) %Creates a tif image in the cellSegmentation folder
    disp([newFile ' Finished']); %Displays to the user the status of each picture
    szCL = size(cellLocation);
    cellLoc(1:szCL(1),1:szCL(2),i)=cellLocation;
end
disp('Cell segmentation complete');
end

