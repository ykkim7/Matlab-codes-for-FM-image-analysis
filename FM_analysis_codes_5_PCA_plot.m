%% MATLAB code #5 - PCA

%% load file

load('C:\PCA.mat');


%% specific data extract - change the zone or age numbers and extract specific data

stats3m = PCAstats(PCAstats(:,14)==1,:);    % Change zone numbers and extract specific zone data

% stats3m = PCAstats(PCAstats(:,15)==180,:);  % Change age numbers and extract specific age data


%% PCA
stats4m=[stats3m(:,[1:12])];        %% array with morphometric data only
[coeff,score,latent,tsquared,explained,mu] = pca(stats4m);

%% plot Age - using this code when plotting over ages

Xscore=score(:,1);
Yscore=score(:,2);

Zone = stats3m(:,14);
Age= stats3m(:,15);

hold on;
plot(Xscore(Age<=60),Yscore(Age<=60),'r.');
plot(Xscore(Age==180),Yscore(Age==180),'y.');
plot(Xscore(Age==330),Yscore(Age==330),'g.');
plot(Xscore(Age==720),Yscore(Age==720), 'b.');

xlabel('PC1 score','FontSize',60,'FontWeight','bold','Color','k')
ylabel('PC2 score','FontSize',60,'FontWeight','bold','Color','k')
formatSpec = 'Zone%d';
A1 = Zone(1);
str = sprintf(formatSpec,A1);
title(str,'FontSize',60);
hold off;



%% plot zone - using this code when plotting over zones

Xscore=score(:,1);
Yscore=score(:,2);

Zone = stats3m(:,14);
Age= stats3m(:,15);

hold on;
plot(Xscore(Zone==1),Yscore(Zone==1),'r.');
plot(Xscore(Zone==2),Yscore(Zone==2),'m.');
plot(Xscore(Zone==3),Yscore(Zone==3),'y.');
plot(Xscore(Zone==4),Yscore(Zone==4),'g.');
plot(Xscore(Zone==5),Yscore(Zone==5), 'b.');

xlabel('PC1 score','FontSize',60,'FontWeight','bold','Color','k')
ylabel('PC2 score','FontSize',60,'FontWeight','bold','Color','k')
formatSpec = 'P%d';
A1 = Age(1);
str = sprintf(formatSpec,A1);
title(str,'FontSize',60);
hold off;

