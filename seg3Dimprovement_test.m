%Inputs to the function
CL2D = CL201_2;
K = 4;
TOL = 4;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~Code Begins~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%Variables
TH_DIS=3;
RAT=14;
j=1; %Dynamic pointer
count=0;
ID3D=1;

s = size(CL2D);
PC = zeros(s(1),3); %Parent/Child array


%~~~~~~~~~~~~~~~~~Find all parent/child relationships~~~~~~~~~~~~~~~~~~~~~%
for i=1:s(1)-1 %Go through each element in the array
    %Preliminary setup
    if(CL2D(i,1)==0) %Ignore false positives
        continue;
    end
    count=count+1; %Count how many true positives there are
    j=i+1; %Start the dynamic pointer at one after it
    M = 100; %Minimum distance (arbitrarily set to start at 100)
    I=-1;
    
    %Get minimum distances and fild child
    z = CL2D(i,5); %Get the current z stack
    while(CL2D(j,5)<=z&&(j<(s(1)-1))) %Get j to the next z stack
        j=j+1;
    end
    z=z+1; 
    while(CL2D(j,5)<=z&&(j<(s(1)-1)))
        cDis = sqrt((CL2D(j,3)-CL2D(i,3)).^2+(CL2D(j,4)-CL2D(i,4)).^2); %Distance calculation
        if(cDis<M&&cDis<TH_DIS) %If it is smaller than min, make new min and record where it happened
            M=cDis;
            I=j;
        end
        j=j+1;
    end
    PC(i,1:2) = [i, I];
end


%~~~~~~~~~~~~~~~~~~~Create the segmentation list~~~~~~~~~~~~~~~~~~~~~~~~~~%
seg3D = zeros(count,14);
for i=1:count
    if(PC(i,1)==0) %Ignore false positives
        continue;
    elseif(PC(i,3)==1) %Already been sorted
        continue;
    end
    
    maxR=CL2D(i,6); minL=CL2D(i,7); minT=CL2D(i,8); maxB=CL2D(i,9);
    j=i; %Setting dynamic pointer to point to self
    seg3D(ID3D,1)=ID3D;
    seg3D(ID3D,9)=CL2D(i,5); %z1
    while~(j==-1)
        oldj=j;
        PC(j,3)=1; %Mark as sorted
        if(CL2D(j,6)>maxR) %Getting new extremes all throughout the 
            maxR=CL2D(j,6);
        end
        if(CL2D(j,7)<minL)
            minL=CL2D(j,7);
        end
        if(CL2D(j,8)<minT)
            minT=CL2D(j,8);
        end
        if(CL2D(j,9)>maxB)
            maxB=CL2D(j,9);
        end
        j=PC(j,2); %Go to next element
    end
    seg3D(ID3D,5:8)=[minL maxR minT maxB]; %x1 x2 y1 y2
    seg3D(ID3D,10)=CL2D(oldj,5); %z2
    if~((seg3D(ID3D,10)-seg3D(ID3D,9))<TOL)
        ID3D=ID3D+1; %Increment 3D ID if there are enough parent/child relationships
    end
end
seg3D(:,2)=(seg3D(:,5)+seg3D(:,6))./2; %XCOM
seg3D(:,3)=(seg3D(:,7)+seg3D(:,8))./2; %YCOM
seg3D(:,4)=(seg3D(:,9)+seg3D(:,10)+2*K)./(2*K); %ZCOM
seg3D(:,11)=(seg3D(:,6)-seg3D(:,5));
seg3D(:,12)=(seg3D(:,8)-seg3D(:,7));
seg3D(:,13)=(seg3D(:,10)-seg3D(:,9))./(K).*RAT;
seg3D(:,14)=seg3D(:,11).*seg3D(:,12).*seg3D(:,13);
for i=1:count
    if(seg3D(i,1)==0)
        ind=i-1;
        break;
    end
end
CL3D = seg3D(1:ind,:);