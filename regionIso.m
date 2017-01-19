function regionIso( tm, threshold )

Ltm = length(tm); %How many time stamps are there.
regionImageDataFN = './image_data/region_mat_tm';
%imageDataFN = './image_data/imageData';

mkdir Region_Location_Images

for i=1:Ltm
    tmStr = num2str(tm(i)); %String of time stamp
    disp(['Evaluating time stamp ' tmStr ' for region isolation' char(10)]);
    load([regionImageDataFN tmStr '.mat']); %Load image data
    %load([imageDataFN tmStr '.mat']); %Load region data
    sz = size(regionMatrix); %Get the size of the region matrix
    completeRegionMatrix = zeros(sz(1),sz(2),sz(3)); %Stores the region matrix used later
    
    
    for j=1:sz(3)
        disp(['Creating region image for z-stack ' num2str(j)]);
        tmpMat = zeros(sz(1),sz(2));
        for x = 1:sz(2)
            for y = 1:sz(1)
                if (regionMatrix(y,x,j) > threshold) %Pixels that are above threshold, paint white
                    tmpMat(y,x) = 1;
                end
            end
        end
        completeRegionMatrix(:,:,j) = tmpMat;
        %Write file to an image
        imwrite(completeRegionMatrix(:,:,j),['./Region_Location_Images/TM' tmStr '_STK' num2str(j) '_Region_Location.tif']);
    end
    disp(['Saving region data for tm ' tmStr char(10)]);
    save(['complete_region_mat_tm' tmStr '.mat']); %Save region data
    
    
end



end

