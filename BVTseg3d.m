function BVTseg3d( )
%Highest level function in BVT framework. This function segments regions in
%all 3 dimensional images indicated in the configuration file.  This
%function uses gradient descent and gradient vector convergence principals
%to indicate and segment regions in 3 dimensions.  NOTE: this function
%requires a high capacity of RAM space to complete depending on how large
%the images are.

load('data_config');
disp('Segmenting GFP cluster information');
clInfo = []; %Holds the information concerning the activity location 
zStacks = zeros(tmEnd-tmStart+1,3);
timeArray = zeros(tmEnd-tmStart+1,2);

spm = input('Which specimen do you want to segment? ');
cd(['SPM' num2str(spm,'%.2u')]);
mkdir 3D_SEG

sigma = 2; %Variance used to filter the images

for t=tmStart:tmEnd
    disp(['Time Stamp: ' num2str(t)]);
    tmStr = num2str(t,'%.4u'); %Create a new directory to put the segmented images in
    mkdir([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/TM' tmStr]);
    
    [I,zNum] = microImInputRaw(spm,t,1,1); %Get the images
    zStacks(t,:) = [size(I,1) size(I,2) zNum];
    
    %Spread pixel values if the image is low contrast
    if(sprd==1)
        I = I-minp;
        I = I./maxp;
    end
    
    [Ireg,CL] = gseg3(I,TH(t),sigma,xyratz); %Segment the regions
    CLnum = size(CL);
    clInfo = [clInfo; CL zeros(CLnum(1),1)+t];
    if(size(CL,1)==0) %This happens if no regions are detected in a time stamp
        timeArray(t,:) = [0 0];
    else
        timeArray(t,:) = [size(clInfo,1)-size(CL,1)+1 size(clInfo,1)];
    end
    for z=1:zStacks(t,3)
        imwrite(Ireg(:,:,z),[pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/TM' tmStr '/SEG_IM.tif'],'writemode','append');
    end
end
save('cell_location_information','clInfo','timeArray');
save('zStacks','zStacks');

cd ..

end

