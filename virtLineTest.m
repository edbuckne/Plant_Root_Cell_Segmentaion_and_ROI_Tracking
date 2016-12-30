function virtLineTest( image, column, RGB )

%size of image
SZ = size(image);
colNum = SZ(2); x=column; %Number of columns

if(x>colNum) %Error message for going outside of column bounds
    disp('ERROR: column number exceeds number of columns in image');
    return;
end

tmpIm = image;

for y=1:SZ(1)
    tmpIm(y,x,1) = 0;
    tmpIm(y,x,2) = 0;
    tmpIm(y,x,3) = 0;
    tmpIm(y,x,RGB) = 1;
end

imshow(tmpIm);
end