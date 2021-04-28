% 車牌辨識
% 李畤廣、陳郁柔、鄭宇恒
clear;clc;close all;
img = imread('0409VJ.jpg');
% figure
% imshow(img)
gimg = rgb2gray(img); % 0.2989 * R + 0.5870 * G + 0.1140 * B 
% figure
% imshow(gimg)
[h,w,d] = size(gimg);
%計算平均亮度
% sum = 0;
% for i=1:h
%     for j = 1:w
%         sum =  sum + uint64(gimg(i,j,1)); % gimg(i,j,1); data type : uint8; range : 0~255; 怎麼加都不會超過255
%     end
% end
% average = sum/(h*w);
% fprintf('平均亮度: %d\n',average);

%high boost filter
pimg = zeros(h+2,w+2,d); %padding
pimg = uint8(pimg);
pimg1 = pimg; %for closing
pimg(2:h+1,2:w+1,1) = gimg(:,:,1); 


B = 1/16*[-1 -2 -1; -2 60 -2; -1 -2 -1]; % a*I - I-LowPass = (a-1)*I + I-HighPass 
B = uint8(B);

himg = zeros(h,w,d);
himg = uint8(himg);

for i=3:h+2
    for j=3:w+2
        A = pimg(i-2:i,j-2:j,1).*B;
        himg(i-2,j-2,1) = sum(A,'all');
    end
end
figure
imshow(himg)
%imwrite(himg,'himg.jpg')

%dilation and erosion
pimg(2:h+1,2:w+1,1) = himg(:,:,1); 

B=[1 1 1
1 1 1
1 1 1];
B = uint8(B);

dimg = zeros(h,w,d);
dimg = uint8(dimg);
eimg = dimg;

for i=3:h+2
    for j=3:w+2
        A = pimg(i-2:i,j-2:j,1).*B;
        dimg(i-2,j-2,1) = max(A,[],'all'); %dilation Max(A) by B
        eimg(i-2,j-2,1) = min(A,[],'all'); %erosion Min(A) by B
    end
end
% figure
% imshow(dimg)
% figure
% imshow(eimg)
%opening and closing
oimg = zeros(h,w,d);
oimg = uint8(oimg);
cimg = oimg;

pimg(2:h+1,2:w+1,1) = eimg(:,:,1);
pimg1(2:h+1,2:w+1,1) = dimg(:,:,1);

for i=3:h+2
    for j=3:w+2
        A = pimg(i-2:i,j-2:j,1).*B; 
        oimg(i-2,j-2,1) = max(A,[],'all'); %opening Max(Min(A)) by B
        A = pimg1(i-2:i,j-2:j,1).*B; 
        cimg(i-2,j-2,1) = max(A,[],'all'); %closing Min(Max(A)) by B
    end
end
figure
imshow(oimg)
figure
imshow(cimg)
coimg = cimg - oimg;
figure
imshow(coimg)
%imwrite(coimg,'coimg.jpg')