function [ DATA_OUT ] = equalizeData( DATA_IN, IT )
%Takes in data and performs the Local Extreme Equalization
%Input:
%   1. DATA_IN - 1 dimensional data to be equalized
%Output:
%   1. DATA_OUT - 1 dimensional equalized data

%Initialized Variables
len = length(DATA_IN);
sz = size(DATA_IN);
if (sz(2)>1)
    DATA_IN=DATA_IN';
end

%Find the local mins and maxes of the data and holds on to their locations
if(IT==1)
    dataFilt = filter([0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1],1,DATA_IN);
else %If this isn't the first iteration, no need to filter
    dataFilt = DATA_IN;
end
dataDiff = diff(dataFilt);
maxData = findZCrossing(dataDiff,1); %Finds max points
minData = findZCrossing(dataDiff,0); %Finds min points
minData = [1; minData];
lenMaxData = length(maxData);
lenMinData = length(minData);

%Determines which set of data is longer and aligns them such that the
%matrices are the same length and maxes come before mins
if (lenMaxData>lenMinData) %More max points than min points
    while (lenMaxData>lenMinData)
        minData = [minData; len]; 
        lenMaxData = length(maxData);
        lenMinData = length(minData);
    end
elseif (lenMaxData<lenMinData) %More min points than max points
    while (lenMaxData<lenMinData)
        maxData = [1; maxData]; 
        lenMaxData = length(maxData);
        lenMinData = length(minData);
    end
elseif (lenMaxData==0 || lenMinData==0)
    DATA_OUT=DATA_IN;
    return
else %Same amount of data points
    if(maxData(1)>minData(1))
        maxData = [1; maxData];
        minData = [minData; len];
    end
end
DATA_OUT = zeros(len,1);
lenMaxData = length(maxData);
lenMinData = length(minData);

%If the data does not line up, print an error
if(~(lenMaxData==lenMinData))
    maxData
    minData
    error('Minimum and Maximum arrays do not have the same amount of data points');
end

%Enter a sine wave into the newData array for each half time period

%max to min sections
for i=1:lenMaxData
    tHalf = minData(i)-maxData(i); %Half time period
    freq = 0.5/double(tHalf); %Frequency of such half period
    t = 1:tHalf;
    DATA_OUT(maxData(i)+1:minData(i)) = 0.5.*cos(2*pi*freq.*t)+0.5;
end

%min to max sections
for i=1:(lenMinData-1) %Go to the next to last because the last element will be a max to min
    tHalf = maxData(i+1)-minData(i);
    freq = 0.5/double(tHalf);
    t = 1:tHalf;
    DATA_OUT(minData(i)+1:maxData(i+1)) = -0.5.*cos(2*pi*freq.*t)+0.5;
end
if(IT==1)
    DATA_OUT = [DATA_OUT(5:end); 0; 0; 0; 0];
end
end

