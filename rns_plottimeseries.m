function figH = rns_plottimeseries(time,data,info,figH,srate,Amp)

% data is ch x time
% nchan = 4;
% Example: 
%   rec=53
%   figH = rns_plottimeseries(figH,datastruct(rec).Data,info(rec))

% Set defaults

tmp = size(data);
if tmp(1)~=4
    data = data';
end

if ~exist('figH','var')
    figH = figure;
end

if ~exist('srate','var')
    srate = 250;
end

if ~exist('Amp','var')
    Amp = 500;
end

Ldata = size(data,2);
if ~exist('time','var') || isempty(time)
    time = (0:Ldata-1)/srate;
end
%% Plot
nchan = size(data,1);
Amp = Amp/(1+1/nchan)*2;
offset = repmat(Amp*(nchan:-(1+1/nchan):0)',[1,Ldata]);

%
set(0,'CurrentFigure',figH)
p = plot(time,data+offset);
%

set(gca,'xlim',[time(1) time(end)],'ylim',[-Amp Amp*5])
tmp = get(gca,'ylim');
set(gca,'ytick',[-Amp:(tmp(2))/8:tmp(2)],'YTickLabel',repmat({'0'; sprintf('+/-%03d',round(Amp*(1+1/nchan)/2))},[5 1]))
ylabel('Amplitude (mA)');
xlabel('Times (s)');
try
    title({[info.pt_id ' - ' 'Recording ' num2str(info.np_comment_id)];...
        strrep(info.trigger_reason,'_',' ')})
end

%% Notes:
% %% 3. Time Series
%     h = figure; hold on; set(gcf,'Position',[34   336   779   649])
% for n=1:length(Idx{ttype_idx});
% rec = Idx{ttype_idx}(n); % ONLY USING ONE RECORDING for now
%     % Get trial data
%     %srate = datastruct(rec).SamplingRate; % takes only the first one
%     % 3. Plot Time Series
%     % data = datastruct(rec).Data; %{ch x time}
%     time = (0:numel(data(:,1,rec))-1)/srate;
%     % Amp = ceil(max(max(data))/100)*100;
%     Amp = 300*2;
%     offset = repmat(Amp*(nch:-(1+1/nchan):0)',[1,size(data,1)]);
%     
%     hold off
%     p = plot(time(1:rec_length(rec)),squeeze(data(1:rec_length(rec),:,rec))'+offset(:,1:rec_length(rec)));
%     %     set(gca,'xlim',[0 90],'ylim',[-Amp*3/4 Amp*(nch-1)+Amp*3/4],'YTickLabel',repmat({['+/-' num2str(Amp*0.5)]; '0'},[5 1]))
%     hold on
%     set(gca,'xlim',[0 90],'ylim',[-Amp Amp*5])
%     tmp = get(gca,'ylim');
%     set(gca,'ytick',[-Amp:(tmp(2))/8:tmp(2)],'YTickLabel',repmat({'0'; ['+/-' num2str(Amp*0.5)]},[5 1]))
%     ylabel('Amplitude (mA)'); 
%     xlabel('Times (s)');
%     % trigstr = datastruct(rec).TriggerReason; % trigstr(strfind(trigstr,'_'))= ' ';
%     trigstr = strrep(info(rec).trigger_reason,'_',' ');    
%     title({[info(rec).pt_id ' - ' 'Recording ' num2str(rec)];trigstr})
%     
%     % TextBox for Channel Labels
%     %     fpos = get(gcf,'Position'); %frame size: [x1, y1, width, height]
%     %     apos = get(gca,'Position'); % axis size:
%     %     textPos = { [-2.7, 2760]; [-2.7, 1720]; [-2.7, 700]; [-2.7, -280] };
%     %     for j=1:4
%     %         % BoxStr{i} = ['Channel' num2str(i) ': ' eval(['info(trials(i)).channel' num2str(i)])];
%     %         BoxStr{j} = ['Channel' num2str(j) ': ' datastruct(trials(i)).ChannelMap{j}];
%     %         TextBox = text(textPos{j}(1),textPos{j}(2),BoxStr{j}); set(TextBox,'rotation', 90);
%     %     end
%     % disp(['saving Recording: ' num2str(rec)]);
% 
% % Mark Events:
%     h = rns_addmarkers(h,datastruct(rec).Timestamps,[0.4,0.4,0.4]); % info(rec).post_trigger_length   -  actually pre-trigger
%     % x = getappdata(h,'TherapyMarkers');
%     % for i = 1:length(x); delete(x{i}); end
%     
%     plot(stim_win(n,3)*[1 1],ylim,'--') % info(rec).pre_trigger_length  -  actually post-trigger
%     pause
%     %try; mkdir([datapath '/images/' info(rec).pt_id '/' trial_type{ttype_idx}]); end
%     %saveas(gcf,[datapath '/images/' info(rec).pt_id '/' trial_type{ttype_idx} '/TimeSeries_Rec' sprintf('%4.4d',rec) '.png'])
%     %close
% end
