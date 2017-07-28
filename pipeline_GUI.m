function varargout = pipeline_GUI(varargin)
% PIPELINE_GUI MATLAB code for pipeline_GUI.fig
%      PIPELINE_GUI, by itself, creates a new PIPELINE_GUI or raises the existing
%      singleton*.
%
%      H = PIPELINE_GUI returns the handle to a new PIPELINE_GUI or the handle to
%      the existing singleton*.
%
%      PIPELINE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PIPELINE_GUI.M with the given input arguments.
%
%      PIPELINE_GUI('Property','Value',...) creates a new PIPELINE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pipeline_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pipeline_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pipeline_GUI

% Last Modified by GUIDE v2.5 29-Jun-2017 16:39:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pipeline_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @pipeline_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before pipeline_GUI is made visible.
function pipeline_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pipeline_GUI (see VARARGIN)

% Choose default command line output for pipeline_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pipeline_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pipeline_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.SPMNum.Value


% --- Executes on button press in SEG.
function SEG_Callback(hObject, eventdata, handles)
% hObject    handle to SEG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%This section looks at each set of GFP images, segments the regions
mkdir 3D_SEG
load('data_config');
disp('Segmenting GFP cluster information');
clInfo = []; %Holds the information concerning the activity location 
zStacks = zeros(tmEnd-tmStart+1,3);
timeArray = zeros(tmEnd-tmStart+1,2);
for t=tmStart:tmEnd
    disp(['Evaluating time stamp ' num2str(t)])
    tmStr = num2str(t,'%.4u'); %Create a new directory to put the segmented images in
    mkdir([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/TM' tmStr]);
    
    [I,zNum] = microImInputRaw(spm,t,1,1); %Get the images
    zStacks(t,:) = [size(I,1) size(I,2) zNum];
    [Ireg,CL] = gseg3(I,TH(t),8,xyratz); %Segment the regions
    CLnum = size(CL);
    clInfo = [clInfo; CL zeros(CLnum(1),1)+t];
    timeArray(t,:) = [size(clInfo,1)-size(CL,1)+1 size(clInfo,1)];
    for z=1:zStacks(t,3)
        imwrite(Ireg(:,:,z),[pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/TM' tmStr '/SEG_IM.tif'],'writemode','append');
    end
end
save([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/cell_location_information'],'clInfo','timeArray');
save('zStacks','zStacks');


% --- Executes on button press in MEASCHAR.
function MEASCHAR_Callback(hObject, eventdata, handles)
% hObject    handle to MEASCHAR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load('data_config');
load('zStacks');

load([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/cell_location_information']);
sCL = size(clInfo);
shapeInfo = zeros(sCL(1),9);
statsTot = zeros(tmEnd-tmStart-1,4);

disp('Doing mathematical shape representation of each cluster');
for t=tmStart:tmEnd
    disp(['Doing measurements on time ' num2str(t)])
    timeTot = 0;
    timeTotCount = 0;
    tmStr = num2str(t,'%.4u');
    
    [I,~] = microImInputRaw(spm,t,1,1); %Get the original image
    sI = size(I);
    Ireg = zeros(sI);
    for z=1:sI(3)
        Ireg(:,:,z) = im2double(imread([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/TM' tmStr '/SEG_IM.tif'],z));
    end
    
    for i=1:sCL(1) %Look at each element
        if~(clInfo(i,10)==t) %Don't consider an element when it's not in the current time stamp
            continue;
        end
        secVal = Ireg(clInfo(i,2),clInfo(i,1),clInfo(i,3)); %Get the value of the section from the COM
        tot = 0; %Used to sum up all pixle values in the region to normalize the curve
        totCount = 0;
        for x=clInfo(i,4):clInfo(i,5)
            for y=clInfo(i,6):clInfo(i,7)
                for z=clInfo(i,8):clInfo(i,9)
                    if(Ireg(y,x,z)==secVal)
                        timeTot = timeTot+I(y,x,z);
                        tot = tot+I(y,x,z);
                        timeTotCount = timeTotCount+1;
                        totCount = totCount+1;
                    end
                end
            end
        end
        
        Ex = clInfo(i,1); %All of the expected values
        Ey = clInfo(i,2); 
        Ez = clInfo(i,3);
        Vx = 0; %Variences
        Vy = 0;
        Vz = 0;
        Cxy = 0; %Covariences
        Cxz = 0;
        Cyz = 0;
        
        Ilog = Ireg==secVal; %Used as a mask for the regions
        Ishape = Ilog.*I; 
        y=clInfo(i,6);
        z=clInfo(i,8);
        for x=clInfo(i,4):clInfo(i,5) %Go through them again getting the covarience information            
            for y=clInfo(i,6):clInfo(i,7)                                
                for z=clInfo(i,8):clInfo(i,9)
                    Vx = Vx+((x-Ex)^2)*Ilog(y,x,z); %V(X)
                    Vy = Vy+((y-Ey)^2)*Ilog(y,x,z); %V(Y)
                    Vz = Vz+((z-Ez)^2)*Ilog(y,x,z); %V(Z)
                    Cxy = Cxy+(x-Ex)*(y-Ey)*Ilog(y,x,z); %C(XY)
                    Cxz = Cxz+(x-Ex)*(z-Ez)*Ilog(y,x,z); %C(XZ)
                    Cyz = Cyz+(y-Ey)*(z-Ez)*Ilog(y,x,z); %C(YZ)
                end
            end
        end
        shapeInfo(i,1) = Vx/totCount; %Vx,Vy,Vz,Cxy,Cxz,Cyz
        shapeInfo(i,2) = Vy/totCount;
        shapeInfo(i,3) = Vz/totCount;
        shapeInfo(i,4) = Cxy/totCount;
        shapeInfo(i,5) = Cxz/totCount;
        shapeInfo(i,6) = Cyz/totCount;
        shapeInfo(i,7) = totCount; %Total number of voxels effected
        shapeInfo(i,8) = tot/totCount; %Average voxel intensity
        shapeInfo(i,9) = tot; %Sum of voxel intensities
         
    end
    statsTot(t,:) = [timeTotCount timeTot/timeTotCount timeTot timeTotCount*(2*xPix+zPix)]; %Total voxels effected, total average, total sum
end
mkdir SHAPE_INFO
save([pwd '/SHAPE_INFO/shape_info'],'shapeInfo','statsTot');



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
cd(eventdata.Source.String)


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
str = get(hObject, 'String');
val = get(hObject,'Value');
showGFP(handles.edit3.Value,[1920 1920],val,0);


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
handles.edit3.Value = str2double(hObject.String);



% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%Begin time
function beginTime_Callback(hObject, eventdata, handles)
handles.beginTime.Value = str2double(hObject.String);

function beginTime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%End time
function endTime_Callback(hObject, eventdata, handles)
handles.endTime.Value = str2double(hObject.String);

function endTime_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Threshold value
function THVal_Callback(hObject, eventdata, handles)
handles.THVal.Value = str2double(hObject.String);

function THVal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Specimen number
function SPMNum_Callback(hObject, eventdata, handles)
handles.SPMNum.Value = str2double(hObject.String);

function SPMNum_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function X_Callback(hObject, eventdata, handles)
% hObject    handle to X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of X as text
%        str2double(get(hObject,'String')) returns contents of X as a double
handles.X.Value = str2double(hObject.String);


% --- Executes during object creation, after setting all properties.
function X_CreateFcn(hObject, eventdata, handles)
% hObject    handle to X (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Y_Callback(hObject, eventdata, handles)
% hObject    handle to Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Y as text
%        str2double(get(hObject,'String')) returns contents of Y as a double
handles.Y.Value = str2double(hObject.String);


% --- Executes during object creation, after setting all properties.
function Y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Z_Callback(hObject, eventdata, handles)
% hObject    handle to Z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Z as text
%        str2double(get(hObject,'String')) returns contents of Z as a double
handles.Z.Value = str2double(hObject.String);


% --- Executes during object creation, after setting all properties.
function Z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SAVE.
function SAVE_Callback(hObject, eventdata, handles)
% hObject    handle to SAVE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spm = handles.SPMNum.Value;
tmStart = handles.beginTime.Value;
tmEnd = handles.endTime.Value;
TH = zeros(tmEnd-tmStart+1,1)+(handles.THVal.Value./255);
xPix = handles.X.Value;
yPix = handles.Y.Value;
zPix = handles.Z.Value;
xyratz = zPix/xPix;
save('data_config','spm','tmStart','tmEnd','TH','xPix','yPix','yPix','zPix','xyratz');


% --- Executes on button press in TRACK.
function TRACK_Callback(hObject, eventdata, handles)
% hObject    handle to TRACK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load data_config
load zStacks

maxDis = zeros(1,3);
maxDis(1) = zStacks(1,1)/5;
maxDis(2) = zStacks(1,2)/2;
maxDis(3) = uint16(zStacks(1,3)/10);

%This section takes the points and executes the point matching image
%registration algorithm
CLt0start = 1; %Indices for cell location and contour points
CLtoend = 0;
CPtostart = 1;
CPtoend = 0;
r = 5;

load([pwd '/3D_SEG/SPM' num2str(spm,'%.2u') '/cell_location_information.mat']); %load the cell location information
% load([pwd '/ROOT_BORDER/Active_Contour_Points.mat']);

sCL = size(clInfo);
timeDiff = tmEnd-tmStart; %How many time points are we looking at?
delSet = zeros(timeDiff,5); %As of right now only looking at the translation

%Find the starting time stamps points
i=CLt0start;
while(clInfo(i,10)==tmStart)
    i=i+1;
end
CLt0end = i-1;

for t=tmStart+1:tmEnd
    minValxz = 1e9;
    disp(['Registering point matching for time ' num2str(t-1) ' to ' num2str(t)]);
    CLt1start = i; %Algorithm on pg. 69 of personal notebook on finding time stamp points
    while(clInfo(i,10)==t && i<sCL(1))
        i=i+1;
    end
    CLt1end = i-1;
    
    CLt0 = clInfo(CLt0start:CLt0end,1:3)'; %All of the t0 COM points
    CLt1 = clInfo(CLt1start:CLt1end,1:3)'; %All of the t1 COM points
    delSet(t-1,1:3) = regPM3D(CLt0,CLt1,r,maxDis,xyratz); %3D point matching image registration
    
    CLt0start = CLt1start; %Next time stamp
    CLt0end = CLt1end;
    
end

mkdir IMAGE_REGISTRATION
save([pwd '/IMAGE_REGISTRATION/delta_set'],'delSet');

mkdir TRACKING
disp('Tracking COM locations')

T = eye(4);
THDist = 40;
i = 1;
s = size(clInfo);

timeArray = zeros(tmEnd-tmStart+1,2); %This holds the time separation info of clInfo 
PC = zeros(s(1),2); %holds the parent/child relationships and their distances

for t=tmStart:tmEnd
    timeArray(t,1) = i; %The beginning pointer of this time stamp
    while(clInfo(i,10)==t && i<s(1))
        i=i+1; %Increment i to continue looking for the end of this time stamp
    end
    if~(i==s(1))
        timeArray(t,2) = i-1;
    else
        timeArray(t,2) = i;
    end
end

i=1;
for t=tmStart:tmEnd-1 %Get the points from the clInfo array
    t0Points = clInfo(timeArray(t,1):timeArray(t,2),1:3)'; %COM points first time point
    t1Points = clInfo(timeArray(t+1,1):timeArray(t+1,2),1:3)'; %COM points second time point
    
    T(1:3,4) = delSet(t,1:3)'; %Transformation matrix
    
    dMat = disMat(t0Points,t1Points,T);
    dSize = size(dMat); %Get the size of the distance matrix
    
    for N=1:dSize(1) %Going through all of the distance matrix
        childI = 0; %Child index
        minDist = 100;
        for M=1:dSize(2)
            if(dMat(N,M)<THDist && abs(t0Points(3,N)-t1Points(3,M))<=abs(T(3,4))+5)
                if(dMat(N,M)<minDist)
                    childI=M;
                    minDist = dMat(N,M);
                end
            end
        end        
        if(childI>0) %We have found a PC relationship
            PC(i,1) = childI+timeArray(t+1)-1;
        else
            PC(i,1)=0;
        end
        i=i+1;
    end
end
for i=1:s(1) %Now find the parents to each 
    found = 0;
    j = 1;
    while(j<=s(1) && ~(PC(j,1)==i))
        j=j+1;
    end
    if~(j>=s(1))
        PC(i,2) = j;
    end
end
save([pwd '/TRACKING/PC_Relationships'],'PC');


% --- Executes on button press in BF.
function BF_Callback(hObject, eventdata, handles)
load('zStacks');
load('data_config');

handles.BF.Value = 1;
I = microImInputRaw(spm,1,2,1);
imshow(I(:,:,round((zStacks(1,3)-1)*handles.ZSTACK.Value+0.5)));


% --- Executes on slider movement.
function ZSTACK_Callback(hObject, eventdata, handles)
load('zStacks');
load('data_config');
% hObject    handle to ZSTACK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.ZSTACK.Value = hObject.Value;
I = microImInputRaw(spm,1,2,1);
imshow(I(:,:,round((zStacks(1,3)-1)*handles.ZSTACK.Value+0.5)));



% --- Executes during object creation, after setting all properties.
function ZSTACK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ZSTACK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
handles.ZSTACK.Value = hObject.Value;


% --- Executes on button press in GFP.
function GFP_Callback(hObject, eventdata, handles)
% hObject    handle to GFP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load('data_config')
load('zStacks')

I = microImInputRaw(spm,1,1,1);
Im = I(:,:,round((zStacks(1,3)-1)*handles.ZSTACK.Value+0.5));
maxp = max(Im(:));
imshow(Im./maxp)