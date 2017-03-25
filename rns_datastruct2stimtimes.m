function [datastruct,therapynotdelivered] = rns_datastruct2stimtimes(datastruct)

if ~isfield(datastruct,'Timestamps')
    error('Missing Timestamps')
end

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

for i = 1:length(datastruct)
    datastruct(i).stimtimes = [];
end

% Skip for stims outside of [20 70] second window
for i = 1:length(results.rec)
    datastruct(results.rec(i)).stimtimes = cell2mat({datastruct(results.rec(i)).Timestamps(results.cfg(i).idxtherapies(:)).start_time});
end
return

