function [data] = rns_traintimes(datastruct,prewin,postwin)

% Default prewin = 10s;
% Default postwin = 15s
%
% [data] = rns_traintimes(datastruct,10,15)

% Idx{2} = find(~cellfun(@isempty,strfind({info.trigger_reason},'LONG_EPISODE'))==1);

%%
if ~exist('prewin','var')
    prewin = 10;
end

if ~exist('postwin','var')
    postwin = 15;
end

[datastruct] = rns_datastruct2stimtimes(datastruct);

srate = 250;

counter=1;
for rec=1:length(datastruct);
    try
        stims = datastruct(rec).stimtimes';
        prestims = diff([0;stims]);
        poststims = diff([stims;size(datastruct(rec).Data,2)/srate]);
        starts=find(prestims>prewin);
        ends=find(poststims>postwin);
        edges=[starts;ends];%use unique to exlude isolated pulses
        edgeid=[false(size(starts));true(size(ends))];
        [sortedges,b]=sort(edges);
        sortedgeid=edgeid(b);
        goodstarts=find([diff(sortedgeid)==1;0]);
        %subcounter=1;
        for n=1:length(goodstarts)
            tmp=[sortedges(goodstarts(n)):sortedges(goodstarts(n)+1)];
            if all(diff(stims(tmp))<5) & all(diff(stims(tmp))>1)
                traintimes=stims(tmp);
                data(counter).recid = rec;
                data(counter).tsraw = datastruct(rec).Data;
                data(counter).traintimes = traintimes;
                counter = counter+1;
            end
        end
    end
    clear traintimes
end

% check hist of interval times
% tmp = arrayfun(@(x) cellfun(@(y) diff(y),x.traintimes,'uni',0),data,'uni',0);
% tmp = cellfun(@(x) cat(1,x{:}),tmp,'uni',0);
% tmp = cat(1,tmp{:});

interwin = 1.5;
% if any(tmp<interwin)
%     error('check interwindows')
% end

for i = 1:length(data)
    tstart = data(i).traintimes(1)*srate;
    tend = data(i).traintimes(end)*srate;
    data(i).tsprewin = data(i).tsraw(:,tstart-prewin*srate:tstart);
    data(i).tspostwin = data(i).tsraw(:,tend:tend+postwin*srate);
    if length(data(i).traintimes)>1
        for k = 1:length(data(i).traintimes)-1
            tstart = floor(data(i).traintimes(k)*srate);
            data(i).tsinterwin{k} = data(i).tsraw(tstart:floor(tstart+interwin*srate));
        end
    end
end

% for i = 1:length(data)
%     for j = 1:length(data(i).traintimes)
%         tstart = data(i).traintimes{j}(1)*srate;
%         tend = data(i).traintimes{j}(end)*srate;
%         data(i).tsprewin{j} = data(i).tsraw(:,tstart-prewin*srate:tstart);
%         data(i).tspostwin{j} = data(i).tsraw(:,tend:tend+postwin*srate);
%         if length(data(i).traintimes{j})>1
%             for k = 1:length(data(i).traintimes{j})-1
%                 tstart = floor(data(i).traintimes{j}(k)*srate);
%                 data(i).tsinterwin{j}{k} = data(i).tsraw(tstart:floor(tstart+interwin*srate));
%             end
%         end
%     end
% end

% find(arrayfun(@(x) length(x.traintimes),data)==2)

%% 
postll=arrayfun(@(x) mean(abs(diff(x.tspostwin'))),data,'uni',0);
postll=cat(1,postll{:});



%
end