function p = rns_plot(x,y)

% data is ch x time
% nchan = 4;
% Example: 
%   rec=53
%   figH = rns_plottimeseries(figH,datastruct(rec).Data,info(rec))

% Set defaults

tmp = size(y);
if tmp(1)~=4
    y = y';
end

if ~exist('srate','var')
    srate = 250;
end

if ~exist('Amp','var')
    Amp = round(max(max(y'))/100)*100;
end

Ldata = size(y,2);
if ~ exist('x','var')
    x = (0:Ldata-1)/srate;
end
%% Plot
nchan = size(y,1);
Amp = Amp/(1+1/nchan)*2;
offset = repmat(Amp*(nchan:-(1+1/nchan):0)',[1,Ldata]);

%
% set(0,'CurrentFigure',figH)
p = plot(x(1,:),y+offset);
%

set(gca,'xlim',[x(1) x(end)],'ylim',[-Amp Amp*5])
tmp = get(gca,'ylim');
set(gca,'ytick',[-Amp:(tmp(2))/8:tmp(2)],'YTickLabel',repmat({'0'; sprintf('+/-%03d',round(Amp*(1+1/nchan)/2))},[5 1]))
ylabel('Amplitude (mA)');
xlabel('Times (s)');
