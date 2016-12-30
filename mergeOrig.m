function [ cellImage ] = mergeOrig( orig, cellLocations )
SZ = size(cellLocations); %How many cells are in the picture
cellImage = orig;

for i=1:SZ(1)
    cellImage(cellLocations(i,1)-5:cellLocations(i,1)+4,cellLocations(i,2)-5:cellLocations(i,2)+4,1) = zeros(10);
    cellImage(cellLocations(i,1)-5:cellLocations(i,1)+4,cellLocations(i,2)-5:cellLocations(i,2)+4,2) = zeros(10);
    cellImage(cellLocations(i,1)-5:cellLocations(i,1)+4,cellLocations(i,2)-5:cellLocations(i,2)+4,3) = zeros(10)+1;
end
end

