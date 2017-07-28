function [s] = surfaceRec3( ACV1,ACV2,n )
%Surface reconstruction of root using contour points
%   Keeps every nth point during revision
%   Outputs figure(f) and array of middle points(s)
 
%Assign values
gx1=ACV1(1,:);
gy1=ACV1(3,:);
gz1=ACV1(2,:);
gx2=ACV2(3,:);
gy2=ACV2(1,:);
gz2=ACV2(2,:);
 
%Length must be the same
if length(gx1)>length(gx2)
    while length(gx1)>length(gx2)
     gx1=gx1(:,2:end-1);
     gy1=gy1(:,2:end-1);
     gz1=gz1(:,2:end-1); 
    end
else if length(gx2)>length(gx1)
     while length(gx2)>length(gx1)
     gx2=gx2(:,2:end-1);
     gy2=gy2(:,2:end-1);
     gz2=gz2(:,2:end-1);     
     end
    else 
        gx1=gx1;
        gx2=gx2;
    end
end
plot3(gx1,gy1,gz1); %Contour 1
hold on
plot3(gx2,gy2,gz2); %Contour 2
axis([-1920/2 1920/2 -1920/2 1920/2 -20 1920])
 
if mod(length(gx1),2)==0
    %X
    gx1=gx1';
    gx1=reshape(gx1,[length(gx1)/2 2]);
    gx1(:,2)=flipud(gx1(:,2));
    gx11=[gx1((1:n:length(gx1)),:)];
    if gx1(end,:)==gx11(end,:)
       gx11=gx11;
    else
        for i=1:length(gx1)
            if gx1(i,1)==gx11(end,1)&& gx1(i,2)==gx11(end,2)
               k=i(end);
            end
        end
        gx11=[gx11; gx1(k(end)+1:end,:)];
    end
    gx11(:,2)=flipud(gx11(:,2));
    gx11=reshape(gx11,[],1);
    gx11=gx11';
    gx2=gx2';
    gx2=reshape(gx2,[length(gx2)/2 2]);
    gx2(:,2)=flipud(gx2(:,2));
    gx21=[gx2((1:n:length(gx2)),:)];
    if gx2(end,:)==gx21(end,:)
       gx21=gx21;
    else
        for i=1:length(gx2)
            if gx2(i,1)==gx21(end,1)&& gx2(i,2)==gx21(end,2)
               k=i(end);
            end
        end
        gx21=[gx21; gx2(k(end)+1:end,:)];
    end
    gx21(:,2)=flipud(gx21(:,2));
    gx21=reshape(gx21,[],1);
    gx21=gx21';
    %Y
    gy1=gy1';
    gy1=reshape(gy1,[length(gy1)/2 2]);
    gy1(:,2)=flipud(gy1(:,2));
    gy11=[gy1((1:n:length(gy1)),:)];
    if gy1(end,:)==gy11(end,:)
       gy11=gy11;
    else
        for i=1:length(gy1)
            if gy1(i,1)==gy11(end,1)&& gy1(i,2)==gy11(end,2)
               k=i(end);
            end
        end
        gy11=[gy11; gy1(k(end)+1:end,:)];
    end
    gy11(:,2)=flipud(gy11(:,2));
    gy11=reshape(gy11,[],1);
    gy11=gy11';
    gy2=gy2';
    gy2=reshape(gy2,[length(gy2)/2 2]);
    gy2(:,2)=flipud(gy2(:,2));
    gy21=[gy2((1:n:length(gy2)),:)];
    if gy2(end,:)==gy21(end,:)
       gy21=gy21;
    else
        for i=1:length(gy2)
            if gy2(i,1)==gy21(end,1)&& gy2(i,2)==gy21(end,2)
               k=i(end);
            end
        end
        gy21=[gy21; gy2(k(end)+1:end,:)];
    end
    gy21(:,2)=flipud(gy21(:,2));
    gy21=reshape(gy21,[],1);
    gy21=gy21';
    %Z
    gz1=gz1';
    gz1=reshape(gz1,[length(gz1)/2 2]);
    gz1(:,2)=flipud(gz1(:,2));
    gz11=[gz1((1:n:length(gz1)),:)];
    if gz1(end,:)==gz11(end,:)
       gz11=gz11;
    else
        for i=1:length(gz1)
            if gz1(i,1)==gz11(end,1)&& gz1(i,2)==gz11(end,2)
               k=i(end);
            end
        end
        gz11=[gz11; gz1(k(end)+1:end,:)];
    end
    gz11(:,2)=flipud(gz11(:,2));
    gz11=reshape(gz11,[],1);
    gz11=gz11';
    gz2=gz2';
    gz2=reshape(gz2,[length(gz2)/2 2]);
    gz2(:,2)=flipud(gz2(:,2));
    gz21=[gz2((1:n:length(gz2)),:)];
    if gz2(end,:)==gz21(end,:)
       gz21=gz21;
    else
        for i=1:length(gz2)
            if gz2(i,1)==gz21(end,1)&& gz2(i,2)==gz21(end,2)
               k=i(end);
            end
        end
        gz21=[gz21; gz2(k(end)+1:end,:)];
    end
    gz21(:,2)=flipud(gz21(:,2));
    gz21=reshape(gz21,[],1);
    gz21=gz21';
else 
    %X
    gx1=gx1';
    mgx1=gx1(round((length(gx1)/2)));
    gx1(mgx1)=[];
    gx1=reshape(gx1,[length(gx1)/2 2]);
    gx1(:,2)=flipud(gx1(:,2));
    gx11=[gx1((1:n:length(gx1)),:)];
    if gx1(end,:)==gx11(end,:)
       gx11=gx11;
    else
        for i=1:length(gz1)
            if gx1(i,1)==gx11(end,1)&& gx1(i,2)==gx11(end,2)
               k=i(end);
            end
        end
        gx11=[gx11; gx1(k(end)+1:end,:)];
    end
    gx11=reshape(gx11,[],1);
    gx11=gx11';
    gx11=[gx11(length(gx11)/2) mgx1 gx11((length(gx11)/2)+1:end)];
    gx2=gx2';
    mgx2=gx2(round((length(gx2)/2)));
    gx2(mgx2)=[];
    gx2=reshape(gx2,[length(gx2)/2 2]);
    if gx2(end,:)==gx21(end,:)
       gx21=gx21;
    else
        for i=1:length(gx2)
            if gx2(i,1)==gx21(end,1)&& gx2(i,2)==gx21(end,2)
               k=i(end);
            end
        end
        gx21=[gx21; gx2(k(end)+1:end,:)];
    end
    gx2(:,2)=flipud(gx2(:,2));
    gx21=[gx2((1:n:length(gx2)),:)];
    gx21(:,2)=flipud(gx21(:,2));
    gx21=reshape(gx21,[],1);
    gx21=gx21';
    gx21=[gx21(length(gx21)/2) mgx2 gx21((length(gx21)/2)+1:end)];
    %Y
    gy1=gy1';
    mgy1=gy1(round((length(gy1)/2)));
    gy1(mgy1)=[];
    gy1=reshape(gy1,[length(gy1)/2 2]);
    gy1(:,2)=flipud(gy1(:,2));
    gy11=[gy1((1:n:length(gy1)),:)];
    if gy1(end,:)==gy11(end,:)
       gy11=gy11;
    else
        for i=1:length(gy1)
            if gy1(i,1)==gy11(end,1)&& gy1(i,2)==gy11(end,2)
               k=i(end);
            end
        end
        gy11=[gy11; gy1(k(end)+1:end,:)];
    end
    gy11(:,2)=flipud(gy11(:,2));
    gy11=reshape(gy11,[],1);
    gy11=gy11';
    gy11=[gy11(length(gy11)/2) mgy1 gy11((length(gy11)/2)+1:end)];
    gy2=gy2';
    mgy2=gy2(round((length(gy2)/2)));
    gy2(mgy2)=[];
    gy2=reshape(gy2,[length(gy2)/2 2]);
    gy2(:,2)=flipud(gy2(:,2));
    gy21=[gy2((1:n:length(gy2)),:)];
    if gy2(end,:)==gy21(end,:)
       gy21=gy21;
    else
        for i=1:length(gy2)
            if gy2(i,1)==gy21(end,1)&& gy2(i,2)==gy21(end,2)
               k=i(end);
            end
        end
        gy21=[gy21; gy2(k(end)+1:end,:)];
    end
    gy21(:,2)=flipud(gy21(:,2));
    gy21=reshape(gy21,[],1);
    gy21=gy21';
    gy21=[gy21(length(gy21)/2) mgy2 gy21((length(gy21)/2)+1:end)];
    %Z
    gz1=gz1';
    mgz1=gz1(round((length(gz1)/2)));
    gz1(mgz1)=[];
    gz1=reshape(gz1,[length(gz1)/2 2]);
    gz1(:,2)=flipud(gz1(:,2));
    gz11=[gz1((1:n:length(gz1)),:)];
    if gz1(end,:)==gz11(end,:)
       gz11=gz11;
    else
        for i=1:length(gz1)
            if gz1(i,1)==gz11(end,1)&& gz1(i,2)==gz11(end,2)
               k=i(end);
            end
        end
        gz11=[gz11; gz1(k(end)+1:end,:)];
    end
    gz11=reshape(gz11,[],1);
    gz11=gz11';
    gz11=[gz11(length(gz11)/2) mgz1 gz11((length(gz11)/2)+1:end)];
    gz2=gz2';
    mgz2=gz2(round((length(gz2)/2)));
    gz2(mgz2)=[];
    gz2=reshape(gz2,[length(gz2)/2 2]);
    gz2(:,2)=flipud(gz2(:,2));
    gz21=[gz2((1:n:length(gz2)),:)];
    if gz2(end,:)==gz21(end,:)
       gz21=gz21;
    else
        for i=1:length(gz2)
            if gz2(i,1)==gz21(end,1)&& gz2(i,2)==gz21(end,2)
               k=i(end);
            end
        end
        gz21=[gz21; gz2(k(end)+1:end,:)];
    end
    gz21(:,2)=flipud(gz21(:,2));
    gz21=reshape(gz21,[],1);
    gz21=gz21';
    gz21=[gz21(length(gz21)/2) mgz2 gz21((length(gz21)/2)+1:end)];
end
 
for i=1:length(gx1);
%Find the 4 points that lie on the same z plane
idx1=find(gz1==gz1(i));
epx1=gx1(idx1);
epy1=gy1(idx1);
epz1=gz1(idx1);
idx2=find(gz1==gz1(i));
epx2=gx1(idx2);
epy2=gy1(idx2);
epz2=gz1(idx2);
epoint1=[epx1(1),epy1(1),epz1(1)];
epoint2=[epx2(1),epy2(1),epz2(1)];
epoint3=[epx1(2),epy1(2),epz1(2)];
epoint4=[epx2(2),epy2(2),epz2(2)];
epoints=[epoint1' epoint2' epoint3' epoint4'];
 
%Find every center point
ecxpoint=(epx1(1)+epx1(2)+epx2(1)+epx2(2))./4;
ecypoint=(epy1(1)+epy1(2)+epy2(1)+epy2(2))./4;
eczpoint=(epz1(1)+epz1(2)+epz2(1)+epz2(2))./4;
ecpoint=[ecxpoint,ecypoint,eczpoint];
S(i,:,:)=[ecxpoint,ecypoint,eczpoint];
plot3(ecxpoint,ecypoint,eczpoint,'.');
end
s=S;
return;
 
for i=1:length(gx11);
%Find the 4 points that lie on the same z plane
idx1=find(gz11==gz11(i));
px1=gx11(idx1);
py1=gy11(idx1);
pz1=gz11(idx1);
idx2=find(gz21==gz21(i));
px2=gx21(idx2);
py2=gy21(idx2);
pz2=gz21(idx2);
point1=[px1(1),py1(1),pz1(1)];
point2=[px2(1),py2(1),pz2(1)];
point3=[px1(2),py1(2),pz1(2)];
point4=[px2(2),py2(2),pz2(2)];
points=[point1' point2' point3' point4'];
%fill3(points(1,:),points(2,:),points(3,:),'r')
%alpha(0.1)
 
%Find center point
cxpoint=(px1(1)+px1(2)+px2(1)+px2(2))./4;
cypoint=(py1(1)+py1(2)+py2(1)+py2(2))./4;
czpoint=(pz1(1)+pz1(2)+pz2(1)+pz2(2))./4;
cpoint=[cxpoint,cypoint,czpoint];
%plot3(cxpoint,cypoint,czpoint,'.');
 
 
npoint1=point1-cpoint;
npoint2=point2-cpoint;
npoint3=point3-cpoint;
npoint4=point4-cpoint;
npoints=[npoint1' npoint2' npoint3' npoint4'];
 
%Interpolation
[theta,rho]=cart2pol(npoints(1,:),npoints(2,:));
theta=theta';
rho=rho';
viewPP=[theta,rho];
viewPP=sortrows(viewPP,1);
viewPP=[viewPP(4,1)-2*pi viewPP(4,2);viewPP];
viewPP=[viewPP; viewPP(2,1)+2*pi viewPP(2,2)];
(2*pi)/16;
ntheta=-pi:ans:pi;
for j=1:length(ntheta)
    nrho(j)=interp1(viewPP(:,1)',viewPP(:,2)',ntheta(j));
end
x=nrho.*cos(ntheta);
y=nrho.*sin(ntheta);
 
x=x+cpoint(1);
y=y+cpoint(2);
newz(1,1:length(x))=gz11(i);
 
%plot3(x,y,newz,'.b'); %Interpolation points
 
 
    A(i,:,:)=[x(1),y(1),gz11(i)];
    B(i,:,:)=[x(2),y(2),gz11(i)];
    C(i,:,:)=[x(3),y(3),gz11(i)];
    D(i,:,:)=[x(4),y(4),gz11(i)];
    E(i,:,:)=[x(5),y(5),gz11(i)];
    F(i,:,:)=[x(6),y(6),gz11(i)];
    G(i,:,:)=[x(7),y(7),gz11(i)];
    H(i,:,:)=[x(8),y(8),gz11(i)];
    I(i,:,:)=[x(9),y(9),gz11(i)];
    J(i,:,:)=[x(10),y(10),gz11(i)];
    K(i,:,:)=[x(11),y(11),gz11(i)];
    L(i,:,:)=[x(12),y(12),gz11(i)];
    M(i,:,:)=[x(13),y(13),gz11(i)];
    O(i,:,:)=[x(14),y(14),gz11(i)];
    P(i,:,:)=[x(15),y(15),gz11(i)];
    Q(i,:,:)=[x(16),y(16),gz11(i)];
    R(i,:,:)=[x(17),y(17),gz11(i)]; 
    
end
 
%Remove half the points which are duplicates
A=[A(1:length(A)/2,1),A(1:length(A)/2,2),A(1:length(A)/2,3)];
B=[B(1:length(B)/2,1),B(1:length(B)/2,2),B(1:length(B)/2,3)];
C=[C(1:length(C)/2,1),C(1:length(C)/2,2),C(1:length(C)/2,3)];
D=[D(1:length(D)/2,1),D(1:length(D)/2,2),D(1:length(D)/2,3)];
E=[E(1:length(E)/2,1),E(1:length(E)/2,2),E(1:length(E)/2,3)];
F=[F(1:length(F)/2,1),F(1:length(F)/2,2),F(1:length(F)/2,3)];
G=[G(1:length(G)/2,1),G(1:length(G)/2,2),G(1:length(G)/2,3)];
H=[H(1:length(H)/2,1),H(1:length(H)/2,2),H(1:length(H)/2,3)];
I=[I(1:length(I)/2,1),I(1:length(I)/2,2),I(1:length(I)/2,3)];
J=[J(1:length(J)/2,1),J(1:length(J)/2,2),J(1:length(J)/2,3)];
K=[K(1:length(K)/2,1),K(1:length(K)/2,2),K(1:length(K)/2,3)];
L=[L(1:length(L)/2,1),L(1:length(L)/2,2),L(1:length(L)/2,3)];
M=[M(1:length(M)/2,1),M(1:length(M)/2,2),M(1:length(M)/2,3)];
O=[O(1:length(O)/2,1),O(1:length(O)/2,2),O(1:length(O)/2,3)];
P=[P(1:length(P)/2,1),P(1:length(P)/2,2),P(1:length(P)/2,3)];
Q=[Q(1:length(Q)/2,1),Q(1:length(Q)/2,2),Q(1:length(Q)/2,3)];
R=[R(1:length(R)/2,1),R(1:length(R)/2,2),R(1:length(R)/2,3)];
 
 
A=reshape(A,[],3);
B=reshape(B,[],3);
C=reshape(C,[],3);
D=reshape(D,[],3);
E=reshape(E,[],3);
F=reshape(F,[],3);
G=reshape(G,[],3);
H=reshape(H,[],3);
I=reshape(I,[],3);
J=reshape(J,[],3);
K=reshape(K,[],3);
L=reshape(L,[],3);
M=reshape(M,[],3);
O=reshape(O,[],3);
P=reshape(P,[],3);
Q=reshape(Q,[],3);
S=reshape(S,[],3);
 
%Flips the data from top to bottom
I=flipud(I);
J=flipud(J);
K=flipud(K);
L=flipud(L);
M=flipud(M);
O=flipud(O);
P=flipud(P);
Q=flipud(Q);
S=flipud(S);
 
%Combine points of parrallel lines
li1=vertcat(A,I);
li2=vertcat(B,J);
li3=vertcat(C,K);
li4=vertcat(D,L);
li5=vertcat(E,M);
li6=vertcat(F,O);
li7=vertcat(G,P);
li8=vertcat(H,Q);
lines=[li1' li2' li3' li4' li5' li6' li7' li8'];
 
% plot3(li1(:,1),li1(:,2),li1(:,3))
% plot3(li2(:,1),li2(:,2),li2(:,3))
% plot3(li3(:,1),li3(:,2),li3(:,3))
% plot3(li4(:,1),li4(:,2),li4(:,3))
% plot3(li5(:,1),li5(:,2),li5(:,3))
% plot3(li6(:,1),li6(:,2),li6(:,3))
% plot3(li7(:,1),li7(:,2),li7(:,3))
% plot3(li8(:,1),li8(:,2),li8(:,3))
 
 
allX=vertcat(gx11,gx21,li1(:,1)',li2(:,1)',li3(:,1)',li4(:,1)',li5(:,1)',li6(:,1)',li7(:,1)',li8(:,1)');
allY=vertcat(gy11,gy21,li1(:,2)',li2(:,2)',li3(:,2)',li4(:,2)',li5(:,2)',li6(:,2)',li7(:,2)',li8(:,2)');
allZ=vertcat(gz11,gz21,li1(:,3)',li2(:,3)',li3(:,3)',li4(:,3)',li5(:,3)',li6(:,3)',li7(:,3)',li8(:,3)');
allX=reshape(allX,1,[]);
allY=reshape(allY,1,[]);
allZ=reshape(allZ,1,[]);
allX=allX';
allY=allY';
allZ=allZ';
dt=delaunayTriangulation(allX,allY,allZ);
faceColor=[0.6875 0.8750 0.8984];
f = figure;
s=S;
%tetramesh(dt,'LineStyle','none','FaceColor',faceColor, 'FaceAlpha',0.3);
 
hold off
 
 end