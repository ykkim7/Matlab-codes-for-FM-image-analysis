%% MATLAB code #4

% Add all data into one array 'PCAstats'
% Following codes should be repeated on each image

close all;

%% load file
load('C:\PCA.mat');   %% open array with morphometric data of RPE cells
  
%% regionprops

stats2m(:,10)=AR;
stats2m(:,11)=RCO;
stats2m(:,12)=costheta;
stats2m(:,13)=Distance;
stats2m(:,14)=Zone;
stats2m(:,15)=720;  % Change the age according to the current data (e.g. 30, 45, 60, 180, 330, or 720)

stats2m(isinf(stats2m)|isnan(stats2m)) = 0;          % Replace NaNs and infinite values with zeros


%% save file

PCAstats=[PCAstats;stats2m];                %% add current data to the previous array
save('C:\PCA.mat','PCAstats');

