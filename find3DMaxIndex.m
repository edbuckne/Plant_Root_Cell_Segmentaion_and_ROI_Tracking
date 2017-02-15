function [ X,Y,Z ] = find3DMaxIndex( matrixIn )
s = size(matrixIn);
X = 0;
Y = 0;
Z = 0;

max = 0;
for x=2:s(2)-1
    for y=2:s(1)-1
        for z=2:s(3)-1
            if (matrixIn(y,x,z)>max)
                X = x;
                Y = y;
                Z = z;
                max = matrixIn(y,x,z);
            end
        end
    end
end
end

