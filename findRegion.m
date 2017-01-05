function [ pixelLoc ] = findRegion( filtIm, x, y )
CL = [y x];
maxSz = 20;
numLines = 40;

regMat = filtIm(CL(1)-maxSz+1:CL(1)+maxSz,CL(2)-maxSz+1:CL(2)+maxSz);
szreg = size(regMat);
modMat = regMat;
figure(2)
mesh(1:szreg(2),szreg(1):-1:1,regMat);

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

figure(3)
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
regStart = indexLevels(boundInd);

pixelLoc = zeros(2,1,((indexLevels(boundInd-1)-1)-(regStart+1)));
size(pixelLoc)
for i=regStart+1:indexLevels(boundInd-1)-1;
    pixel = int8(c(:,i));
    pixelLoc(:,:,i) = [x+pixel(1)-maxSz y+pixel(2)-maxSz];
    modMat(pixel(2),pixel(1)) = 0.5;
end

figure(4)
mesh(1:szreg(2),szreg(1):-1:1,modMat);
end

