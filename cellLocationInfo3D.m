function [ cellInfo3D, SORTED_OUT_2 ] = cellLocationInfo3D( cellInfo, Z_STACKS, TM, PTH )
%cellLocationInfo3D takes in the cellInfo matrix produced by the function
%"cellLocationInfo2D" and segments the 3 dimensional slices by defining the
%data into a cellInfo3D matrix. Note, this only works for 1 time stamp at a
%time.
%     Inputs:
%         1. cellInfo - matrix of 2 dimensional images that describe where the 
%         objects are located in 2D space.
%         2. Z_STACKS - number of z stacks located in this time stamp
%         3. TM - time stamp.  The user must indicate which time stamp this 
%         is the evaluation for in order to save the .mat file correctly.
%     Outputs
%         1. cellInfo3D - matrix that defines segmented boxes or "super voxels"
% Column definitions for cellInfo3D
%     1. ID - Each cell indicated gets a unique ID number
%     2. x1
%     3. x2
%     4. y1
%     5. y2
%     6. z1
%     7. z2
%     *Note: column 2 to 7 are the 6 points that define the box that contains
%     an area of interest.
disp(['Constructing 3D super voxel information for time stamp ' num2str(TM)]);

MAX_DIST = 15.00; %Max distance a cell COM location can move between stacks
DP = 10; %Data points

s = size(cellInfo); %Information about how many cell info vectors were found
OUT = zeros(s(1),DP); %OUT is the matrix that holds the "raw" 3d segmentation information

count = 0;
i = 1; %Index
z = 1; %Used to reference which z stack
start = i; %Make note of where you started
while (cellInfo(i,5)==z||cellInfo(i,5)==0) %Go through first stack
    count = count+1; %Counts how many vectors are found before pass the 1st stack
    OUT(i,:) = [i -1 cellInfo(i,3:5) 0 0 0 0 0]; %Puts information into the OUT matrix
    i = i+1;
end
enD = i-1; %Where to find the end of the last stack
startOld = start; %Where to find the beginning of the last stack
enD2 = 1; %These two are used for 2 z stacks before in case a parent wasn't found
startOld2 = 1;

%Now that the first stack has been handled, go through the rest of the
%stacks
for z=2:Z_STACKS
    start = i; %Start off where you left off last time
    if (i>s(1)) %If ever we past the index of the size we exit
        break;
    end
    while (cellInfo(i,5)==z||cellInfo(i,5)==0)
        if (cellInfo(i,5)==0)
            i=i+1;
            if (i>s(1))
                break;
            end
            continue
        end
        found = 0; %Variable is set to 1 when a parent is found
        OUT(i,1) = i; %The id of the object is the same as the index
        OUT(i,3:5) = cellInfo(i,3:5);
        locNew = [cellInfo(i,3) cellInfo(i,4)]; %Compare to this z stack
        for j=startOld:enD %Trying to find a parent from the previous z stack
            locOld = [OUT(j,3) OUT(j,4)]; %Looking at location of last z stacks
            xDis = locNew(1)-locOld(1); %Find the distance
            yDis = locNew(2)-locOld(2);
            Dis = sqrt(xDis^2+yDis^2);
            if(Dis>MAX_DIST)
            else
                OUT(i,2) = OUT(j,1); %If it is close by, that is the parent
                found = 1;
                break
            end
        end
        if (~(found)) %If nothing was found, check 2 stacks ago
            for p=startOld2:enD2
                locOld = [OUT(p,3) OUT(p,4)]; %Looking at location of last 2 z stacks
                xDis = locNew(1)-locOld(1); %Find the distance
                yDis = locNew(2)-locOld(2);
                Dis = sqrt(xDis^2+yDis^2);
                if(Dis>MAX_DIST)
                else
                    OUT(i,2) = OUT(p,1); %If it is close by, that is the parent
                    found = 1;
                end
            end
            if (found) %This covers the case that we found one 2 stacks ago
            else
                OUT(i,2) = -1;
            end
        end
        i = i+1;
        if (i>s(1))
            break
        end
    end
    enD2 = enD;
    startOld2 = startOld;
    enD = i-1; %Record last stack's range
    startOld = start;
end

%Add a sorted column
s = size(OUT);
% zs = zeros(s(1),1); %This column is added to the OUT function to indicated when it has been sorted
% OUT = [OUT zs];
% s = size(OUT);
SORTED_OUT_1 = zeros(s); %Where the sorted (backwards) matrix will go
b = 1; %Index of the SORTED_OUT_1 matrix
idNew = 1; %A new id for each 3D segmented super voxel
OUT(1,2) = -1;

for i=s(1):-1:1 %Start at the end of OUT and go to the beginning
    j=i; %j is a dynamic index to grab items to be put in the sorted matrix
    if (OUT(i,1)==0) %If it was a false positive, do nothing
        continue;
    end
    if (OUT(i,6)==0) %Hasn't been sorted yet
        OUT(i,6) = 1; %Indicated that it has now
        if (OUT(i,2)==-1) %It has no parent (Lone wolf) ignore it
%             SORTED_OUT_1(b,:) = [OUT(i,1:5) idNew 0 0 0 0];
%             b=b+1;
            continue; %Do loop again
        end
        SORTED_OUT_1(b,:) = [OUT(i,1:5) idNew 0 0 0 0]; %If it does have a parent
        b = b+1;
        count=1;
        while ~(OUT(j,2)==-1) %Keep sorting until you find the original vector (with no parent)
            count=count+1;
            j=OUT(j,2); %Index the parent
            OUT(j,6) = 1;
            SORTED_OUT_1(b,:) = [OUT(j,1:5) idNew 0 0 0 0];
            b = b+1;
        end
        if(count<=PTH)
            SORTED_OUT_1(b-count:b-1,:) = zeros(count,10);
        end
        idNew = idNew+1; %Once we have reached here, we can create a new super voxel id number
    end
end
s=size(SORTED_OUT_1);
%SORTED_OUT_2 is just SORTED_OUT_1 backwards
SORTED_OUT_2 = zeros(s);
j = s(1);
for i=1:s(1)
    if~(SORTED_OUT_1(i,1)==0)
        SORTED_OUT_2(j,:) = SORTED_OUT_1(i,:);
        j=j-1;
        continue;
    end
end

%All false positive vectors will be in the beginning of the matrix now, so go until we don't
%see zeros anymore
i = 1;
while (SORTED_OUT_2(i,3)==0)
    i=i+1;
end
id3d = SORTED_OUT_2(i,6); %id3d holds the number of super voxels found
cellInfo3D = zeros(id3d,10); %Final out matrix
j=i; %j is the index for SORTED_OUT_2

for finalIndex=1:id3d %Look at each super voxel
    cellInfo3D(finalIndex,6) = SORTED_OUT_2(j,5); %Record z1
    cellInfo3D(finalIndex,1) = finalIndex; %Super voxel ID number
    Xsum = 0; %We want to record the center of mass as the average X and Y pixels
    Ysum = 0;
    numInSV = 0;
    maxW = 0;
    maxH = 0;
    while (SORTED_OUT_2(j,6)==id3d) %Go through all of the vectors that describe a super voxel
        cellId = SORTED_OUT_2(j,1);
        Xsum = Xsum+SORTED_OUT_2(j,3);
        Ysum = Ysum+SORTED_OUT_2(j,4);
        numInSV = numInSV+1;
        %Below are the 4 2D points that describe a rectangle 
        B = cellInfo(cellId,9);
        T = cellInfo(cellId,8);
        R = cellInfo(cellId,6);
        L = cellInfo(cellId,7);
        H = B-T; %Height
        W = R-L; %Width
        if (H>maxH) %If H is greater that H max, put in final matrix and replace
            cellInfo3D(finalIndex,4)=T; %y1 and y2
            cellInfo3D(finalIndex,5)=B;
            maxH = H;
        end
        if (W>maxW) %If W is greated that W max, put in final matrix and replace
            cellInfo3D(finalIndex,2)=L; %x1 and x2
            cellInfo3D(finalIndex,3)=R;
            maxW = W;
        end
        j=j+1; %Increase SORTED_OUT_2 matrix index
        if (j>s(1))
            break;
        end
    end
    id3d=id3d-1; %Once a super voxel has been completed, go to the next one
    cellInfo3D(finalIndex,7) = SORTED_OUT_2(j-1,5); %Record z2
    cellInfo3D(finalIndex,8) = int16(Xsum/numInSV); %Record x 3D COM
    cellInfo3D(finalIndex,9) = int16(Ysum/numInSV); %Record y 3D COM
    cellInfo3D(finalIndex,10) = int16((cellInfo3D(finalIndex,6)+cellInfo3D(finalIndex,7))/2);
    SORTED_OUT_2;
end
%save(['./segmentation/3DCellInfo_TM' num2str(TM)],'cellInfo3D');
end

