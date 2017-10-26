function [psi,rho,ang] = rootCylCoord(x,y,z,muX,muY,muZ,S)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
totDis = 0;
for i=2:y
    dist=sqrt(1+((S(i,1)-S(i-1,1)).^2)+((S(i,2)-S(i-1,2)).^2));
    totDis = totDis+dist;
end
 
psi=muX*totDis;
if(y<=0)
    psi = NaN;
    rho = NaN;
    ang = NaN;
    return;
end
Sx = S(y+1,1);
Sy = S(y+1,2);
 
rho=sqrt(((muX*(x-Sx)).^2)+((muZ*z-muX*Sy).^2));
ang=atan((muZ-muX*Sy)/(muX*(x-Sx)));
 
end