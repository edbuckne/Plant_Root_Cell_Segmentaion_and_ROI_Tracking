function [ cellShape3D ] = cellShapeInfo3D( cellInfo3D, Idata )
%CellShapeInfo3D takes in the cell information calculated from the
%cellLocationInfo3D function and creates data that can be used to track the
%cells over time.  This function has 2 inputs and 1 output;
% INPUTS:
%     1. cellInfo3D - Information matrix that describes each super voxel in 3D space
%     2. Idata - The 3 dimensional image data of a specific time point
% OUTPUTS:
%     1. cellShape3D - Information matrix that describes each super voxel in greater
%     detail than the cellInfo3D matrix. This data columns are described below
%         1. ID - Unique ID for each cellular object found
%         2. Xc - X center of mass
%         3. Yc - Y center of mass
%         4. Zc - Z center of mass
%         5. Zcr - Z center of mass relative to 3 dimensional space.  This parameter
%         is in proportion to X and Y with respect to physical distances.
%         6. VARx - Variance in the X direction
%         7. VARy - Variance in the Y direction
%         8. VARzr - Variance in the Z direction using an interpolated z axis
%         9. mu - Maximum pixel value found in the super voxel
%         10. size - Number of pixels that are found in the super voxel over a
%         specific threshold value.

%Variables
ZRatio = 14.3517;
ZRatioRound = 14;
TH = 0.15; %Threshold for counting size

s = size(cellInfo3D);
cellShape_prime = zeros(s(1),10);

for i=1:s(1)
    testInfo = cellInfo3D(i,:);
    
    %Get the box data
    x1 = testInfo(2);
    x2 = testInfo(3);
    y1 = testInfo(4);
    y2 = testInfo(5);
    z1 = testInfo(6)-1; %Grab two extra z stacks
    if (z1==0)
        z1 = 1;
    end
    z2 = testInfo(7)+1;
    zDepth = z2-z1+1; %How big is this box?
    xWidth = x2-x1+1;
    yHeight = y2-y1+1;
    
    testMat = Idata(y1:y2,x1:x2,z1:z2); %Matrix that holds the super voxel data
    
    [Xc1,Yc1,Zc1, mu] = find3DMaxIndex(testMat); %Finds the XZY of the super voxel COM
    CP = [Xc1 Yc1 Zc1]; %Center of testMat
    AP = [x1-1 y1-1 z1-1]; %Beginning corner of original image
    COM = CP+AP; %COM of supervoxel for the cell
    
    cellShape_prime(i,1:5) = [i COM COM(3)*ZRatio]; % $$REPLACE$$ - store the COM information
    
    %Find the variance of the gaussian PDF in the x direction
    dataX=testMat(Yc1,:,Zc1); %Obtain 1D data
    Ax = 0; %Expected value of X integral sum
    delX = 1; %Delta x
    for x=1:length(dataX) %Zero order hold approximation of the integral
        Ax = Ax+dataX(x); %Area under the curve
    end
    dataX = dataX./Ax; %Normalize the data
    Ex = 0;
    for x=1:length(dataX) %Zero order hold approximation of the integral
        Ex = Ex+x*dataX(x)*delX; %E[X]
    end
    VarX = 0;
    for x=1:length(dataX) %Zero order hold approximation of the integral
        VarX = VarX+dataX(x)*((x-Ex)^2); %Integral of f(x)(x-mu)^2
    end
    cellShape_prime(i,6) = VarX;
    
    
    %Find the variance of the gaussian PDF in the y direction
    dataY=testMat(:,Xc1,Zc1); %Obtain 1D data
    Ay = 0; %Expected value of X integral sum
    delY = 1; %Delta x
    for y=1:length(dataY) %Zero order hold approximation of the integral
        Ay = Ay+dataY(y); %Area under the curve
    end
    dataY = dataY./Ay; %Normalize the data
    Ey = 0;
    for y=1:length(dataY) %Zero order hold approximation of the integral
        Ey = Ey+y*dataY(y)*delY; %E[X]
    end
    VarY = 0;
    for y=1:length(dataY) %Zero order hold approximation of the integral
        VarY = VarY+dataY(y)*((y-Ey)^2); %Integral of f(x)(x-mu)^2
    end
    cellShape_prime(i,7) = VarY;
    
    %Find the variance of the gaussian PDF in the z direction
    dataZ = zeros(1,zDepth);
    for z=1:zDepth %Have to get each z pixel individually
        dataZ(z) = testMat(Yc1,Xc1,z);
    end
    %Interpolate the z data because we don't have as many data points
    xOld = 1:length(dataZ);
    xNew = 1:1/ZRatioRound:length(dataZ);
    dataZinterp = spline(xOld,dataZ,xNew);
    A = 0; %Start sum for the z data
    for z=1:length(xNew)
        A=A+dataZinterp(z); %Zero order hold approximation integral
    end
    dataZinterp = dataZinterp./A;
    Ez = 0;
    for z=1:length(xNew)
        Ez = Ez+z*dataZinterp(z); %Expected value of Z
    end
    VarZ = 0;
    for z=1:length(xNew)
        VarZ = VarZ+dataZinterp(z)*(z-Ez)^2; %VarZ = sum:f(z)(z-Ez)^2
    end
    cellShape_prime(i,8) = VarZ;
    
    cellShape_prime(i,9) = mu;
    
    count = 0; %Count for the number of pixels within the super voxel that are above a threshold value
    for x=1:xWidth
        for y=1:yHeight
            for z=1:zDepth
                if testMat(y,x,z)>TH
                    count=count+1;
                end
            end
        end
    end
    
    cellShape_prime(i,10) = count; %Store that count
end

%Perge duplicates
for i=1:s(1) %Primary index
    for j=i+1:s(1) %Secondary index
        if(cellShape_prime(j,2:4)==cellShape_prime(i,2:4))
            cellShape_prime = [cellShape_prime(1:j-1,:); cellShape_prime(j+1:end,:); zeros(1,10)];
        end
    end
    if (cellShape_prime(i,2)==0) %once we get to the zeros, we break
        break;
    end
end

cellShape3D = cellShape_prime(1:i-1,:);
end

