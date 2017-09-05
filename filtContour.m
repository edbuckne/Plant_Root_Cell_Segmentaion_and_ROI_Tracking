function [ filtData ] = filtContour( ACV1, xSpread, varX )
%Good value for xSpread is 100 and for varX is 50

x = -xSpread:xSpread;
norm = normpdf(x,0,varX);

logVar1 = 1:length(ACV1); %Make a variable to use for logical operations

convAC = conv(ACV1,norm); %Convolving the data to get a filtered answer

%convAC = convAC(xSpread:end-xSpread-1); %Taking out the tails of the filtered data

% convAC(logVar1<2*xSpread) = ACV1(1:2*xSpread-1); %Deleting more of the tail

% convAC(logVar1>end-xSpread) = ACV1(end-xSpread+1:end);

filtData = convAC;
end

