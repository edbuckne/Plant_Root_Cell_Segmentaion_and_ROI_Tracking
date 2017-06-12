function [ AC1, AC2 ] = create3DRec( AC1, AC2, MidLine1, MidLine2 )
%Function that takes in the contour points AC1 and AC2 (3xN) oriented at
%the origin.  And takes in the Midline (3xN) of those two, and 3D plots them.

sMid1 = size(MidLine1); %Getting the sizes of the midlines
sMid2 = size(MidLine2);

[maxY1,maxI1] = max(AC1(2,:)); %Index of bottom
[maxY2,maxI2] = max(AC2(2,:)); 

%Insert MidLine2 into AC1
count = 0;
for i=maxY1:-1:1
    if(count>sMid2(2))
        break;
    elseif(i>sMid2(2))
        continue;
    else
        AC1(3,maxY1-count)=MidLine2(1,i);
        AC1(3,maxY1+count)=MidLine2(1,i);
        count = count+1;
    end
end
AC1(3,1) = AC1(3,2);
AC1(3,end) = AC1(3,end-1);


%Insert MidLine1 into AC2
count = 0;
for i=maxY2:-1:1
    if(count>sMid1(2))
        break;
    elseif(i>sMid1(2))
        continue;
    else
        AC2(3,maxY2-count)=MidLine1(1,i);
        AC2(3,maxY2+count)=MidLine1(1,i);
        count = count+1;
    end
end
AC2(3,1) = AC2(3,2);
AC2(3,end) = AC2(3,end-1);

AC1(2,:) = maxY1-AC1(2,:);
AC2(2,:) = maxY2-AC2(2,:);

% figure
% plot3(AC1(1,:),AC1(3,:),AC1(2,:));
% hold on
% plot3(AC2(3,:),AC2(1,:),AC2(2,:));
end

