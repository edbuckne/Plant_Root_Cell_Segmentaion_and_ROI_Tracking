function [ Etot,dVmag,ddVmag ] = acEnergy( As, S, Iexe, alpha, beta, We )
N = size(As,1);
halfN = round(N/2);
sI = size(Iexe);

%Internal Energy
if~(S==1||S==(halfN+1))
    dV = As(S,:)-As(S-1,:);
    if~(S==N||S==halfN)
        ddV = As(S-1,:)-2.*As(S,:)+As(S+1,:);
    elseif(S==halfN)
        beta = 0;
        ddV = As(halfN-1,:)-2.*As(halfN,:)+As(N,:);
    else %S==N
        beta = 0;
        ddV = As(N-1,:)-2.*As(N,:)+As(halfN,:);
    end
else
    if(S==1)
        dV = As(1,:)-[sI(2)/2 sI(1)/2];
        alpha = alpha/5;
        ddV = As(halfN+1,:)-2.*As(1,:)+As(2,:);
    elseif(S==halfN+1) %S==halfN+1
        dV = As(S,:)-[sI(2)/2 sI(1)/2];
        alpha = alpha/5;
        ddV = As(1,:)-2.*As(halfN+1,:)+As(halfN+2,:);
    end
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

