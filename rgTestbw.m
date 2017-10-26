function [ Irg, ch_ls ] = rgTestbw( I, x, y )
ch_ls = [x y]; %Check list, starts at the x,y start pixel
i = 1; %Index of ch_ls
n_ca = [-1 0; 0 1; 1 0; 0 -1]; %Neighbor list: Left, bottom, right, top

s = size(I); %Get size of image
Irg = zeros(s); %Final image that holds the segmented area

while i<=size(ch_ls,1)
    for p=1:4
        pn = ch_ls(i,:)+n_ca(p,:); %Go to a neighbor
        if(pn(1)<1||pn(1)>s(2)||pn(2)<1||pn(2)>s(1))
            continue;
        end
        if(I(pn(2),pn(1))&&~Irg(pn(2),pn(1))) %Make sure that it has neighbors that can be candidates
            ch_ls = [ch_ls; pn]; %Add them to the list
            Irg(pn(2),pn(1))=1; %Paint that block white
        end
    end
    i=i+1;
end

end

