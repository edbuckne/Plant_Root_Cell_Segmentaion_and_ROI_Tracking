function [ I3 ] = equalizeLocal( I2 )
szI2 = size(I2);
I4 = zeros(szI2(1),szI2(2));
h = fspecial('disk',8); 

for j=1:szI2(2)
    data = I2(:,j);
    data2 = filter([0.125 0.125 0.125 0.125 0.125 0.125 0.125 0.125],1,data);
    data3 = diff(data2);
    
    A = findZCrossing(data3,1);
    lenA = length(A);
    B = findZCrossing(data3,0);
    lenB = length(B);
    
    if (lenA>lenB)
        differ = lenA-lenB;
        endMat = zeros(differ,1);
        B = [B; endMat];
    elseif (lenB>lenA)
        differ = lenB-lenA;
        endMat = zeros(differ,1);
        A = [A; endMat];
    end
    newData = zeros(length(data),1);
    
    AB = [A B];
    
    for i=2:lenB-2
        if (A(i)>B(i))
            Thalf = B(i-1)-A(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = 0.2.*cos(2*pi*f*t)+0.5;
            newData(A(i):B(i-1)-1)=dataIns;
        else
            Thalf = B(i)-A(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = 0.2.*cos(2*pi*f*t)+0.5;
            newData(A(i):B(i)-1)=dataIns;
        end
    end
    
    for i=1:lenB-2
        if (B(i)>A(i))
            Thalf = A(i+1)-B(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = -0.2.*cos(2*pi*f*t)+0.5;
            newData(B(i):A(i+1)-1)=dataIns;
        else
            Thalf = A(i)-B(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = (-0.2.*cos(2*pi*f*t))+0.5;
            newData(B(i):A(i)-1)=dataIns;
        end
    end
    I4(:,j) = newData;
end
        


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%


I5 = zeros(szI2(1),szI2(2));

for j=1:szI2(1)
    data = I2(j,:);
    data2 = filter([0.125 0.125 0.125 0.125 0.125 0.125 0.125 0.125],1,data);
    data3 = diff(data2);
    
    A = findZCrossing(data3,1);
    lenA = length(A);
    B = findZCrossing(data3,0);
    lenB = length(B);
    
    if (lenA>lenB)
        differ = lenA-lenB;
        endMat = zeros(differ,1);
        B = [B; endMat];
    elseif (lenB>lenA)
        differ = lenB-lenA;
        endMat = zeros(differ,1);
        A = [A; endMat];
    end
    newData = zeros(length(data),1);
    
    
    for i=2:lenB-2
        if (A(i)>B(i))
            Thalf = B(i-1)-A(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = 0.2.*cos(2*pi*f*t)+0.5;
            newData(A(i):B(i-1)-1)=dataIns;
        else
            Thalf = B(i)-A(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = 0.2.*cos(2*pi*f*t)+0.5;
            newData(A(i):B(i)-1)=dataIns;
        end
    end
    
    for i=1:lenB-2
        if (B(i)>A(i))
            Thalf = A(i+1)-B(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = -0.2.*cos(2*pi*f*t)+0.5;
            newData(B(i):A(i+1)-1)=dataIns;
        else
            Thalf = A(i)-B(i);
            f = 0.5/double(Thalf);
            t = 1:Thalf;
            dataIns = (-0.2.*cos(2*pi*f*t))+0.5;
            newData(B(i):A(i)-1)=dataIns;
        end
    end
    I5(j,:) = newData;
end

I6 = I4.*I5;
I3 = imfilter(I6,h,'replicate');

end

