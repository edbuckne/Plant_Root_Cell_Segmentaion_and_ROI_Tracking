function [ D ] = disMat( seg3D1, seg3D2, T12 )
s1 = size(seg3D1);
s2 = size(seg3D2);

CL1 = [seg3D1(:,2:4)'; ones(1,s1(1))];
CL2 = [seg3D2(:,2:4)'; ones(1,s2(1))];
CL2t = T12*CL2;
D = zeros(s1(1),s2(1));

for i=1:s1(1)
    for j=1:s2(1)
        D(i,j) = sqrt((CL1(1,i)-CL2t(1,j))^2+(CL1(2,i)-CL2t(2,j))^2+(CL1(3,i)-CL2t(3,j))^2);
    end
end

end

