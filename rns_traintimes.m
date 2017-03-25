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
        subcounter=1;
        for n=1:length(goodstarts)
            tmp=[sortedges(goodstarts(n)):sortedges(goodstarts(n)+1)];
            if all(diff(stims(tmp))<5)
                traintimes{subcounter}=stims(tmp);
                subcounter=subcounter+1;
            end
        end
        if exist('traintimes','var')
            data(counter).recid = rec;
            data(counter).tsraw = datastruct(rec).Data;
            data(counter).traintimes = traintimes;
            counter = counter+1;
        end
    end
    clear traintimes
end




