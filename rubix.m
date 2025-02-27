clc;
close all;
clear all;
A = imread('cameraman.tif');
[r c] = size(A);
B = imresize(A,[128 128]);
[r,c] = size(B);


kr = randperm(r);
kc = randperm(c);

tic;

n = 1;
while n<=r
i = n;
tempr = B(i,:);
a = sum(tempr); %sum of row elements%
m = mod(a,2);

if m == 0;
k = circshift(tempr,[0 kr(i)]);
else
k = circshift(tempr,[0 -kr(i)]);
end
n = n+1;
C(i,:) = k; % c is scrambled image (Iscr)%

end

n1 = 1;
while n1<=c

j = n1;
tempc = C(:,j);
b = sum(tempc); % sum of column elements %
m1 = mod(b,2);

if m1 == 0;
k1 = circshift(tempc,[kc(j) 0]);
else
k1 = circshift(tempc,[-kc(j) 0]);
end

D(:,j) = k1; % D is the new image formed after scrambling %
n1 = n1+1;
end


%obtaining encrypted image scrambling done up%

keygener=zeros(8,8);
key=[0 0 1 0 ;0 0 1 1 ;0 1 0 1; 0 1 1 1; 1 0 0 0; 1 0 1 0; 1 1 0 1; 1 0 1 1];

keygener(1:8,5:8)=key;


for i1 = 1:r/2;

for j1 = 1:c;

%bitwise XOR to each row %

E(2*i1-1,j1) = bitxor(D(2*i1-1,j1),kc(j1));

E(2*i1,j1) = bitxor(D(2*i1,j1),rot90(kc(j1),2));

end
end

for i2 = 1:r
for j2 = 1:c/2

%bitwise XOR to each column %
F(i2,2*j2-1) = bitxor(E(i2,2*j2-1),kr(j2));
F(i2,2*j2) = bitxor(E(i2,2*j2),rot90(kr(j2),2));

% F is the encrypted image %

end
end

t1 = toc;

% Decryption

tic;

keygener=zeros(8,8);
key1=[0 0 1 0 0 0 1 0 ;0 0 1 1 0 0 1 1 ;0 1 0 1 0 1 0 1; 0 1 1 1 0 1 1 1];
keygener(5:8,1:8)=key1;
for i2 = 1:r
for j2 = 1:c/2

%bitwise XOR applied on vector Kr and to each column of encrypted image F

G(i2,2*j2-1) = bitxor(F(i2,2*j2-1),kr(j2));
G(i2,2*j2) = bitxor(F(i2,2*j2),rot90(kr(j2),2));

end
end

for i1 = 1:r/2;
for j1 = 1:c;

%bitwise XOR applied on vector Kc and to each row of i1

H(2*i1-1,j1) = bitxor(G(2*i1-1,j1),kc(j1));
H(2*i1,j1) = bitxor(G(2*i1,j1),rot90(kc(j1),2));

end
end


n3 = 1;

while n3<=c

j = n3;
tempm = H(:,j);
s1 = sum(tempm); %sum of column elements%
m2 = mod(s1,2);

if m2 == 0;
k2 = circshift(tempm,[-kc(j) 0]);
else
k2 = circshift(tempm,[kc(j) 0]);
end

I(:,j) = k2;
n3 = n3+1;
end

n4 = 1;
while n4<=r

i = n4;
tempn = I(i,:);
s2 = sum(tempn); %sum of row elements%
m3 = mod(s2,2);

if m3 == 0;
k3 = circshift(tempn,[0 -kr(i)]);
else
k3 = circshift(tempn,[0 kr(i)]);
end
n4 = n4+1;
J(i,:) = k3; % J is the decrypted image %

end

t2 = toc;

subplot(4,3,1);
imshow(A);
title('original image');

subplot(4,3,2);
imshow(B);
title('resize image');

subplot(4,3,3);
imshow(C);
title('scrambled image');

subplot(4,3,4);
imshow(D);
title('new image');

subplot(4,3,5);

imshow(E);
title('combination of scrambled and new image');

subplot(4,3,6);
imshow(F);
title('encrypted image');

subplot(4,3,7);
imshow(G);
title('combination of scrambled and new image');

subplot(4,3,8);
imshow(H);
title('new image');


subplot(4,3,9);
imshow(I);
title('scrambled image');


subplot(4,3,10);
imshow(J);
title('decrypted image');
