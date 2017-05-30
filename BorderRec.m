function [ AC_Reconstruction_1, AC_Reconstruction_2 ] = BorderRec( ACP1, ACP2 )

[maxY1,maxI1] = max(ACP1(2,:));
maxX1 = ACP1(1,maxI1); %The origin of ACP1

[maxY2,maxI2] = max(ACP2(2,:));
maxX2 = ACP2(1,maxI2); %The origin of ACP1

for rec=1:2 %2 90 degree views
    if(rec==1)
        Ylim = maxY1;
        Blist = ACP1;
        Blist(1,:) = Blist(1,:)-maxX1; %Shift everything to the origin
    else
        Ylim = maxY2;
        Blist = ACP2;
        Blist(1,:) = Blist(1,:)-maxX2; %Shift everything to the origin
    end
    
    state = 1; %State 1 is left side, state 2 is right side
    j=1;
    
    ALlist = ones(3,Ylim);
    ARlist = ones(3,Ylim-1);
    
    for k=1:Ylim-1 %Initiate the y coordinates
        ALlist(2,k) = k;
        ARlist(2,k) = k;
    end
    ALlist(2,k+1) = k+1;
    
    while(state==1) %Left side
        i = Blist(2,j); %Get the first y coordinate in the Blist (It will be 1);
        for j=1:size(Blist,2)-1
            while~(i==Blist(2,j+1))
                if(i<Blist(2,j+1)) %Continue adding
                    ALlist(1,i) = interp1([Blist(2,j) Blist(2,j+1)],[Blist(1,j) Blist(1,j+1)],i);
                elseif(i==Blist(2,j+1)) %Quit adding and go to next j
                    ALlist(1,i) = Blist(1,j);
                else
                    break;
                end
                i=i+1;
                if(i>Ylim)
                    break;
                end
            end
            if(i>=Ylim)
                state=2;
                ALlist(1,Ylim) = Blist(1,j+1);
                break;
            end
        end
    end
    
    i=i-1;
    while(state==2) %Right side
        for j=j:size(Blist,2)-1
            while~(i==Blist(2,j+1))
                if(i>Blist(2,j+1)) %Continue subtracting
                    ARlist(1,i) = interp1([Blist(2,j+1) Blist(2,j)],[Blist(1,j+1) Blist(1,j)],i);
                elseif(i==Blist(2,j+1)) %Quit subtracting and go to next j
                    ARlist(1,i) = Blist(1,j);
                    break;
                else
                    break;
                end
                i=i-1;
                if(i<=1)
                    break;
                end
            end
            if(i<=1)
                state=1;
                ARlist(1,1) = ARlist(1,j+1);
                break;
            end
        end
    end
    
    k=size(ARlist,2);
    ARlist4 = ARlist;
    for i=1:size(ARlist,2)
        ARlist4(:,i) = ARlist(:,k);
        k=k-1;
    end
    ARlist3 = ARlist4;
   
    %Creating the midline
    MidLine = ones(3,Ylim-1); %Contains the midline of the root
    
    for i=1:Ylim-1
        MidLine(2,i) = i;
        MidLine(1,i) = (ALlist(1,i)+ARlist(1,i))/2; %Average line
    end
    
    MidLine(2,:) = Ylim-MidLine(2,:);
    if(rec==1)
        AClist1 = [ALlist(1,:) ARlist3(1,:); ALlist(2,:) ARlist3(2,:)];
        MidLine1 = MidLine;
    else
        AClist2 = [ALlist(1,:) ARlist3(1,:); ALlist(2,:) ARlist3(2,:)];
        MidLine2 = MidLine;
    end
end
    
    for rec=1:2
        if(rec==1)
            Ylim = maxY2;
            AC_Reconstruction = AClist1;
            MidLine = MidLine2;
        else
            Ylim = maxY1;
            AC_Reconstruction = AClist2;
            MidLine = MidLine1;
        end
        
        s = size(AC_Reconstruction,2);
        AC_Reconstruction = [AC_Reconstruction; ones(1,s)]; %Add a row of ones below( this is where midline will be put)
        
        for i=1:s
            if(AC_Reconstruction(2,i)>=Ylim)
                AC_Reconstruction(3,i) = AC_Reconstruction(3,i-1);
                continue;
            end
            AC_Reconstruction(3,i) = MidLine(1,AC_Reconstruction(2,i));
        end
        if(rec==1)
            AC_Reconstruction_1 = AC_Reconstruction;
            figure
            plot3(AC_Reconstruction_1(1,:),AC_Reconstruction_1(3,:),maxY1-AC_Reconstruction_1(2,:));
            hold on
        else
            AC_Reconstruction_2 = AC_Reconstruction;
            plot3(AC_Reconstruction_2(3,:),AC_Reconstruction_2(1,:),maxY2-AC_Reconstruction_2(2,:));
        end
    end
end

