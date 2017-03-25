% 1. get rns datastruct and info
clear; clc; close all

dp='/Users/arikappel/Documents/MATLAB/Richardsonlab/RNS'; %datapath
mp='/Users/arikappel/Documents/MATLAB/Richardsonlab/RNS/rns'; %matlabpath

patients = {'DD762713','CM723654','GN765937','DW728352'};
PtId=patients{1};

load(fullfile(dp,PtId,[PtId '_datastruct.mat']))
load(fullfile(dp,PtId,[PtId '_info.mat']))

[data,recid,datastruct] = rns_getisgood(datastruct,10,3);

