function [ shapeInfo ] = getChar3( I, Ireg, clInfo )
%This function measures different characteristics found in the fluorescent
%image

%Initialize variables
sCL = size(clInfo);
shapeInfo = zeros(sCL(1),9);
timeTot = 0;
timeTotCount = 0;

for i=1:sCL(1) %Look at each element
    secVal = Ireg(clInfo(i,2),clInfo(i,1),clInfo(i,3)); %Get the value of the section from the COM
    tot = 0; %Used to sum up all pixle values in the region to normalize the curve
    totCount = 0;
    for x=clInfo(i,4):clInfo(i,5)
        for y=clInfo(i,6):clInfo(i,7)
            for z=clInfo(i,8):clInfo(i,9)
                if(Ireg(y,x,z)==secVal)
                    timeTot = timeTot+I(y,x,z);
                    tot = tot+I(y,x,z);
                    timeTotCount = timeTotCount+1;
                    totCount = totCount+1;
                end
            end
        end
    end
    
    Ex = clInfo(i,1); %All of the expected values
    Ey = clInfo(i,2);
    Ez = clInfo(i,3);
    Vx = 0; %Variences
    Vy = 0;
    Vz = 0;
    Cxy = 0; %Covariences
    Cxz = 0;
    Cyz = 0;
    
    Ilog = Ireg==secVal; %Used as a mask for the regions
    for x=clInfo(i,4):clInfo(i,5) %Go through them again getting the covarience information
        for y=clInfo(i,6):clInfo(i,7)
            for z=clInfo(i,8):clInfo(i,9)
                Vx = Vx+((x-Ex)^2)*Ilog(y,x,z); %V(X)
                Vy = Vy+((y-Ey)^2)*Ilog(y,x,z); %V(Y)
                Vz = Vz+((z-Ez)^2)*Ilog(y,x,z); %V(Z)
                Cxy = Cxy+(x-Ex)*(y-Ey)*Ilog(y,x,z); %C(XY)
                Cxz = Cxz+(x-Ex)*(z-Ez)*Ilog(y,x,z); %C(XZ)
                Cyz = Cyz+(y-Ey)*(z-Ez)*Ilog(y,x,z); %C(YZ)
            end
        end
    end
    shapeInfo(i,1) = Vx/totCount; %Vx,Vy,Vz,Cxy,Cxz,Cyz
    shapeInfo(i,2) = Vy/totCount;
    shapeInfo(i,3) = Vz/totCount;
    shapeInfo(i,4) = Cxy/totCount;
    shapeInfo(i,5) = Cxz/totCount;
    shapeInfo(i,6) = Cyz/totCount;
    shapeInfo(i,7) = totCount; %Total number of voxels effected
    shapeInfo(i,8) = tot/totCount; %Average voxel intensity
    shapeInfo(i,9) = tot; %Sum of voxel intensities
    
end
end

