function [ pixelLoc ] = findRegion( filtIm, x, y )
CL = [y x];
maxSz = 28;
numLines = 40;
szIm = size(filtIm);

Y1 = CL(1)-maxSz+1;
Y2 = CL(1)+maxSz;
X1 = CL(2)-maxSz+1;
X2 = CL(2)+maxSz;

if ((Y1<=0)||(X1<=0)||(Y2>szIm(1))||(X2>szIm(2)))
    pixelLoc = [1; 1];
    return
end

regMat = filtIm(Y1:Y2,X1:X2);
szreg = size(regMat);
modMat = regMat;
% figure(3)
% mesh(1:szreg(2),szreg(1):-1:1,regMat);

maxLoc = zeros(1,2);
maxVal = 0;

for y=1:szreg(1)
    for x=1:szreg(2)
        if(~(regMat(y,x)>maxVal))
        else
            maxLoc = [y x];
            maxVal = regMat(y,x);
        end
    end
end
minVal = min(min(regMat));

figure(4)
[c h] = imcontour(regMat,numLines);
data = c(1,:);
lineCheck = maxVal-2*(maxVal-minVal)/numLines;

storeI = 0;
indexLevels = [];
for i=length(data):-1:1
    if(~(data(i)<1))
    else
        indexLevels=[indexLevels; i];
    end
end

boundInd = isBound(c,indexLevels);
if (boundInd <= 1)
    Bad = [1; 1];
    pixelLoc = Bad;
    return
end
regStart = indexLevels(boundInd);

pixelLoc = zeros(2,((indexLevels(boundInd-1)-1)-(regStart+1)));


for i=(regStart+1):(indexLevels(boundInd-1)-1);
    pixel = c(:,i);
    pixelLoc(:,i-regStart) = [CL(2)+pixel(1)-maxSz; CL(1)+pixel(2)-maxSz];
    modMat(int8(pixel(2)),int8(pixel(1))) = 0.5;
end

% figure(5)
% mesh(1:szreg(2),szreg(1):-1:1,modMat);

end

