function [ del ] = regPM3D( P, Q, r, maxDis, xyratz )

dxmax = 0; %To keep track of the delta set that created the best transformation
dymax = 0;
dzmax = 0;
Nmax = 0;

T = eye(4); %Transformation matrix

sp = size(P);
sq = size(Q);
Pp = [P; zeros(1,sp(2))+1]; %Insert an all ones row below the cell locations
Qp = [Q; zeros(1,sq(2))+1];

D = zeros(sp(2), sq(2)); %Distance matrix

for dx=-maxDis(1):r:maxDis(1) %First iteration of dx and dy, varying by the radius value
    for dy=-maxDis(2):r:maxDis(2)
        for dz=-maxDis(3):maxDis(3) %The z range is varied by only one because 
            T(1:3,4) = [dx; dy; dz]; %Insert shifts into the transformation matrix
            Qi = T*Qp; %Apply transformation
            for i=1:sp(2)
                D(i,:) = sqrt((Pp(1,i)-Qi(1,:)).^2+(Pp(2,i)-Qi(2,:)).^2+(xyratz*(Pp(3,i)-Qi(3,:))).^2); %Calculating the Distance matrix
            end
            Dl = D<r; %Logical matrix that tells which elements are closer than r
            sd = sum(Dl(:));
            if(sd>Nmax)
                Nmax = sd;
                dxmax = dx;
                dymax = dy;
                dzmax = dz;
            end
        end
    end
end

dxmax2 = dxmax; %Reset parameters for 2nd iteration
dymax2 = dymax;
for dx=dxmax-r:dxmax+r
    for dy=dymax-r:dymax+r
        T(1:3,4) = [dx; dy; dzmax]; %Keep dzmax since it had a step of 1 in the first iteration
        Qi = T*Qp;
        for i=1:sp(2)
            D(i,:) = sqrt((Pp(1,i)-Qi(1,:)).^2+(Pp(2,i)-Qi(2,:)).^2+(xyratz*(Pp(3,i)-Qi(3,:))).^2); %Calculating the Distance matrix
        end
        Dl = D<r; %Logical matrix that tells which elements are closer than r
        sd = sum(Dl(:));
        if(sd>Nmax)
            Nmax = sd;
            dxmax2 = dx;
            dymax2 = dy;
        end
    end
end
del = [-dxmax2 -dymax2 -dzmax];
end

