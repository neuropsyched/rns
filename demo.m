% clear; clc; close all
clear; clc; close all

dp='/Users/arikappel/Documents/MATLAB/Richardsonlab/RNS'; %datapath
mp='/Users/arikappel/Documents/MATLAB/Richardsonlab/RNS/rns'; %matlabpath

% 1. get rns datastruct and info
patients = {'DD762713','CM723654','GN765937','DW728352'};
PtId=patients{3};

load(fullfile(dp,PtId,[PtId '_datastruct.mat']))
load(fullfile(dp,PtId,[PtId '_info.mat']))

[data,rec_length] = rns_datastruct2array(datastruct);

% 2. Choose Trials
Idx{1} = find(~cellfun(@isempty,strfind({info.trigger_reason},'SCHEDULED'))==1);
Idx{2} = find(~cellfun(@isempty,strfind({info.trigger_reason},'LONG_EPISODE'))==1);
Idx{3} = find(~cellfun(@isempty,strfind({info.trigger_reason},'SATURATION'))==1);
Idx{4} = find(~cellfun(@isempty,strfind({info.trigger_reason},'USER_SAVED'))==1);

%
srate = info.channel1_srate;
nchan = size(data,2);
%

% [pre_stim,post_stim,stim_win,results] = rns_datastruct2stimwin(datastruct);
% FTdata_pre = rns_datastruct2fieldtrip(datastruct,'prestim');
% FTdata_post = rns_datastruct2fieldtrip(datastruct,'poststim');

%% 2. Time Series
rec = Idx{2};

figH = figure; set(gcf,'Position',[34   336   779   649])
for tr = 1:length(rec)
   
    hold off;
    figH = rns_plottimeseries([],datastruct(rec(tr)).Data,info(rec(tr)),figH);
    hold on;
    
    % Mark Events:
    figH = rns_addmarkers(figH,datastruct(rec(tr)).Timestamps,[0.4,0.4,0.4]); % info(rec).post_trigger_length   -  actually pre-trigger
    % x = getappdata(h,'TherapyMarkers');
    % for i = 1:length(x); delete(x{i}); end
    
    % Option to save 
    pause %(.5)
    % saveas(gcf,sprintf('%s_TimeSeries_Rec%4.4d',info(rec(tr)).pt_id,rec(tr)),'png')
    
end
close
