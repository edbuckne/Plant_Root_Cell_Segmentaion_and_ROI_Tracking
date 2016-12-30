function [ cellIm, cellLoc ] = mergeCells( virtIm, horIm, orig  )
SZ = size(virtIm); %Only need to find the size of one.  They are the same size
cellIm = orig; %Original rgb image
cellLoc = []; %Holds the location of the cells

for x=1:SZ(2)
    for y=1:SZ(1)
        %We can find whether or not a pixel is black by multiplying the RGB
        %value of a pixel.  If it is 1, then the pixel is black.
        tmpV = (1-virtIm(y,x,1))*(1-virtIm(y,x,2))*(1-virtIm(y,x,3));
        tmpH = (1-horIm(y,x,1))*(1-horIm(y,x,2))*(1-horIm(y,x,3));
        if (tmpV==1 && tmpH==1) %If both are black, paint the new pixel blue 2x2
            cellIm(y-5:y+4,x-5:x+4,1) = zeros(10);
            cellIm(y-5:y+4,x-5:x+4,2) = zeros(10);
            cellIm(y-5:y+4,x-5:x+4,3) = zeros(10)+1;
            cellLoc = [cellLoc; [y,x]];
            %cellIm(y,x,1) = 0; cellIm(y-1,x,1) = 0; cellIm(y,x-1,1) = 0; cellIm(y-1,x-1,1) = 0; 
            %cellIm(y-1,x+1,1) = 0; cellIm(y+1,x,1) = 0; cellIm(y,x+1,1) = 0; cellIm(y+1,x+1,1) = 0; cellIm(y+1,x-1,1) = 0; 
            %cellIm(y,x,2) = 0; cellIm(y-1,x,2) = 0; cellIm(y,x-1,2) = 0; cellIm(y-1,x-1,2) = 0;
            %cellIm(y-1,x+1,2) = 0; cellIm(y+1,x,2) = 0; cellIm(y,x+1,2) = 0; cellIm(y+1,x+1,2) = 0; cellIm(y+1,x-1,2) = 0;
            %cellIm(y,x,3) = 1; cellIm(y-1,x,3) = 1; cellIm(y,x-1,3) = 1; cellIm(y-1,x-1,3) = 1;
            %cellIm(y-1,x+1,3) = 1; cellIm(y+1,x,3) = 1; cellIm(y,x+1,3) = 1; cellIm(y+1,x+1,3) = 1; cellIm(y+1,x-1,3) = 1;
        else %Else just keep the old image
            cellIm(y,x,:) = orig(y,x,:);
        end
    end
end
end

