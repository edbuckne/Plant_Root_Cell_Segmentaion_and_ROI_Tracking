SPM = 1;
TM = 1;
NUM = 43;
CL2D = CL201_1;
TH = 0.1;

PixDrift = 20;
I3 = 1;

s = size(CL2D);
%Ixz = yStacks(SPM,TM,NUM,1);
CL = zeros(s(1),4);
seg3D1 = zeros(s(1),10);

for i=1:s(1) %Go through each element in the CL2D stack
    if(CL2D(i,1)==0)
        continue;
    end
    CL(i,1) = CL2D(i,1); %Record the ID
    x = CL2D(i,3);
    y = CL2D(i,4);
    z = CL2D(i,5);
    xp = x;
    zp = z;
    I = im2bw(Ixz(:,:,y),TH); %Get the xz planar image
    while(I(zp,xp)==1&&zp>1) %Find the front of the GFP activity
        zp=zp-1;
    end
    CL(i,2) = zp;
    zp=z;
    while(I(zp,xp)==1&&zp<NUM) %Get the backend of the GFP activity
        zp=zp+1;
    end
    CL(i,3) = zp;
end

for i=1:s(1) %Go through the stack again to find PC relationships
    if(CL2D(i,1)==0)
        continue;
    elseif(CL(i,4)==1)
        continue;
    end
    logMat = zeros(s(1),5);
    x = CL2D(i,3); %Get information about the object at hand
    y = CL2D(i,4);
    z1 = CL(i,2);
    z2 = CL(i,3);
    logMat(:,1) = (abs(z1-CL(:,2))<=1); %z1 check
    logMat(:,2) = (abs(z2-CL(:,3))<=1); %z2 check
    logMat(:,3) = (abs(x-CL2D(:,3))<=PixDrift); %x check
    logMat(:,4) = (abs(y-CL2D(:,4))<=PixDrift); %y check
    logMat(:,5) = logMat(:,1).*logMat(:,2).*logMat(:,3).*logMat(:,4).*(1-CL(:,4)); %If they all meet criteria, they're part of the pc relationship
    
    j = 1; %Starting finding 3D atributes
    minT = CL2D(i,8);
    maxB = CL2D(i,9);
    minL = CL2D(i,7);
    maxR = CL2D(i,6);
    seg3D1(I3,1) = I3; %3D identifier
    seg3D1(I3,9) = CL2D(i,5); %z1
    for j=1:s(1)
        if(logMat(j,5)==1) %found a match
            CL(j,4) = 1;
            if(CL2D(j,8)<minT) %y1
                minT = CL2D(j,8);
            end
            if(CL2D(j,9)>maxB) %y2
                maxB = CL2D(j,9);
            end
            if(CL2D(j,7)<minL) %x1
                minL = CL2D(j,7);
            end
            if(CL2D(j,6)>maxR) %x2
                maxR = CL2D(j,6);
            end
            possZ2 = CL2D(j,5); %z2 will be in this variable when finished
        end
    end
    seg3D1(I3,5) = minL; seg3D1(I3,6) = maxR; seg3D1(I3,7) = minT; seg3D1(I3,8) = maxB; seg3D1(I3,10) = possZ2;
    seg3D1(I3,2) = int16((minL+maxR)/2); %XCOM
    seg3D1(I3,3) = int16((minT+maxB)/2); %YCOM
    seg3D1(I3,4) = int16((seg3D1(I3,9)+possZ2)/2); %ZCOM
    I3 = I3+1;
end
seg3D = seg3D1(1:I3-1,:);