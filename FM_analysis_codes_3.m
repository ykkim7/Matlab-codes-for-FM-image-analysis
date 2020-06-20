%% MATLAB code #3 (Flatmount image analysis)

% Using our developed MATLAB-based graphical application (MATLAB code #2), 
% we manually removed erroneously segmented cells from the automatically selected RPE segmentation image ('modified_3.tif'), 
% particularly near the cut edges of the flatmount or artifacts ('finalset.tif').

clear all;
close all;
clc;

a=imread('finalset.tif');              %% Image loading
b=imclearborder(a,4);                  %% border touching cell removal

Flatmount=imread('flatmount.tif');     %% RPE flatmount tissue boundary image
Flatmount=double(Flatmount);

cc=bwconncomp(b,4);                           %% cell division
stats = regionprops(cc,'all');                %% cell characteristics
stats2 = regionprops(cc, 'Area', 'MajorAxisLength', 'MinoraxisLength', 'Eccentricity', 'ConvexArea', 'Circularity', 'Solidity', 'Extent', 'Perimeter');
fields=fieldnames(stats2);

Sizeimage=size(b);                                   
Centerpoint=[Sizeimage(2)/2,Sizeimage(1)/2];        %% Image center point

tmp=struct2cell(stats2);
stats2m=cell2mat(tmp);
stats2m=stats2m';

Area=stats2m(:,1);              %% Area
Maxis=stats2m(:,2);             %% major axis length
maxis=stats2m(:,3);             %% minor axis length
Ecc=stats2m(:,4);               %% eccentricity
Convexarea=stats2m(:,5);        %% convex area
Circularity=stats2m(:,6);       %% circularity
Solidity=stats2m(:,7);          %% solidity
Extent=stats2m(:,8);            %% extent
Perimeter=stats2m(:,9);         %% perimeter
AR=maxis./Maxis;                %% aspect ratio

for i=1:cc.NumObjects               
    C{i}=stats(i).Centroid(:);                      %% Centroid location
         
    theta(1,i)=((atan2((C{i}(2)-Centerpoint(2)),(C{i}(1)-Centerpoint(1))))*180/pi)*-1;  %% angle between x-axis and line between center point and each cell's Centroid point
    
    O(1,i)=stats(i).Orientation;                    %% angle between major axis and x-axis
    
    theta2(1,i)=abs(theta(i)-O(i));                 %% angle between major axis and line between center to Centroid
    if theta2(1,i)>180                              %% theta angle in less than 90 degrees
        theta2(1,i)=theta2(1,i)-180;
    elseif theta2(1,i)>90 & theta2(1,i)<=180
        theta2(1,i)=180-theta2(1,i);
    else
        theta2(1,i)=theta2(1,i);        
    end
        
    RCO(1,i)=cosd(theta2(1,i))*(1-AR(i));           %% radial cell orientation
       
    D = [Centerpoint; stats(i).Centroid];           %% distance between center point and centroid of each cell
    Distance(1,i)=pdist(D,'euclidean');
    
end

RCO=RCO';
Distance=Distance';

%% Max distance

background = (Flatmount==0);

[x1g, x2g] = meshgrid(1:4500, 1:4500);
Distpixel = (x1g-Centerpoint(2)).^2 + (x2g-Centerpoint(1)).^2;
Distpixel(background) = 0;
radius = max(Distpixel(:));
radius = sqrt(radius);


%% Zone classification

for  i=1:cc.NumObjects                              %% zone classification
    if Distance(i)<radius/5         
    Zone(i,1)=1;
    elseif Distance(i)<radius/5 *2     
    Zone(i,1)=2;
    elseif Distance(i)<radius/5 *3    
    Zone(i,1)=3;
    elseif Distance(i)<radius/5 *4     
    Zone(i,1)=4;
    else Zone(i,1)=5;        
    end
end


%% Bins

Distum = Distance/1024*1273;        %% pixel into um conversion
radiusum = radius/1024*1273;

Bin = ceil(radiusum/300);           %% 300 um interval bins

edges = [0];

for i=1:Bin
    edges(1, i+1) = 300*i;
end

edges(end-1)='';                    %% The last bin is merged into the second last bin

binWidth = 300;
X = edges(1:end-2) + binWidth/2;            %% bin centerpoint
X(end+1) = (edges(end-1)+radiusum)/2;     %% last bin centerpoint

%% mean calculation

mArea=[];                                           

for i=1:size(edges, 2)-1
    mArea(1,i)=mean(Area(Distum>=edges(i) & Distum<edges(i+1)));
end

mArea=mArea';
mAreaum=mArea/((1024/1273)^2);

mEcc=[];                                           

for i=1:size(edges, 2)-1
    mEcc(1,i)=mean(Ecc(Distum>=edges(i) & Distum<edges(i+1)));
end

mEcc=mEcc';


mSolidity=[];                                           

for i=1:size(edges, 2)-1
    mSolidity(1,i)=mean(Solidity(Distum>=edges(i) & Distum<edges(i+1)));
end

mSolidity=mSolidity';


mPerimeter=[];                                           

for i=1:size(edges, 2)-1
    mPerimeter(1,i)=mean(Perimeter(Distum>=edges(i) & Distum<edges(i+1)));
end

mPerimeter=mPerimeter';
mPerimeterum=mPerimeter/1024*1273;


mAR=[];                                           

for i=1:size(edges, 2)-1
    mAR(1,i)=mean(AR(Distum>=edges(i) & Distum<edges(i+1)));
end

mAR=mAR';

mRCO=[];                                           

for i=1:size(edges, 2)-1
    mRCO(1,i)=mean(RCO(Distum>=edges(i) & Distum<edges(i+1)));
end

mRCO=mRCO';



%% Area, analyzed area

MM = zeros(4500);
MM (2250,2250)=1;       %% image centerpoint

a = double(a);          %% a=imread('finalset.tif');  %% Image loading

Cellarea=[];            %% RPE area
FMarea=[];              %% flatmount area
Analyzedarea=[];        %% Percentage of the analyzed area over the flatmount area
Cellcount=[];           %% Cell count

for i=1:size(edges, 2)-1
    MM(bwdist(MM)>=edges(i)/1273*1024 & bwdist(MM)<edges(i+1)/1273*1024)=1;
    Cellarea(1,i) = bwarea(a.*MM);
    FMarea(1,i) = bwarea(Flatmount.*MM);
    Analyzedarea(1,i) = bwarea(a.*MM)*100/bwarea(Flatmount.*MM);
    Cellcount(1,i)=FMarea(i)/mArea(i);
    MM = zeros(4500);
    MM (2250,2250)=1;
end

Analyzedarea=Analyzedarea';
TAnalyzedarea=bwarea(a)/bwarea(Flatmount)*100;
Cellcount=Cellcount';
FMarea=FMarea';
FMareaum=[];
FMareaum=FMarea/((1024/1273)^2);

for i=1:size(edges, 2)-1
    cFMareaum(1,i)=sum(FMareaum([1:i]));    %% cumulative flatmount area
end

cFMareaum=cFMareaum';
cFMareamm=cFMareaum/1000000;                %% um^2 into mm^2 conversion


%% Cosine theta

costheta=[];

for i=1:cc.NumObjects               
    costheta(1,i)=cosd(theta2(i));
      
end

costheta=costheta';

mcostheta=[];  
mtheta2=[];

for i=1:size(edges, 2)-1
    mcostheta(1,i)=mean(costheta(Distum>=edges(i) & Distum<edges(i+1)));
    mtheta2(1,i)=mean(theta2(Distum>=edges(i) & Distum<edges(i+1)));
end

mcostheta=mcostheta';
mtheta2=mtheta2';

%% Excel export

warning( 'off', 'MATLAB:xlswrite:AddSheet' ) ;

header1={'Distance(um)','mArea','Analyzed area%','Total analyzed area%','estimated cell count','total cell count','Flatmount area','Cumulative area','Ecc','Solidity','Perimeter','Aspect ratio','Radius','Radial cell orientation','theta'}; 

writecell(header1,'Analysis.xlsx','Range','A1');


writematrix(X','Analysis.xlsx','Range','A2');     
writematrix(mAreaum,'Analysis.xlsx','Range','B2');    
writematrix(Analyzedarea,'Analysis.xlsx','Range','C2'); 
writematrix(TAnalyzedarea,'Analysis.xlsx','Range','D2'); 
writematrix(Cellcount,'Analysis.xlsx','Range','E2'); 
writematrix(sum(Cellcount),'Analysis.xlsx','Range','F2'); 
writematrix(FMareaum,'Analysis.xlsx','Range','G2');    
writematrix(cFMareamm,'Analysis.xlsx','Range','H2'); 

writematrix(mEcc,'Analysis.xlsx','Range','I2');  
writematrix(mSolidity,'Analysis.xlsx','Range','J2'); 
writematrix(mPerimeterum,'Analysis.xlsx','Range','K2');   
writematrix(mAR,'Analysis.xlsx','Range','L2');    
  
writematrix(radiusum,'Analysis.xlsx','Range','M2');  

writematrix(mRCO,'Analysis.xlsx','Range','N2'); 
writematrix(mtheta2,'Analysis.xlsx','Range','O2');  

 
