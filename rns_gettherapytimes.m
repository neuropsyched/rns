function [therapy_times,detection_times] = rns_gettherapytimes(Events)

% rec = 53;
% [therapy_times,detection_times] = rns_gettherapytimes(datastruct(rec).Timestamps)

if isempty(Events)
    disp('No Timestamps')
    return
end

cfg.nevents = length(Events);
cfg.types = unique({Events(:).name});
for i = 1:length(cfg.types)
    cfg.idxtypes{i} = ~cellfun(@isempty, strfind({Events(:).name},cfg.types{i}));
end
cfg.idxdetection = find(cell2mat(cfg.idxtypes(~cellfun(@isempty, strfind(cfg.types,'Episode Start'))))==1);
cfg.ndetection = sum(double(~cellfun(@isempty, strfind(cfg.types,'Episode Start'))));
cfg.idxtherapies = find(cell2mat(cfg.idxtypes(~cellfun(@isempty, strfind(cfg.types,'Therapy Delivered'))))==1);
cfg.ntherapies = sum(double(cfg.idxtypes{~cellfun(@isempty, strfind(cfg.types,'Therapy Delivered'))}));

% Mark Start Epsiode
detection_times = cell2mat({Events(cfg.idxdetection(:)).start_time});

% Mark Therapies delivered
therapy_times = cell2mat({Events(cfg.idxtherapies(:)).start_time});
