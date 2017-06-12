function showGFP( TM, SCALE )
%This function takes in a time stamp from the data and displays the region
%of interests within the specimen with a corresponding item number;
load('zStacks');
load('data_config');
load([pwd '/TRACKING/PC_Relationships']); %Load the time Array and PC
load([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/cell_location_information']); %Load cell locations
load([pwd '/ROOT_BORDER/AC_Multiview_Info_TM' num2str(TM,'%.4u')]); %Load active contour

[maxY1,maxY1I] = max(ACRAWV1(2,:)); %Get the shifting information
maxX1 = ACRAWV1(1,maxY1I);
[maxY2,maxY2I] = max(ACRAWV2(2,:));
maxX2 = ACRAWV2(1,maxY2I);

b = timeArray(TM,1); %Get the range index for where this time stamp is in the CL list
e = timeArray(TM,2);

figure
hold on
title(['Cell locations for TM' num2str(TM,'%.4u')]);
plot3(ACV1(1,:),ACV1(3,:),ACV1(2,:),'b');
plot3(ACV2(3,:),ACV2(1,:),ACV2(2,:),'b');

zN = (zStacks(TM)*xyratz)/2; %Get the scale of z shift

scatter3(clInfo(b:e,1)-maxX1,clInfo(b:e,3)*xyratz-zN,maxY1-clInfo(b:e,2),zeros(e-b+1,1)+4);
axis([-SCALE(1)/2 SCALE(1)/2 -SCALE(1)/2 SCALE(1)/2 0 SCALE(2)]);
for i=b:e
    text(clInfo(i,1)-maxX1,clInfo(i,3)*xyratz-zN,maxY1-clInfo(i,2),num2str(i));
end
end

