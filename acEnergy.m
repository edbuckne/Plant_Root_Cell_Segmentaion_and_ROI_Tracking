function [ Etot,dVmag,ddVmag ] = acEnergy( As, S, Iexe, alpha, beta, We )
N = size(As,1);
WeM = 100000;

%Internal Energy
if~(S==1)
    dV = As(S,:)-As(S-1,:);
    if~(S==N)
        ddV = As(S-1,:)-2.*As(S,:)+As(S+1,:);
    else
        We = WeM;
        ddV = As(S-1,:)-2.*As(S,:)+As(1,:);
    end
else
    We = WeM;
    dV = As(S,:)-As(N,:);
    ddV = As(N,:)-2.*As(S,:)+As(S+1,:);
end



dVmag = dV(1)^2+dV(2)^2;
ddVmag = ddV(1)^2+ddV(2)^2;

Eint = alpha.*dVmag+beta*ddVmag;

%External energy
X = As(S,1);
Y = As(S,2);

Eext = We*Iexe(Y,X);

%Total Energy
Etot = Eint+Eext;
end

