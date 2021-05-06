clear;clc;close all;
img = imread('7929.jpg');
figure
imshow(img)
gimg = rgb2gray(img); % 0.2989 * R + 0.5870 * G + 0.1140 * B 
figure
imshow(gimg)
[h,w,d] = size(gimg); 




sum = 0;
for i=1:h
    for j = 1:w
        sum =  sum + uint64(gimg(i,j,1)); % gimg(i,j,1); data type : uint8; range : 0~255; 怎麼加都不會超過255
    end
end
average = sum/(h*w);
fprintf('平均亮度: %d\n',average);



pimg = zeros(h+2,w+2,d); %padding
% pimg1 = uint8(pimg); %for closing
pimg(2:h+1,2:w+1,1) = gimg(:,:,1); 

B = 1/9*[-1 -1 -1; -1 35 -1; -1 -1 -1]; % a*I - I-LowPass = (a-1)*I + I-HighPass 
%B = 1/16*[-1 -2 -1; -2 60 -2; -1 -2 -1];
himg = zeros(h,w,d);

for i=3:h+2
    for j=3:w+2
       summ = 0;
       for k=1:3
           for m=1:3
               summ = summ + pimg(i-k+1,j-m+1,1) * B(k,m);
           end
       end
       himg(i-2,j-2,1) = summ;
    end
end
himg = uint8(himg);
figure
imshow(himg)


pimg = zeros(h,w+6,d);
pimg(1:h,4:w+3,1) = himg(:,:,1); 
pimg = uint8(pimg);

B = ones(1,7);
B = uint8(B);

dimg = zeros(h,w,d);
dimg = uint8(dimg);
eimg = dimg;

for i=1:h
    for j=7:w+6
        A = pimg(i,j-6:j,1).*B;
        dimg(i,j-6,1) = max(A,[],'all'); %dilation Max(A) by B
        eimg(i,j-6,1) = min(A,[],'all'); %erosion Min(A) by B
    end
end

figure
imshow(dimg)
figure
imshow(eimg)

oimg = zeros(h,w,d);
oimg = uint8(oimg);
cimg = oimg;

pimg = zeros(h,w+6,d);
pimg1 = zeros(h,w+6,d);
pimg(1:h,4:w+3,1) = eimg(:,:,1);
pimg1(1:h,4:w+3,1) = dimg(:,:,1);
pimg = uint8(pimg);
pimg1 = uint8(pimg1);

for i=1:h
    for j=7:w+6
        A = pimg(i,j-6:j,1).*B; 
        oimg(i,j-6,1) = max(A,[],'all'); %opening Max(Min(A)) by B
        A = pimg1(i,j-6:j,1).*B; 
        cimg(i,j-6,1) = min(A,[],'all'); %closing Min(Max(A)) by B
    end
end

figure
imshow(oimg)
figure
imshow(cimg)

coimg = cimg - oimg;
figure
imshow(coimg)

coimg = coimg>uint8(average);
figure
imshow(coimg)

B = ones(1,11);
% B = uint8(B);
ocoimg = zeros(h,w,d);
% ocoimg = uint8(ocoimg);
pimg = zeros(h,w+10,d);
pimg(1:h,6:w+5,1) = coimg(:,:,1); 
% pimg = uint8(pimg);

for i=1:h
    for j=11:w+10
        A = pimg(i,j-10:j,1).*B; 
        ocoimg(i,j-10,1) = min(A,[],'all');
    end
end    

figure
imshow(ocoimg)

pimg = zeros(h,w+10,d);
pimg(1:h,6:w+5,1) = ocoimg(:,:,1); 
%pimg = uint8(pimg);

for i=1:h
    for j=11:w+10
        A = pimg(i,j-10:j,1).*B; 
        ocoimg(i,j-10,1) = max(A,[],'all');
    end
end

figure
imshow(ocoimg)


B = [1 1 1;1 1 1;1 1 1];
%B = uint8(B);
docoimg = zeros(h,w,d);
%docoimg = uint8(docoimg);
pimg = zeros(h+2,w+2,d);
pimg(2:h+1,2:w+1,1) = ocoimg(:,:,1); 
%pimg = uint8(pimg);

for i=3:h+2
    for j=3:w+2
        A = pimg(i-2:i,j-2:j,1).*B; 
        docoimg(i-2,j-2,1) = max(A,[],'all');
    end
end  

figure
imshow(docoimg)

ddocoimg = zeros(h,w,d);
%docoimg = uint8(docoimg);
pimg = zeros(h+2,w+2,d);
pimg(2:h+1,2:w+1,1) = docoimg(:,:,1); 
%pimg = uint8(pimg);

for i=3:h+2
    for j=3:w+2
        A = pimg(i-2:i,j-2:j,1).*B; 
        ddocoimg(i-2,j-2,1) = max(A,[],'all');
    end
end  

figure
imshow(ddocoimg)

tmp = uint8(gimg) .* uint8(ddocoimg);
figure
imshow(tmp)

