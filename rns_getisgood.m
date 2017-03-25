function [data,recid,datastruct] = rns_getisgood(datastruct,prewin,postwin)

% [data,recid] = rns_getisgood(datastruct);
% Default prewin = 10s;
% Default postwin = 3s
%
% [data,recid,datastruct] = rns_getisgood(datastruct,prewin,postwin)

% Idx{2} = find(~cellfun(@isempty,strfind({info.trigger_reason},'LONG_EPISODE'))==1);

if ~exist('prewin','var')
    prewin = 10;
end

if ~exist('postwin','var')
    postwin = 3;
end

[datastruct] = rns_datastruct2stimtimes(datastruct);

srate = 250;

for rec=1:length(datastruct);
    try
        prestims{rec} = diff([0,datastruct(rec).stimtimes]);
        poststims{rec} = diff([datastruct(rec).stimtimes,size(datastruct(rec).Data,2)/srate]);
        datastruct(rec).soi = datastruct(rec).stimtimes(prestims{rec}>prewin & poststims{rec}>postwin);
        for j = 1:length(datastruct(rec).soi)
            datastruct(rec).soi_data{j} = datastruct(rec).Data(:,[datastruct(rec).soi(j)*srate-prewin*srate:datastruct(rec).soi(j)*srate+postwin*srate]);
        end
        datastruct(rec).soi_data = cat(3,datastruct(rec).soi_data{:});
        datastruct(rec).recid = repmat(rec,size(datastruct(rec).soi_data,3),1);
    catch
        datastruct(rec).soi = [];
    end
end

tmp = cat(1,datastruct(:).recid);
X = cat(3,datastruct(:).soi_data); 
if iscell(X)
    X = cat(3,X{:});
end

for ch = 1:4
    data{ch,1} = squeeze(X(ch,:,:));
    recid{ch,1} = tmp(:);
end

% imagesc( squeeze(any(X<-400|X>400,2)) )
% sum(squeeze(any(X<-400|X>400,2)),2)

var = (X>400|X<-400);
isbad = diff(X,1,2)==0&var(:,1:end-1,:);
isgood = ~squeeze(any(isbad(:,[1:prewin*srate,(prewin+1)*srate:size(isbad,2)],:),2));
data = cellfun(@(x,y) x(:,isgood(y,:)), data, num2cell(1:4)','uni',0);
recid = cellfun(@(x,y) x(isgood(y,:)), recid, num2cell(1:4)','uni',0);

% imagesc(isgood)
% sum(isgood,2)
% 
% figure;
% ch=1;
% plot(squeeze(X(ch,:,~isgood(ch,:))))