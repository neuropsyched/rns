function FTdata = rns_datastruct2fieldtrip(datastruct,options)
% FTdata_pre = rns_datastruct2fieldtrip(datastruct,'prestim');
% FTdata_post = rns_datastruct2fieldtrip(datastruct,'poststim');
%
if nargin==1
    options = '';
end

%%
FTdata.hdr.Fs = datastruct.SamplingRate;
FTdata.hdr.nChans = size(datastruct(1).Data,1);
FTdata.hdr.nSamples = cellfun(@numel, {datastruct(:).Data})./FTdata.hdr.nChans;
FTdata.hdr.nTrials = length(datastruct);
FTdata.hdr.label = datastruct(1).ChannelMap;

[pre_stim,post_stim,~,results] = rns_datastruct2stimwin(datastruct);

FTdata.label = datastruct(1).ChannelMap;
FTdata.fsample = datastruct.SamplingRate;

srate = FTdata.fsample;
switch options
    
    case 'prestim'
        FTdata.trial = pre_stim;
        for i = 1:length(FTdata.trial)
            stimtimes = {datastruct(results.rec(i)).Timestamps(results.cfg(i).idxtherapies(:)).start_time}';
            FTdata.time{i} = (round(stimtimes{results.cfg(i).start_stimwin}*srate)-length(FTdata.trial{i})+1:round(stimtimes{results.cfg(i).start_stimwin}*srate))./srate;
            FTdata.trialinfo(i) = 1;        
        end

    case 'poststim'
        FTdata.trial = post_stim;
        for i = 1:length(FTdata.trial)
            stimtimes = {datastruct(results.rec(i)).Timestamps(results.cfg(i).idxtherapies(:)).start_time}';
            FTdata.time{i} = (round(stimtimes{results.cfg(i).stop_stimwin}*srate)+1:round(stimtimes{results.cfg(i).stop_stimwin}*srate)+length(FTdata.trial{i}))./srate;
            FTdata.trialinfo(i) = 3;
        end    
        
    otherwise % General
        FTdata.trial = {datastruct(:).Data};
        for i = 1:FTdata.hdr.nTrials
            FTdata.time{i} = linspace(0,FTdata.hdr.nSamples(i)/FTdata.hdr.Fs,FTdata.hdr.nSamples(i));
            switch datastruct(i).TriggerReason
                case 'ECOG_SCHEDULED_CATEGORY'
                    FTdata.trialinfo(i) = 1;
                case 'ECOG_LONG_EPISODE_CATEGORY'
                    FTdata.trialinfo(i) = 2;
                case 'ECOG_SATURATION_CATEGORY'
                    FTdata.trialinfo(i) = 3;
                case 'STR_DIAG_ECOG_REASON_USER_SAVED'
                    FTdata.trialinfo(i) = 4;
                otherwise
                    FTdata.trialinfo(i) = 0;
            end
        end
end

FTdata.recidx = results.rec;
%% Structure:
% dataFIC = 
% 
%            hdr: [1x1 struct]
%          label: {149x1 cell}
%           time: {1x77 cell}
%          trial: {1x77 cell}
%        fsample: 300
%     sampleinfo: [77x2 double]
%      trialinfo: [77x1 double]
%           grad: [1x1 struct]
%            cfg: [1x1 struct]

% dataFIC.hdr = 
% 
%              Fs: 300
%          nChans: 187
%        nSamples: 900
%     nSamplesPre: 300
%         nTrials: 266
%           label: {187x1 cell}
%            grad: [1x1 struct]
%            orig: [1x1 struct]

% dataFIC.hdr.orig = 
% 
%         baseName: 'removed by ft_anonimizedata'
%             path: 'removed by ft_anonimizedata'
%             res4: [1x1 struct]
%             meg4: [1x1 struct]
%            newds: 'removed by ft_anonimizedata'
%              acq: [1x621 struct]
%             hist: 'removed by ft_anonimizedata'
%               hc: [1x1 struct]
%              eeg: [1x1 struct]
%              mrk: [1x6 struct]
%       TrialClass: [1x1 struct]
%      badSegments: [1x1 struct]
%      BadChannels: 'removed by ft_anonimizedata'
%       processing: 'removed by ft_anonimizedata'
%     BalanceCoefs: [1x1 struct]

% dataFIC.cfg = 
% 
%          keepfield: {1x9 cell}
%          keepvalue: {'yes'  'no'}
%        removefield: {'dataset'  'datafile'  'headerfile'  'eventfile'  'orig'}
%          inputfile: '/home/common/matlab/fieldtrip/data/ftp/tutorial/timefrequencyanalysis/dataFIC.mat'
%         outputfile: '/home/common/matlab/fieldtrip/data/ftp/tutorial/timefrequencyanalysis/dataFIC.mat'
%           callinfo: [1x1 struct]
%            version: [1x1 struct]
%        trackconfig: 'off'
%        checkconfig: 'loose'
%          checksize: 100000
%       showcallinfo: 'yes'
%              debug: 'no'
%      trackcallinfo: 'yes'
%      trackdatainfo: 'no'
%     trackparaminfo: 'no'
%            warning: [1x1 struct]
%        removevalue: {}
%        keepnumeric: 'yes'
%           previous: [1x1 struct]