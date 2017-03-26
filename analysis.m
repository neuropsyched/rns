clear; clc; close all
dp=['/Users/tomwozny/Documents/RNS/'];

patients = {'DD762713','CM723654','GN765937','DW728352'};
PtId=patients{3};

load(fullfile(dp,PtId,[PtId '_datastruct.mat']))
load(fullfile(dp,PtId,[PtId '_info.mat']))

prewin=10;
postwin=15;
sr=250;
[data] = rns_traintimes(datastruct,prewin,postwin);

postll=arrayfun(@(x) mean(abs(diff(x.tspostwin'))),data,'uni',0);
postll=cat(1,postll{:});












%%
% 1. get rns datastruct and info
clear; clc; close all
dp=['/Users/tomwozny/Documents/RNS/'];

patients = {'DD762713','CM723654','GN765937','DW728352'};
PtId=patients{3};

load(fullfile(dp,PtId,[PtId '_datastruct.mat']))
load(fullfile(dp,PtId,[PtId '_info.mat']))

prewin=10;
postwin=3;
sr=250;
[data,recid,datastruct] = rns_getisgood(datastruct,prewin,postwin);

%% power

win=1;
step=0.5;
index=reshape( bsxfun(@plus,[0:floor(win*sr)-1]', ...
    [1:round(step*sr):prewin*sr-floor(win*sr)]) ,[],1);
R=cell(4,1);
P=R;
for nch=1:length(data)
    %pre power
    preamp=reshape(data{nch}(index,:),floor(win*sr),[]);
    preamp=abs(fft(preamp));
    preamp=preamp(1:end/2,:).*(2/floor(win*sr));
    preamp=reshape(preamp,round(step*sr),[],size(data{nch},2));
    %post power
%     postamp=data{nch}(prewin*sr+1*sr:prewin*sr+2*sr-1,:);
%     postamp=abs(fft(postamp));
%     postamp=postamp(1:end/2,:).*(2/floor(win*sr));
%     postamp=reshape(postamp,round(step*sr),[],size(data{nch},2));
    postamp=data{nch}(prewin*sr+1*sr:end,:);
    postamp=mean(abs(diff(postamp)));
    %
    preamp=reshape(permute(preamp,[3,1,2]),size(preamp,3),[]);
    [r,p]=corr(preamp,reshape(postamp,[],1),'type','Pearson');
    R{nch}=reshape(r,round(sr*win*0.5),[]);
    P{nch}=reshape(p,round(sr*win*0.5),[]);
end

figure
subplot(4,2,1),imagesc(R{1},[-1,1]),axis xy
subplot(4,2,2),imagesc(1-P{1},[1-0.05/numel(P{1}),1]),axis xy
subplot(4,2,3),imagesc(R{2},[-1,1]),axis xy
subplot(4,2,4),imagesc(1-P{2},[1-0.05/numel(P{2}),1]),axis xy
subplot(4,2,5),imagesc(R{3},[-1,1]),axis xy
subplot(4,2,6),imagesc(1-P{3},[1-0.05/numel(P{3}),1]),axis xy
subplot(4,2,7),imagesc(R{4},[-1,1]),axis xy
subplot(4,2,8),imagesc(1-P{4},[1-0.05/numel(P{4}),1]),axis xy