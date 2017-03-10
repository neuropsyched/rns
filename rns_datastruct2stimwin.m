function [pre_stim,post_stim,stim_win,results] = rns_datastruct2stimwin(datastruct)

if ~isfield(datastruct,'Timestamps')
    error('Missing Timestamps')
end

srate = datastruct(1).SamplingRate;

rec = find(~cellfun(@isempty,strfind({datastruct.TriggerReason},'LONG_EPISODE'))==1); %cfg.trials
results.orig.rec =rec;

cfg = struct([]);
emptyrecs = [];
therapynotdelivered = [];
for i = 1:length(rec)
    Events = datastruct(rec(i)).Timestamps;
    if ~isempty(Events)
        cfg(i).nevents = length(Events);
        cfg(i).types = unique({Events(:).name});
        for j = 1:length(cfg(i).types)
            cfg(i).idxtypes{j} = ~cellfun(@isempty, strfind({Events(:).name},cfg(i).types{j}));
        end
        cfg(i).idxdetection = find(cell2mat(cfg(i).idxtypes(~cellfun(@isempty, strfind(cfg(i).types,'Episode Start'))))==1);
        cfg(i).ndetection = sum(double(~cellfun(@isempty, strfind(cfg(i).types,'Episode Start'))));
        cfg(i).idxtherapies = find(cell2mat(cfg(i).idxtypes(~cellfun(@isempty, strfind(cfg(i).types,'Therapy Delivered'))))==1);
        try
            cfg(i).ntherapies = sum(double(cfg(i).idxtypes{~cellfun(@isempty, strfind(cfg(i).types,'Therapy Delivered'))}));
        catch
            therapynotdelivered = [therapynotdelivered,i];
        end
    else
        emptyrecs = [emptyrecs,i];
    end
end
results.orig.cfg = cfg;

results.rec = rec(setdiff(setdiff(1:length(rec),emptyrecs),therapynotdelivered));
results.cfg = cfg(setdiff(1:length(cfg),therapynotdelivered));
results.emptyrecs = emptyrecs;
results.therapynotdelivered = therapynotdelivered;

cfg = results.cfg;
start_trialskips=[];
stop_trialskips=[];
stim_win = ones(length(results.rec),size(datastruct(1).Data,1));
for i = 1:length(results.rec)
    % Skip for stims outside of [20 70] second window
    stimtimes = {datastruct(results.rec(i)).Timestamps(results.cfg(i).idxtherapies(:)).start_time};
    [cfg(i).start_stimwin,cfg(i).stop_stimwin] = check_stimtimes(stimtimes);
    if cfg(i).start_stimwin~=1; start_trialskips = [start_trialskips i]; end
    if cfg(i).stop_stimwin~=length(stimtimes); stop_trialskips = [stop_trialskips i]; end
    stim_win(i,1) = 0;
    stim_win(i,2) = datastruct(results.rec(i)).Timestamps(results.cfg(i).idxtherapies(cfg(i).start_stimwin)).start_time;
    stim_win(i,3) = datastruct(results.rec(i)).Timestamps(results.cfg(i).idxtherapies(cfg(i).stop_stimwin)).start_time;
    stim_win(i,4) = size(datastruct(results.rec(i)).Data,2)/srate;
end
results.cfg = cfg;

Lwin = 28*srate; % 7000 samples
shorttrials = [];
badtrials = [];
for i = 1:length(results.rec)
    results.orig.win_idx(i).pre = stim_win(i,1)*srate+1:stim_win(i,2)*srate;
    results.orig.win_idx(i).stim = stim_win(i,2)*srate+1:stim_win(i,3)*srate;
    results.orig.win_idx(i).post = stim_win(i,3)*srate+1:stim_win(i,4)*srate;
    
    if length(results.orig.win_idx(i).pre)<Lwin || length(results.orig.win_idx(i).post)<Lwin
        results.win_idx(i).error = sprintf('Short Window: Pre=%d or Post=%d Samples',length(results.orig.win_idx(i).pre),length(results.orig.win_idx(i).post));
        shorttrials = [shorttrials i];
        if min(length(results.orig.win_idx(i).pre),length(results.orig.win_idx(i).post))<500
           badtrials = [badtrials i];
        else
            Mwin = min(length(results.orig.win_idx(i).pre),length(results.orig.win_idx(i).post));
            results.win_idx(i).pre = stim_win(i,2)*srate-Mwin+1:stim_win(i,2)*srate;
            results.win_idx(i).post = stim_win(i,4)*srate-Mwin+1:stim_win(i,4)*srate;
        end
    else
        results.win_idx(i).pre = stim_win(i,2)*srate-Lwin+1:stim_win(i,2)*srate;
        results.win_idx(i).post = stim_win(i,4)*srate-Lwin+1:stim_win(i,4)*srate;
    end
end

results.shorttrials = shorttrials;
results.badtrials = badtrials;
results.start_trialskips = start_trialskips;
results.stop_trialskips = stop_trialskips;

% NOTES: 
% {results.win_idx(results.shorttrials).error}'
% {results.win_idx(badtrials).error}'

pre_stim=cell(1,length(results.rec));
post_stim=cell(1,length(results.rec));
for i = 1:length(results.rec)
    pre_stim{i} = datastruct(results.rec(i)).Data(:,results.win_idx(i).pre);
    post_stim{i} = datastruct(results.rec(i)).Data(:,results.win_idx(i).post);
end

function [startstim,stopstim] = check_stimtimes(stimtimes)

    startstim=1;
    while stimtimes{startstim}<20
        %stimstart = find(stimtimes(iStim)==stimtimes)
        startstim=startstim+1;
    end
    
    stopstim=length(stimtimes);
    while stimtimes{stopstim}>70
        %stimstart = find(stimtimes(iStim)==stimtimes)
        stopstim=stopstim-1;
    end
    
    