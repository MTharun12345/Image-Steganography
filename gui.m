function varargout = gui(varargin)
% GUI M-file for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gui_OpeningFcn, ...
    'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible. 
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;
ss=ones(256,256);
axes(handles.axes1);
imshow(ss);
axes(handles.axes2);
imshow(ss);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
% hObject    handle to browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%% read cover image %%%%%%%%
[file,path] = uigetfile('*.png;*.bmp;*.jpg','Pick an Image File');
if isequal(file,0) || isequal(path,0)
    warndlg('No Input Selected');
else
    a = imread(file);
    a=imresize(a,[256 256]);
    [r c p] = size(a);

    %%%%%%%%%%% If it is color image ,convert that to gray......

    if p==3
        a = rgb2gray(a);
    end
   axes(handles.axes1);
    imshow(a);
    handles.a=a;
    guidata(hObject, handles);
end


% --- Executes on button press in modification.
function modification_Callback(hObject, eventdata, handles)
% hObject    handle to modification (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%converting gray level values histogram modification%%%%%%%%%
minvalue=15;
maxvalue=240;
a=handles.a;
[r c]=size(a);
for i=1:r;
    for j=1:c;
        if a(i,j)<=minvalue;
            a(i,j)=minvalue;
        elseif a(i,j)>=maxvalue;
            a(i,j)=maxvalue;
        end
    end
end
bitxor=a;
figure(11);
imshow(bitxor);
handles.bitxor=bitxor;
guidata(hObject, handles);
helpdlg('histogram modification done');

% --- Executes on button press in Integertransform.
function Integertransform_Callback(hObject, eventdata, handles)
% hObject    handle to Integertransform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%dividing the image into 8x8 block and IWT%%%%%% 

bitxor=handles.bitxor;
[r c]=size(bitxor);
for i=1:8:r-7;
    for j=1:8:c-7;
        bloc_k=bitxor(i:i+7,j:j+7);
        Y(i:i+7,j:j+7)=forward_lift(bloc_k);
    end
end
axes(handles.axes2);
imshow(Y,[]);
handles.Y=Y;
guidata(hObject, handles);
helpdlg('Transformation completed');

% --- Executes on button press in key.
function key_Callback(hObject, eventdata, handles)
% hObject    handle to key (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%% Key generation%%%%%%%%%%%

keygener=zeros(8,8);
key=[0 0 1 0 ;0 0 1 1 ;0 1 0 1; 0 1 1 1; 1 0 0 0; 1 0 1 0; 1 1 0 1; 1 0 1 1];
key1=[0 0 1 0 0 0 1 0 ;0 0 1 1 0 0 1 1 ;0 1 0 1 0 1 0 1; 0 1 1 1 0 1 1 1];
keygener(1:8,5:8)=key;
keygener(5:8,1:8)=key1;
circshift=keygener;
handles.circshift=circshift;
guidata(hObject, handles);
helpdlg('Secret key generated');

% --- Executes on button press in embedding.
function embedding_Callback(hObject, eventdata, handles)
% hObject    handle to embedding (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Y=handles.Y;
circshift=handles.circshift;
[file path]=uigetfile('*.txt','choose txt file');
if isequal(file,0) || isequal(path,0)
    warndlg('Hidden message not selected');
else
    data1=fopen(file,'r');
    F=fread(data1);
    fclose(data1);
end
len=length(F);
count=1;
totalbits=8*len;
a=128;
k=1;
[r c]=size(Y);
for i=1:8:r-7;
    for j=1:8:c-7;
        block3=Y(i:i+7,j:j+7);
        for ii=1:8
            for jj=1:8;
                if circshift(ii,jj)==1;
                    coeff=abs(block3(ii,jj));
                    [ block3(ii,jj),a,k,count]=bitlength(coeff,a,k,F,totalbits,count,len);
                    if count>totalbits;
                        break;
                    end
                end
                if count>totalbits;
                    break;
                end
            end
            if count>totalbits;
                break;
            end
        end
        Y(i:i+7,j:j+7)=block3;
        Y=abs(Y);
        if count>totalbits;
            break;
        end
    end
    if count>totalbits;
        break;
    end
end
outpu_t=Y;
handles.outpu_t=outpu_t;
handles.totalbits=totalbits;
guidata(hObject, handles);
helpdlg('Process completed');

% --- Executes on button press in opm.
function opm_Callback(hObject, eventdata, handles)
% hObject    handle to opm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%)OPM%%%%%%%%%%%%%
Y=handles.Y;
outpu_t=handles.outpu_t;
kk=3;
tt=kk-1;
diff=outpu_t-Y;
[r c]=size(diff);
for x=1:r;
    for y=1:c;
        if diff(x,y)>(-2^kk) & diff(x,y)<(-2^tt);
            if outpu_t(x,y)<(256-2^kk);
                outpu_t(x,y)=outpu_t(x,y)+2^kk;
            else
                outpu_t(x,y)=outpu_t(x,y);
            end
        elseif diff(x,y)>=(-2^tt) & diff(x,y)<=(2^tt);
            outpu_t(x,y)=outpu_t(x,y);
        elseif diff(x,y)>(2^tt) & diff(x,y)<(2^kk);
            if outpu_t(x,y)>=(2^kk);
                outpu_t(x,y)=outpu_t(x,y)-(2^kk);
            else outpu_t(x,y)=outpu_t(x,y);
            end
        end
    end
end
embededimage= outpu_t;
handles.embededimage=embededimage;
guidata(hObject, handles);
helpdlg('OPAP completed');
% --- Executes on button press in inversetran.
function inversetran_Callback(hObject, eventdata, handles)
% hObject    handle to inversetran (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

embededimage=handles.embededimage;
[r c]=size(embededimage);
m=1;
n=1;
for i=1:8:r-7;
    for j=1:8:c-7;
        bloc_k11=embededimage(i:i+7,j:j+7);
        LL=bloc_k11(m:m+3,n:n+3);
        LH=bloc_k11(m:m+3,n+4:n+7);
        HL=bloc_k11(m+4:m+7,n:n+3);
        HH=bloc_k11(m+4:m+7,n+4:n+7);
        Z(i:i+7,j:j+7)=reversedwt(LL,LH,HL,HH);
    end
end
axes(handles.axes2);
imshow(Z,[]);
handles.Z=Z;
guidata(hObject, handles);
helpdlg('Inverse Transformation completed');
helpdlg('Output Image is obtained');

% --- Executes on button press in tran2.
function tran2_Callback(hObject, eventdata, handles)
% hObject    handle to tran2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

embededimage=handles.embededimage;

Z=handles.Z;
extractinpu_t=Z;
[r c]=size(extractinpu_t);
for i=1:8:r-7;
    for j=1:8:c-7;
        bloc_kextract=extractinpu_t(i:i+7,j:j+7);
        YY(i:i+7,j:j+7)=forward_lift(bloc_kextract);
    end
end
handles.YY=YY;
guidata(hObject, handles);
helpdlg('Transformation completed');

% --- Executes on button press in extract.
function extract_Callback(hObject, eventdata, handles)
% hObject    handle to extract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

YY=handles.YY;
totalbits=handles.totalbits;
circshift=handles.circshift;
fil_e=YY;
% totalbits=8*len;
a=128;
jjj=1;
count=1;
k=0;
[r c]=size(YY);
for i=1:8:r-7;
    for j=1:8:c-7;
        block9=fil_e(i:i+7,j:j+7);
        for ii=1:8
            for jj=1:8;
                if circshift(ii,jj)==1;
                    coeff=abs(block9(ii,jj));
                    %[ k,a,count,jjj,ff]=extrac_t(coeff,a,k,jjj,totalbits,count);
                    g=coeff;
                    if g>=64;
                        bits=6;

                        h=32;
                    elseif g<64 & g>=32;
                        bits=5;

                        h=16;
                    elseif g<32 & g>=16;
                        bits=4;

                        h=8;
                    elseif g<16
                        bits=3;
                        h=4;
                    end
                    l=bits;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for iii=1:l;
                        if bitand(g,h)==h;
                            k= bitor(k,a);
                        end
                        count=count+1;
                        a=a/2;
                        h=h/2;
                        if a<1;
                            R(jjj)=k;
                            fid=fopen('output.txt','wb');
                            fwrite(fid,char(R),'char');
                            fclose(fid);jjj=jjj+1;
                            k=0;
                            a=128;
                        end
                        if count>totalbits;
                            break;
                        end
                    end
                    if count>totalbits;
                        break;
                    end
                end
                if count>totalbits;
                    break;
                end
            end
            if count>totalbits;
                break;
            end
        end
        if count>totalbits;
            break;
        end
    end
    if count>totalbits;
        break;
    end
end
helpdlg('Secret data was obtained in text file');





% --- Executes on button press in validate.
function validate_Callback(hObject, eventdata, handles)
% hObject    handle to validate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputimage=handles.a;
outputimage=handles.Z;
[M N]=size(outputimage);
inputimage=uint8(inputimage);
outputimage=uint8(outputimage);
%%%%%%%%%%%%%%%%%%%%MSE%%%%%%%%%%%
MSE=sum(sum((inputimage-outputimage).^2))/(M*N);
set(handles.edit1,'string',MSE);
%%%%%%%%%%%%%%%%%%PSNR%%%%%%%%%%%
PSNR = 10*log10(255*255/MSE);
set(handles.edit2,'string',PSNR);



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


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


% --- Executes on button press in viewout.
function viewout_Callback(hObject, eventdata, handles)
% hObject    handle to viewout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
open('output.txt');
outputimage=handles.Z;
figure,imshow(outputimage,[]);
title('Cover Image')


% --- Executes on button press in clea.
function clea_Callback(hObject, eventdata, handles)
% hObject    handle to clea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clear all;
close all;
