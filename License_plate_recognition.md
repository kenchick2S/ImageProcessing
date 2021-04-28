# 車牌辨識

### 目前進度：
#### 1.彩色轉灰階
#### 2.計算平均亮度
#### 3.高增濾波器(high boost filter)
#### 4.膨脹、侵蝕、開運算、閉運算

## <font color="#f00">彩色轉灰階</font>
圖片大小：1706X959
```matlab=
clear;clc;close all;
img = imread('0409VJ.jpg');
figure
imshow(img)
gimg = rgb2gray(img); % 0.2989 * R + 0.5870 * G + 0.1140 * B 
figure
imshow(gimg)
[h,w,d] = size(gimg); 
``` 

| oringinal | gray |
| -------- | -------- | 
| ![](https://i.imgur.com/cs8XLGI.jpg)|![](https://i.imgur.com/NKIrnv1.jpg)| 

## <font color="#f00">計算平均亮度</font>
平均亮度：123
```matlab=
sum = 0;
for i=1:h
    for j = 1:w
        sum =  sum + uint64(gimg(i,j,1)); % gimg(i,j,1); data type : uint8; range : 0~255; 怎麼加都不會超過255
    end
end
average = sum/(h*w);
fprintf('平均亮度: %d\n',average);
``` 
## <font color="#f00">高增濾波器(high boost filter)</font>
高增濾波是將原始資料放大 a 倍，再減去低頻資訊；
相當於將原始資料放大 a-1 倍，再加上高頻資訊。
```matlab=
pimg = zeros(h+2,w+2,d); %padding
pimg1 = uint8(pimg); %for closing
pimg(2:h+1,2:w+1,1) = gimg(:,:,1); 


B = 1/9*[-1 -1 -1; -1 35 -1; -1 -1 -1]; % a*I - I-LowPass = (a-1)*I + I-HighPass 

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
``` 


| high boost filter |
| -------- |
|![](https://i.imgur.com/jkzwTLO.jpg)
|

## <font color="#f00">膨脹、侵蝕</font>
A is image; B is filter
膨脹：Max(A) by B
侵蝕：Min(A) by B
```matlab=
pimg(2:h+1,2:w+1,1) = himg(:,:,1); 
pimg = uint8(pimg);

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

figure
imshow(dimg)
figure
imshow(eimg)
``` 


| Dilation| Erosion | 
| -------- | -------- |
| ![](https://i.imgur.com/bHu5chP.jpg)| ![](https://i.imgur.com/vXgqG3K.jpg)| 


## <font color="#f00">開運算、閉運算</font>
開運算：Max(Min(A)) by B
閉運算：Min(Max(A)) by B
```matlab=
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
        cimg(i-2,j-2,1) = min(A,[],'all'); %closing Min(Max(A)) by B
    end
end

figure
imshow(oimg)
figure
imshow(cimg)

coimg = cimg - oimg;
figure
imshow(coimg)
```

| Opening | Closing | Edge |
| -------- | -------- | -------- |
|![](https://i.imgur.com/5OXwdOd.jpg)| ![](https://i.imgur.com/ABT8m3U.jpg)| ![](https://i.imgur.com/7TcNeu3.jpg)|