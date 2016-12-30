function [ boundImage,cellLoc ] = drawBounds( image, num, opt )

tmpVirt = image; tmpHor = image;%Store image in a temporary variable
SZ = size(image);


for column = 3:(SZ(2)-num)
    %perc = double(column)/double(SZ(2))*100/2
    dataC = zeros(SZ(1),1)+1; %Variable for data to be stored (column)
    %Take raw data from the columns and filter that data
    for i=1:num
        dataC = dataC.*tmpVirt(:,column+i-1,2); %Multiply together the columns
    end
    filtDataC=filter([0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1],1,dataC); %Filtered data

    %Derivative of data, filtered derivative, and corrected filtered data
    derDataC = diff(filtDataC);
    filtDiffDataC=filter([0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1],1,derDataC);
    corrFiltDiffDataC = [filtDiffDataC(4:end); 0; 0; 0];
    
    %Paint on the vertical boundaries
    ZCrossingMatC = findZCrossing(corrFiltDiffDataC,opt);
    tmpVirt = virtBound(tmpVirt,ZCrossingMatC,column);
end

%Do the same thing for the rows

for row=3:(SZ(1)-num)
    %perc = double(row)/double(SZ(1))*100/2+50
    dataR = zeros(1,SZ(2))+1;
    %Obtain and filter data
    for i=1:num
        dataR = dataR.*tmpHor(row+i-1,:,2); %Multiply rows together
    end
    filtDataR=filter([0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1],1,dataR);
    
    %Find estimated differential, filter, and correct filter
    derDataR = diff(filtDataR);
    filtDiffDataR=filter([0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1],1,derDataR);
    corrFiltDiffDataR = [filtDiffDataR(4:end) 0 0 0];
    
    %Paint on the boundaries
    ZCrossingMatR = findZCrossing(corrFiltDiffDataR,opt);
    tmpHor = horBound(tmpHor,ZCrossingMatR,row);
end

if opt
    boundImage = mergeBound(tmpVirt,tmpHor);
else
    [boundImage,cellLoc] = mergeCells(tmpVirt,tmpHor,image);
end

end

