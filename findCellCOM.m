function CELL_ARRAY = findCellCOM( tm )
%Finds cells and prints images of them
CELL_ARRAY = []; %Cell Location matrix originally blank

Ltm = length(tm); %How many time stamps are there.
imageDataFN = './image_data/imageData';
mkdir Cell_Location_Images

%Load all of the image data
for i=1:Ltm
    tmStr = num2str(tm(i)); %Turn time stamp numbers to strings for printing
    disp(['Evaluating time stamp ' tmStr ' for cell location']);
    load([imageDataFN tmStr '.mat']); %Load image data
    sz = size(IC2array); %Gets the 3 demension size of the image data
    regionMatrix = zeros(sz(1),sz(2),sz(3)); %Stores the region matrix used later
    
    for j=1:sz(3)
        disp(['Evaluating z-stack ' num2str(j)]);
        I = IC2array(:,:,j); %Take in one image at a time
        
        h = fspecial('disk',8); %Filter the image
        I2 = imfilter(I,h,'replicate');
        
        I3 = maskIm.*equalizeLocal(I2); %Function sets up cell location and region finding
        regionMatrix(:,:,j) = I3;
        
        BW = 1.00 - imregionalmax(I3); %Find maxes/cells
        %X, Y, Z, TM
        %RGBGrey = zeros(sz(1),sz(2),3);
        %RGBGrey(:,:,1)=I; RGBGrey(:,:,2)=I; RGBGrey(:,:,3)=I; %Needs to be in this format for mergeCells function
        
        for x = 1:sz(2)
            for y = 1:sz(1)
                if (~(BW(y,x)==0))
                else
                    CELL_ARRAY = [CELL_ARRAY; x y j i]; %If a maximum has been put there, say this is a cell
                end
            end
        end
%         I4 = mergeOrig(RGBGrey, CELL_ARRAY); %Merge cell locations on to the original image
%         imwrite(I4, ['./Cell_Location_Images/TM' tmStr '_STK' num2str(j) '_Cell_Location.tif']);
    end
%     save(['./image_data/region_mat_tm' num2str(i) '.mat'],'regionMatrix'); %Save region matrix data
end

end

