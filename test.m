clc;
clear all;
close all;

%%%%%%%% Step1: read cover image %%%%%%%%
[file,path] = uigetfile('*.png;*.jpg;*.bmp','Pick an Image File');

if isequal(file,0) | isequal(path,0)
    warndlg('User Pressed Cancel');
else
    a = imread(file);
    a=imresize(a,[256 256]);
    [r c p] = size(a);
    %%%%%%%%%%% If it is color image ,convert that to gray......

    if p==3
        a = rgb2gray(a);
    end
    figure(1);
    imshow(a);
    title('Input Image');
    
end
% figure(3);
% subplot(1,2,1);
% plot(a);
%%%%%%%%%%Step 2 : converting gray level values histogram modification%%%%%%%%%
minvalue=15;
maxvalue=240;

[r c]=size(a);
for i=1:r
    for j=1:c
        if a(i,j)<=minvalue;
            a(i,j)=minvalue;
        elseif a(i,j)>=maxvalue;
            a(i,j)=maxvalue;
        end
    end
end
histmod = a;
figure(2);
imshow(histmod);
% figure(3);
% subplot(1,2,2);
% plot(a);
helpdlg('histogram modification done');

%%%%%%%%%%Step 3: dividing the image into 8x8 block and IWT%%%%%%

[r c]=size(histmod);
for i=1:8:r-7;
    for j=1:8:c-7;
        bloc_k=histmod(i:i+7,j:j+7);
        Y(i:i+7,j:j+7)=forward_lift(bloc_k);
    end
end
figure(3);
imshow(Y,[]);

helpdlg('Transformation completed');
% % % % % % step 4 secreat key generated 
%%%%%%%%%%%%%%% Key generation%%%%%%%%%%%

keygener=zeros(8,8);
key=[0 0 1 0 ;0 0 1 1 ;0 1 0 1; 0 1 1 1; 1 0 0 0; 1 0 1 0; 1 1 0 1; 1 0 1 1];
key1=[0 0 1 0 0 0 1 0 ;0 0 1 1 0 0 1 1 ;0 1 0 1 0 1 0 1; 0 1 1 1 0 1 1 1];
keygener(1:8,5:8)=key;
keygener(5:8,1:8)=key1;
orig_key=keygener;


helpdlg('Secret key generated');
% % % % step5 Embedding process



[file path]=uigetfile('*.txt','choose txt file');
if isequal(file,0) | isequal(path,0)
    warndlg('User Pressed Cancel');
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
                if orig_key(ii,jj)==1;
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

helpdlg('Process completed');

% % % % % % % % OPA implemented

%%%%%%%%%%%%%)OPA%%%%%%%%%%%%%


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

helpdlg('OPM completed');

% % % % % Invese transformation


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

figure(22),imshow(Z,[]);
 title('Embedded Image');
helpdlg('Inverse Transformation completed');
helpdlg('Output Image is obtained');

