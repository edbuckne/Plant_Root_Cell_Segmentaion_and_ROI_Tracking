function [ As ] = acSeg( Ibfp, Ns, alpha, beta, We, IT, showStr )
%Ibfp - Image to be segmented
%Ns - Number of spline points on the active contour
%alpha - Elasticity coefficient (0.1 works well)
%beta - Rigidity coefficient (0.1 works well)
%We - External energy weight (500-1200 works well)
%IT - Number of iterations

sigma = 6;
poiN = [0 -1; 1 -1; 1 0; 1 1; 0 1; -1 1; -1 0; -1 -1];

As = zeros(Ns,2); %Initialize contour
sI = size(Ibfp); %Size of image in pixels

%Find points for contour
Pix = 2*sI(2)+sI(1)-2; %Number of pixels around the edges
delPix = round(Pix/Ns); %Pixel interval

%Creates an open contour around the edges of the image
state = 1; %Start left
xd = 1;
yd = 1;
for s=1:Ns*2
    As(s,:) = [xd,yd];
    switch state
        case 1 %Left side
            if(yd+delPix<=sI(1))
                yd = yd+delPix;
            else
                xd = xd+delPix;
                state = 2;
            end
        case 2 %Bottom
            if(xd+delPix<=sI(2))
                xd = xd+delPix;
            else
                yd = yd-delPix;
                state = 3;
            end
        case 3 %Right side
            if(yd-delPix>=1)
                yd = yd-delPix;
            else
                As(s,:) = [sI(2),1];
                break;
            end
    end
end

%Have the order stem from the bottom of the image
N = size(As,1);
halfN = round(N/2);
newAs = zeros(halfN,2);
j=halfN;
for i=1:round(N/2)
    newAs(i,:) = As(j,:);
    j=j-1;
end
As(1:halfN,:) = newAs; %Flip the beginning

% Creating the external energy image
Ifilt = imgaussfilt(Ibfp,sigma);
[Gmag,~] = imgradient(Ifilt);
Iexe = 1./(1+Gmag.^2);
minp = min(Iexe(:));
Iexe = Iexe-minp;
maxp = max(Iexe(:));
Iexe = Iexe./maxp;
Ilog = 1-Iexe;
Ilog2 = im2bw(Ilog,0.015);
for x=1:sI(2)
    for y=1:sI(1)
        if(Ilog2(y,x)==0)
            Iexe(y,x)=1;
        end
    end
end

for i=1:IT
    for s=1:N
        Ad = As; %Create a dynamic list that can change
        Emin = acEnergy(As,s,Iexe,alpha,beta,We); %Obtain the energy of the static list
        ind = 0;
        if (s==halfN||s==N)
            poiN = [0 0; 1 0; 1 0; 1 0; 0 0; -1 0; -1 0; -1 0];
        elseif (s==1||s==halfN+1)
            poiN = [0 -1; 1 -1; 1 0; 1 1; 0 1; -1 1; -1 0; -1 -1];
        elseif (abs(As(s,2)-As(s+1,2))>100)
            poiN = [0 0; 1 0; 1 0; 1 0; 0 0; -1 0; -1 0; -1 0];
        end
        for j=1:8 %Go to each neighbor
            pixMove = As(s,:)+poiN(j,:);
            if(pixMove(1)<=0 || pixMove(2)<=0 || pixMove(1)>=sI(2) || pixMove(2)>=sI(1)) %Can't go beyond the bounds of the image
                continue;
            end
            Ad(s,:) = pixMove;
            E = acEnergy(Ad,s,Iexe,alpha,beta,We); %Obtain the energy of the dynamic list
            if(E<Emin) %If the energy is less, move pixel there
                Emin = E;
                ind = j;
            end
        end
        if (ind>0) %Only if movement has occured, change the static list
            As(s,:) = As(s,:)+poiN(ind,:);
        end
    end
    
end

%Flip the end back the way it was
As2 = As;
newAs = zeros(halfN,2);
j=halfN;
for i=1:round(N/2)
    newAs(i,:) = As2(j,:);
    j=j-1;
end
As(1:halfN,:) = newAs; %Flip the beginning

if(strcmp(showStr,'show')) %Show the result only if prompted to
    figure
    imshow(Ibfp);
    line(As(:,1),As(:,2),'linewidth',2)
end
end

