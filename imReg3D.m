function [ T ] = imReg3D( Istin, Idyin )
minValxy = 1e9;
minOffsetxy = [0 0];
tr = 0;

disp('Registering xy projection images');

ss = size(Istin);
sd = size(Idyin);
ssT = ss(1)*ss(2);
sdT = sd(1)*sd(2);
if(ssT>sdT) %We always want the bigger image to be the shifted one
    Itmp = Idyin;
    Idyin = Istin;
    Istin = Itmp;
    tr = 1;
    ss = size(Istin); %Recalculate sizes
    sd = size(Idyin);
end

s = [max([ss(1) sd(1)]) max([ss(2) sd(2)])];

Ist = zeros(s);
Ist(1:ss(1),1:ss(2)) = Istin;
Idy = zeros(s);
Idy(1:sd(1),1:sd(2)) = Idyin;

disp('Iteration 1');
%Iteration 1
for m = int16(-s(2)/10:5:s(2)/10)
    for n = int16(-s(1)/2:50:s(1)/2)
        Ir = imtranslate(Idy,[m,n]);
        A = (Ist-Ir).^2;
        A = sum(A(:));
        if(A<minValxy)
            minValxy=A;
            minOffsetxy = [m,n];
        end
    end
end

%Iteration 2
disp('Iteration 2');
for m = minOffsetxy(1)-5:2:minOffsetxy(1)+5
    for n = minOffsetxy(2)-100:10:minOffsetxy(2)+100
        Ir = imtranslate(Idy,[m,n]);
        A = (Ist-Ir).^2;
        A = sum(A(:));
        if(A<minValxy)
            minValxy=A;
            minOffsetxy = [m,n];
        end
    end
end

%Iteration 3
disp('Iteration 3');
for m = minOffsetxy(1)-2:minOffsetxy(1)+2
    for n = minOffsetxy(2)-10:minOffsetxy(2)+10
        Ir = imtranslate(Idy,[m,n]);
        A = (Ist-Ir).^2;
        A = sum(A(:));
        if(A<minValxy)
            minValxy=A;
            minOffsetxy = [m,n];
        end
    end
end

minOffsetxy = double(minOffsetxy);
if(tr==1)
    minOffsetxy(1)=-minOffsetxy(1);
    minOffsetxy(2)=-minOffsetxy(2);
end
T = [1 0 -minOffsetxy(1); 0 1 -minOffsetxy(2); 0 0 1]; %minOffsetxz(2) is the z transform (Ignoring for now)
end

