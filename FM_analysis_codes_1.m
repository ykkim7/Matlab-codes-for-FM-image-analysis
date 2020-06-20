%% MATLAB code #1 (Flatmount image processing)

% For flatmount image processing, we need following preprocessing and preprocessed image sets

% The whole RPE flatmount image should be trimmed manually using Photoshop (Adobe Photoshop CS2; Adobe, San Jose, CA). 
% Erase the background, cornea, ciliary body, and optic disc area, and only leave the RPE area.
% Make 2 sets of images for the purpose of RPE segmentation and RPE flatmount area analysis.
% For RPE segmentation, remove thoroughly the non-RPE area including the obscured region by ciliary body folding in the periphery ('RPE_1.tif').
% For RPE area analysis, crop the image along the imaginary boundary connected to the surrounding clear boundary including the part of ciliary body folding in the periphery ('RPE_2.tif').
% 
% Then, the trimmed RPE flatmount image is split into 3 channels, red (nucleus), green (ZO-1 staining), and blue (for flatmount contour detection).
% 
% All images were adjusted to fit the same canvas size (4500 by 4500 pixels), centered on the center of the optic disc 
% 
% The following three preprocessed images are needed for RPE flatmount image processing.
% 
% 1) The green-channel of the thoroughly trimmed image ('RPE_1.tif'): 'ZO-1.tif'
% 2) Using 'ZO-1.tif', the image was binarized into cell borders and background by the ImageJ plugin 'Trainable Weka Segmentation': 'weka.tif'
% 3) Using the blue-channel of the trimmed image including the part of ciliary body folding in the periphery ('RPE_2.tif'), the image was thresholded to make the contour image of the RPE flatmount using ImageJ: 'flatmount.tif'
% 4) Using the blue-channel of the thoroughly trimmed image ('RPE_1.tif'), the image was thresholded to make the contour image of RPE boundary: 'RPE_boundary.tif'
% 
% The following ImageJ process was used for images 2) and 3).
% 
% setAutoThreshold("Default");
% //run("Threshold...");
% //setThreshold(0, 254);
% setOption("BlackBackground", true);
% run("Convert to Mask");

%% Binarized Weka image into despeckled image and then into a skeletonized image

clear all;
close all;

a=imread('weka.tif');     %% Weka binarized image loading
a=imcomplement(a);
b=bwareaopen(a, 100, 4);  %% particles less than 100-pixel size were removed
b=imcomplement(b);
b=double(b);

imwrite(b, 'despeckled.tif');  %% despeckled image

c=imbinarize(b);
c=imcomplement(c);
c=bwskel(c);
c=imcomplement(c);

imwrite(c,'skeletonized.tif');  %% skeletonized image

%% Image load
ZO1 = imread('ZO-1.tif');                   %% green channel image representing the signal from ZO-1 staining
RPEboundary = imread('RPE_boundary.tif');   %% RPE cell boundary image 
Flatmount = imread('flatmount.tif');        %% RPE flatmount tissue boundary image

RPEboundary=double(RPEboundary);
Flatmount=double(Flatmount);

%% Image adjustment: compare skeletonized image and original green-channel image

a=imread('ZO-1.tif');
b=imread('skeletonized.tif');
a=double(a);
b=double(b);
b=b.*255;

c=ones(4500);
c=c.*255;
d=a+c-b;                %% pixel comparison       

b(d>490)=255;
b(d<150)=0;             %% we compared the pixel intensity between the skeletonized image and the original image and made an adjustment
imwrite(b,'modified_1.tif')  %% adjusted image

e=imcomplement(b);
f=imbinarize(e);
g=bwskel(f);
h=bwmorph(g,'clean');   %% remove isolated pixels

i=bwmorph(h,'close');   %% performs morphological closing (dilation follwed by erosion)
j=bwskel(i); 
j=imcomplement(j);      %% skeletonized image

%% cells with unconnected line or border touching cell removal

Edge=bwmorph(RPEboundary,'remove');         
imwrite(Edge,'Border image.tif');           %% boundary images for RPE area

Edgepoint=find(Edge);

cc=bwconncomp(j,4);     %% j = skeletonized image of adjusted image / find connected components in binary image
stats = regionprops(cc,'all');

k=imcomplement(j);

E = bwmorph(k, 'endpoints');
Endpoint = find(E);

ind=sub2ind([4500,4500],2250,2250); % Centerpoint index

for i=1:cc.NumObjects
if max(ismember(stats(i).PixelIdxList, ind))==1
    j(cc.PixelIdxList{i})=0;       
elseif max(ismember(stats(i).PixelIdxList, (Endpoint-1)))==1
    j(cc.PixelIdxList{i})=0;
elseif max(ismember(stats(i).PixelIdxList, (Endpoint+1)))==1
    j(cc.PixelIdxList{i})=0;
elseif max(ismember(stats(i).PixelIdxList, (Edgepoint-1)))==1
    j(cc.PixelIdxList{i})=0;
elseif max(ismember(stats(i).PixelIdxList, (Edgepoint+1)))==1
    j(cc.PixelIdxList{i})=0;
elseif max(ismember(stats(i).PixelIdxList, (Edgepoint-4500)))==1
    j(cc.PixelIdxList{i})=0;
elseif max(ismember(stats(i).PixelIdxList, (Edgepoint+4500)))==1
    j(cc.PixelIdxList{i})=0;
end
end

imwrite(j,'modified_2.tif');  %% cells with unconnected line or border touching cell removed


%% Cell area, solidity, and distance from center point

k=imclearborder(j,4);                               %% border touching cell removal

cc=bwconncomp(k,4);                                 %% find connected components in binary image
stats = regionprops(cc,'all'); 
stats2 = regionprops(cc, 'Area', 'Solidity');

Sizeimage=size(k);                                   
Centerpoint=[Sizeimage(2)/2,Sizeimage(1)/2];        %% Image center point
C=[];
Distance=[];
Zone=[];

tmp=struct2cell(stats2);
stats2m=cell2mat(tmp);
stats2m=stats2m';                       %% structure to cell array

Area=stats2m(:,1);
Solidity=stats2m(:,2);

for i=1:cc.NumObjects               
    C{i}=stats(i).Centroid(:);                      %% Centroid location
    
    D = [Centerpoint; stats(i).Centroid];           %% distance between center point and centroid of each cell
    Distance(1,i)=pdist(D,'euclidean');
    
end

Distance=Distance';

%% Max distance

background = (Flatmount==0);

[x1g, x2g] = meshgrid(1:4500, 1:4500);
Distpixel = (x1g-Centerpoint(2)).^2 + (x2g-Centerpoint(1)).^2;
Distpixel(background) = 0;
radius = max(Distpixel(:));
radius = sqrt(radius);

%% Zone

for  i=1:cc.NumObjects                              %% zone classification
    if Distance(i,1)<radius/5      
    Zone(i,1)=1;
    elseif Distance(i,1)<radius/5 *2     
    Zone(i,1)=2;
    elseif Distance(i,1)<radius/5 *3    
    Zone(i,1)=3;
    elseif Distance(i,1)<radius/5 *4     
    Zone(i,1)=4;
    else Zone(i,1)=5;        
    end
end


%% mean calculation

mAreazone=[];                               %% mean area for each zone            

for i=1:5
    mAreazone(1,i)=nanmean(Area(Zone==i));
end

mAreazone=mAreazone';

stArea=[];                                  %% standard deviation of area for each zone 

for i=1:5
    stArea(1,i)=nanstd(Area(Zone==i));
end

stArea=stArea';


mSolidityzone=[];                           %% mean solidity for each zone        

for i=1:5
    mSolidityzone(1,i)=nanmean(Solidity(Zone==i));
end

mSolidityzone=mSolidityzone';

stSolidity=[];                              %% standard deviation of solidity for each zone 

for i=1:5
    stSolidity(1,i)=nanstd(Solidity(Zone==i));
end

stSolidity=stSolidity';


%% Cell removal through area and solidity criteria

k=imclearborder(j,4);                    %% cells with unconnected line or border touching cell removed

for i=1:cc.NumObjects
     if Area(i) < 20
         k(cc.PixelIdxList{i})=0;
     end
     
     if Area(i) > 2000
         k(cc.PixelIdxList{i})=0;
     end
    
    if Area(i) < mAreazone(Zone(i))/8
         k(cc.PixelIdxList{i})=0;
    end
      
    if Area(i) > 2*mAreazone(Zone(i)) & Solidity(i) < mSolidityzone(Zone(i)) - 2*stSolidity(Zone(i)) 
         k(cc.PixelIdxList{i})=0;
    end   
    
    if Solidity(i) < mSolidityzone(Zone(i)) - 3*stSolidity(Zone(i)) 
         k(cc.PixelIdxList{i})=0;
    end   
   
end



imwrite(k,'modified_3.tif');            %% Cell removal through area and solidity criteria
