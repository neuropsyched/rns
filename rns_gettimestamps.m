function datastruct = rns_gettimestamps(datastruct,sqlts)

% Get Timestamps from MSSQL output
%
% Example:
%       PtId = 'GN7322';
%       str = ['select * from rns_dm.data_timestamps d where d.pt_id = ''' PtId ''''];
%       sqlts = rns_accessmssql_server(str);
%       timestamps = rns_gettimestamps(datastruct,sqlts);

% cellfun(@strfind ,{sqlts(:).file_nm}', repmat({datastruct(1).fileID}, [6058,1]),'uni',0)

nfiles=length(datastruct);
for i = 1:nfiles
    rns_progress(i/nfiles, 'reading timestamps from file %d of %d\n', i, nfiles);
    index{i}=find(~cellfun(@isempty,regexp({sqlts(:).file_nm},datastruct(i).fileID))==1);
end

for i = 1:nfiles
    %rns_progress(i/nfiles, 'getting timestamps for file %d of %d\n', i, nfiles);
    if ~isempty(index{i})
        rns_progress(i/nfiles, 'converting str2double from file %d of %d\n', i, nfiles);
        
        tmp = sqlts(index{i});
        
        % Sort Timestamps and convert from str2double
        idx = arrayfun(@(x) find(str2double({tmp(:).start_time})==x),sort(str2double({tmp(:).start_time})),'uni',0);
        cnt=1;
        for j = 1:length(idx)
            if size(idx{j},2)>1
              idx{j}=idx{j}(cnt);
              cnt=cnt+1;
            end
            datastruct(i).Timestamps(j) = tmp(idx{j});
            datastruct(i).Timestamps(j).start_time = str2double(tmp(idx{j}).start_time);
            datastruct(i).Timestamps(j).duration = str2double(tmp(idx{j}).duration);
        end    
        
    else 
        datastruct(i).Timestamps = struct([]);
    end
end



function rns_progress(varargin)
% Small function to show progress in command window
%
% Example:
%       rns_progress(i/nfiles, 'reading file %d of %d\n', i, nfiles);

if nargin>1
    strlen = length(sprintf(varargin{2:end}));
    if varargin{3}==10 || varargin{3}==100 || varargin{3}==1000 || varargin{3}==10000 || varargin{3}==100000
        strlen=strlen-1;
    end
    if varargin{3}~=1
        fprintf([repmat('\b',[1 strlen]), sprintf(varargin{2:end})])
    else   
        fprintf(varargin{2:end})
    end
    
end