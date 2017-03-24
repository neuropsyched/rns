function [figH,therapy_times] = rns_addmarkers(figH,Events,c)

if ~exist('c','var')
    c = [0.65,0.65,0.65];
end
set(0,'CurrentFigure',figH); hold on;

cfg.nevents = length(Events);
cfg.types = unique({Events(:).name});
for i = 1:length(cfg.types)
    cfg.idxtypes{i} = ~cellfun(@isempty, strfind({Events(:).name},cfg.types{i}));
end
cfg.idxdetection = find(cell2mat(cfg.idxtypes(~cellfun(@isempty, strfind(cfg.types,'Episode Start'))))==1);
cfg.ndetection = sum(double(~cellfun(@isempty, strfind(cfg.types,'Episode Start'))));
cfg.idxtherapies = find(cell2mat(cfg.idxtypes(~cellfun(@isempty, strfind(cfg.types,'Therapy Delivered'))))==1);
cfg.ntherapies = sum(double(cfg.idxtypes{~cellfun(@isempty, strfind(cfg.types,'Therapy Delivered'))}));

% colororder = repmat(rns_getpsdcolor,[4,1]);
% c = [0.75 0.75 0.75];

% Mark Start Epsiode
markers = cell(cfg.ndetection,1);
for i = 1:cfg.ndetection
    try
    markers{i}=plot(Events(cfg.idxdetection(i)).start_time*[1 1],ylim,...
        'color',[0.5 0.0 0.0],'linestyle','--','visible','off');
    end
end
setappdata(figH,'StartEpisode',markers)

% Mark Therapies delivered
markers = cell(cfg.ntherapies,1);
therapy_times = cell2mat({Events(cfg.idxtherapies(:)).start_time});
for i = 1:cfg.ntherapies
    markers{i}=plot(therapy_times(i)*[1 1],ylim,...
        'color',c,'linestyle','--','linewidth',1);
end
setappdata(figH,'TherapyMarkers',markers)