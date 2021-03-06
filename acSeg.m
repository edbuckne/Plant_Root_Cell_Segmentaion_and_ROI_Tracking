function [ AClist, MidLine, maxX1 ] = acSeg( I, showStr )
%Takes in an image, and a string.  Returns the border contour of the image
%and the midline of the left and right of the contour.

height = size(I,1);
width = size(I,2);

left = zeros(height,2);
right = zeros(height,2);

for h=1:height
    left(h,:) = [1 h];
    right(h,:) = [width h];
end

for h=1:height
    while(I(h,left(h,1))==0 && left(h,1)<width)
        left(h,1) = left(h,1)+1;
    end
    if(left(h,1)==width)
        break;
    end
end
if(h<20) %If the contour comes back blank or very small
    AClist = [];
    MidLine = [];
    maxX1 = [];
    return
end
left = left(1:h-1,:);

for w=1:height
    while(I(w,right(w,1))==0 && right(w,1)>1)
        right(w,1) = right(w,1)-1;
    end
    if(right(w,1)==1)
        break;
    end
end
if(h<20) %If the contour comes back blank or very small
    AClist = [];
    MidLine = [];
    maxX1 = [];
    return
end
right = right(1:w-1,:);

left(:,1) = filter([0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05],1,left(:,1));
right(:,1) = filter([0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05],1,right(:,1));
left(1:20,1) = zeros(20,1)+left(21,1);
right(1:20,1) = zeros(20,1)+right(21,1);

if strcmp(showStr,'show')
    figure
    imshow(I)
    line(left(:,1),left(:,2),'linewidth',3)
    line(right(:,1),right(:,2),'linewidth',3)
end

s = size(right,1);
rightN = zeros(s,2);
j=s;
for i=1:s
    rightN(i,:) = right(j,:);
    j=j-1;
end

AClist = [left; rightN]';
[~,maxI1] = max(AClist(2,:));
maxX1 = AClist(1,maxI1); %The origin of ACP1

AClist(1,:) = AClist(1,:)-maxX1; %Shift everything to the origin
left(:,1) = left(:,1) - maxX1;
right(:,1) = right(:,1) - maxX1;

MidLine = ones(3,s-1); %Contains the midline of the root

for i=1:s-1
    MidLine(2,i) = i;
    MidLine(1,i) = (left(i,1)+right(i,1))/2; %Average line
end
MidLine(2,:) = s-MidLine(2,:);
end

