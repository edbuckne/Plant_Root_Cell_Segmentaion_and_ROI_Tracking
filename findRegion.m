function [ XX, YY ] = findRegion( logIm, x, y, dir )
    %Variables
    Xdis = 0;
    Ydis = 0;
    thDis = 40;
    XX = x;
    YY = y;
    SC = 1;

    sim = size(logIm); %get the size of the image
    
    LR = 1; %Left right direction, start right
    UD = 1; %Up down direction, start down
    if(dir==1) %North
        while((YY>0)&&(XX>0)&&(XX<sim(2))&&(logIm(YY,XX))==1) %Within the bounds of the image and the region
            if(YY==0) %If y ever goes to the bounds of the image, return
                YY=1;
                return;
            elseif(YY<y-thDis)
                return;    
            end
            if(logIm(YY-1,XX)==1) %If directly above is good, go to that
                YY=YY-1;
                continue;
            elseif(logIm(YY-1,XX+LR)==1) %If diaganol is good, go to that
                YY=YY-1;
                XX=XX+LR;
                continue;
            elseif(logIm(YY-1,XX-LR)==1)
                YY=YY-1;
                XX=XX-LR;
                LR=LR*-1; %Swith directions of left right
                continue;
            elseif(logIm(YY,XX+LR)==1)
                XX=XX+LR;
                continue;
            elseif(logIm(YY,XX-LR)==1&&~(SC==YY))
                XX=XX-LR;
                SC=YY; %Note where the swith occured
                LR=LR*-1;
                continue;
            end
            YY=YY-1;
            break;
        end
    elseif(dir==2) %South
        while((YY<sim(1))&&(XX>0)&&(XX<sim(2))&&(logIm(YY,XX))==1) %Within the bounds of the image and the region
            if(YY==sim(1)) %If y ever goes to the bounds of the image, return
                YY=sim(1);
                return;
            elseif(YY>y+thDis)
                return;
            end
            if(logIm(YY+1,XX)==1) %If directly above is good, go to that
                YY=YY+1;
                continue;
            elseif(logIm(YY+1,XX+LR)==1) %If diaganol is good, go to that
                YY=YY+1;
                XX=XX+LR;
                continue;
            elseif(logIm(YY+1,XX-LR)==1)
                YY=YY+1;
                XX=XX-LR;
                LR=LR*-1; %Swith directions of left right
                continue;
            elseif(logIm(YY,XX+LR)==1)
                XX=XX+LR;
                continue;
            elseif(logIm(YY,XX-LR)==1&&~(SC==YY))
                XX=XX-LR;
                SC=YY; %Note where the swith occured
                LR=LR*-1;
                continue;
            end
            YY=YY+1;
            break;
        end
    elseif(dir==3) %East
        while((XX<sim(2))&&(YY>0)&&(YY<sim(1))&&(logIm(YY,XX))==1) %Within the bounds of the image and the region
            if(XX==sim(2)) %If y ever goes to the bounds of the image, return
                XX=sim(2);
                return;
            elseif(XX>x+thDis)
                return;
            end
            if(logIm(YY,XX+1)==1) %If directly right is good, go to that
                XX=XX+1;
                continue;
            elseif(logIm(YY+UD,XX+1)==1) %If diaganol is good, go to that
                YY=YY+UD;
                XX=XX+1;
                continue;
            elseif(logIm(YY-UD,XX+1)==1)
                YY=YY-UD;
                XX=XX+1;
                UD=UD*-1; %Swith directions of up down
                continue;
            elseif(logIm(YY+UD,XX)==1)
                YY=YY+UD;
                continue;
            elseif(logIm(YY-UD,XX)==1&&~(SC==XX))
                YY=YY-UD;
                SC=XX; %Note where the swith occured
                UD=UD*-1;
                continue;
            end
            XX=XX+1;
            break;
        end
        elseif(dir==4) %West
        while((XX>0)&&(YY>0)&&(YY<sim(1))&&(logIm(YY,XX))==1) %Within the bounds of the image and the region
            if(XX==0) %If y ever goes to the bounds of the image, return
                XX=1;
                return;
            elseif(XX<x-thDis)
                return;
            end
            if(logIm(YY,XX-1)==1) %If directly right is good, go to that
                XX=XX-1;
                continue;
            elseif(logIm(YY+UD,XX-1)==1) %If diaganol is good, go to that
                YY=YY+UD;
                XX=XX-1;
                continue;
            elseif(logIm(YY-UD,XX-1)==1)
                YY=YY-UD;
                XX=XX-1;
                UD=UD*-1; %Swith directions of up down
                continue;
            elseif(logIm(YY+UD,XX)==1)
                YY=YY+UD;
                continue;
            elseif(logIm(YY-UD,XX)==1&&~(SC==XX))
                YY=YY-UD;
                SC=XX; %Note where the swith occured
                UD=UD*-1;
                continue;
            end
            XX=XX-1;
            break;
        end
    end

end

