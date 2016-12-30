function findCells( num )
cellLoc = zeros(800,3,num);

fileStrings = '01020304050607080910111213141516171819202122232425262728293031323334353637383940';
fileNameWB = 'SPM01_TM0001_CM2_CHN00_PLNxx.tif';
fileNameGFP = 'SPM01_TM0001_CM1_CHN00_PLNxx.tif';

dataWidth = 20;
mkdir cell_segmentation

for i=1:num
    newFile = [fileNameWB(1:26) fileStrings(i*2-1) fileStrings(i*2) fileNameWB(29:32)];
    WBim=imread(newFile); %Wide-band image read
    newFile = [fileNameGFP(1:26) fileStrings(i*2-1) fileStrings(i*2) fileNameGFP(29:32)];
    GFPim=imread(newFile); %GFP image read
    disp(['Reading...' newFile]); %Displays to the user the status of each picture
    
    WBimC = histeq(WBim); %Contrasts the image
    WBimC2 = wiener2(WBimC,[20 20]); %Uses a wiener filtering algorithm for the picture
    redWBimC = greyToRGB(WBimC2,1,'inv'); %Creates an inverted red image of the wide-band image
    greenGFPim = greyToRGB(GFPim,2,'inv'); %Creates an inverted green image of the GFP image
    [boundIm,cellLocation] = drawBounds(redWBimC,dataWidth,0); %Draws the boundaries on the red wideband image
    orig=greyToRGB(WBim,1,'reg'); %Use the original image to create a red image of it
    J = mergeOrig(orig,cellLocation); %Plots the cells in their location
    mergedImage = mergeCellIms(J,greenGFPim,0.85); %Merges the two images
    
    imwrite(mergedImage,['./cell_segmentation/' newFile]) %Creates a tif image in the cellSegmentation folder
    disp([newFile ' Finished']); %Displays to the user the status of each picture
end
disp('Cell segmentation complete');
end

