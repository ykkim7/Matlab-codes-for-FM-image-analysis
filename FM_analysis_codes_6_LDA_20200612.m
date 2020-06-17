%% MATLAB code #6 - LDA

%% load file

load('C:\PCA.mat');

PCAstats(:,16)=(PCAstats(:,14)==5);  % zone 5 =1 / zone 1-4 = 0

PCAstats(:,17)=(PCAstats(:,15)>=180);  % age 180-720 = 1 / age 30-60 = 0
%% specific data extract - change the zone or age numbers and extract specific data

stats = PCAstats(PCAstats(:,15)==5,:);    % zone selection -> Run Code 'LDA by ages'

% stats = PCAstats(PCAstats(:,16)==720,:);  % age selection -> Run Code 'LDA by zones'


%% LDA by zones - using this code when plotting over ages

morph = stats(:,[1:12]); % morphometric characteristics
Zone = stats (:,16);    % zone 5 =1 / zone 1-4 = 0
Age = stats (:,15);     % ages

L = fitcdiscr(morph,Zone);
cvmodel = crossval(L);
LL = kfoldLoss(cvmodel);
Accuracy = (1-LL)*100;

[LTrans,Lambda] = eig(L.BetweenSigma,L.Sigma);
[Lambda,sorted] = sort(diag(Lambda),'descend'); % sort by eigenvalues
LTrans = LTrans(:,sorted);
Xtransformed = L.X*LTrans;

Xscore = Xtransformed(:,1);
Yscore = Xtransformed(:,2);

hold on;
plot(Xscore(Zone==0),Yscore(Zone==0),'r.');
plot(Xscore(Zone==1),Yscore(Zone==1),'b.');

xlabel('LD1 score','FontSize',60,'FontWeight','bold','Color','k')
ylabel('LD2 score','FontSize',60,'FontWeight','bold','Color','k')
formatSpec = 'P%d   Accuracy = %.1f %%';
A1 = Age(1);
A2 = Accuracy;
str = sprintf(formatSpec,A1,A2);
title(str,'FontSize',60)
hold off;




%% LDA by ages - using this code when plotting over zones

morph = stats(:,[1:12]); % morphometric characteristics
Age = stats (:,17);     % age 180-720 = 1 / age 30-60 = 0
Zone = stats (:,14);    % zones

L = fitcdiscr(morph,Age);
cvmodel = crossval(L);
LL = kfoldLoss(cvmodel);
Accuracy = (1-LL)*100;

[LTrans,Lambda] = eig(L.BetweenSigma,L.Sigma);
[Lambda,sorted] = sort(diag(Lambda),'descend'); % sort by eigenvalues
LTrans = LTrans(:,sorted);
Xtransformed = L.X*LTrans;

Xscore = Xtransformed(:,1);
Yscore = Xtransformed(:,2);

hold on;
plot(Xscore(Age==0),Yscore(Age==0),'r.');
plot(Xscore(Age==1),Yscore(Age==1),'b.');

xlabel('LD1 score','FontSize',60,'FontWeight','bold','Color','k')
ylabel('LD2 score','FontSize',60,'FontWeight','bold','Color','k')

formatSpec = 'Zone%d   Accuracy = %.1f %%';
A1 = Zone(1);
A2 = Accuracy;
str = sprintf(formatSpec,A1,A2);
title(str,'FontSize',60)

hold off;


