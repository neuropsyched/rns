function [datastruct,SUBJECTS_DIR,files] = rns_getstruct(PtId,SUBJECTS_DIR,varargin)
% Create Data Structure from RNS Files
% 
% USAGE: 
%       [datastruct] = rns_getstruct('GN7322');
%       [datastruct] = rns_getstruct('GN765937','/Volumes/Nexus/RNS_data/pdms64-dbserver_backups/upmc_dataExtract_2017-01-09/')
%
% Example:
%       SUBJECTS_DIR = '/Volumes/Nexus/RNS_data/pdms64-dbserver_backups/upmc_dataExtract_2017-01-09/';
%       [datastruct] = rns_getstruct(PtId,SUBJECTS_DIR);
% =========================================================================
% Ari Kappel, 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
if nargin==0
    ftmp = ea_uigetdir(pwd,'Choose Patient Directory');
    [SUBJECTS_DIR,PtId]=fileparts(ftmp{1});
elseif nargin==1
    SUBJECTS_DIR = ea_uigetdir(pwd,'Choose Subject Directory');
    %[SUBJECTS_DIR,PtId] = fileparts(pathname{1});
end

if strcmp(SUBJECTS_DIR(end),'/')
    SUBJECTS_DIR=SUBJECTS_DIR(1:end-1);
end

[chk,files] = rns_checkdir(SUBJECTS_DIR,PtId);
if chk; else; error('Please check input directories'); end
%%
% cd([SUBJECTS_DIR,filesep,PtId]); % cd(files.path)
nfiles = length(files.DAT);

datastruct = struct([]);
for i = 1:nfiles
    % fprintf(1,'reading file %d of %d\r',i,nfiles);
    rns_progress(i/nfiles, 'reading file %d of %d\n', i, nfiles);
    [ECoG_hdr, ECoG_data] = RNSReadECoGData(...
        [files.path,filesep,files.DAT{i}],...
        [files.path,filesep,files.lay{i}]);
    
    % Create Data Structure
    % Add PtId, index and fileID values
    datastruct(i,1).PtId = PtId;
    datastruct(i,1).index = i;
    
    fileID = char(files.DAT(i));
    datastruct(i,1).fileID = fileID(1:end-4); %remove extension

    % Add Data (cell 1xn where n is the number of channels)
    datastruct(i,1).Data = cell2mat(ECoG_data');
    
    % Add Hdr info
    datastruct(i,1).NPConfigString   = ECoG_hdr.NPConfigString;
    datastruct(i,1).PatientInitials  = ECoG_hdr.PatientInitials;
    datastruct(i,1).DeviceID         = ECoG_hdr.DeviceID;
    datastruct(i,1).TimeStampPatientLocalString = ECoG_hdr.TimeStampPatientLocalString;
    datastruct(i,1).SamplingRate     = ECoG_hdr.SamplingRate;
    datastruct(i,1).WaveformCount    = ECoG_hdr.WaveformCount;
    datastruct(i,1).ChannelMap       = ECoG_hdr.ChannelMap;
    datastruct(i,1).TriggerReason    = ECoG_hdr.TriggerReason;
    datastruct(i,1).Annotations      = ECoG_hdr.Annotations;
    datastruct(i,1).EnabledChannels  = ECoG_hdr.EnabledChannels;

    clear ECoG_data ECoG_hdr
end

detection_settings_gn = rns_accessmssql_server('detection_settings_gn_all');
detector_info = detection_settings_gn(end:-1:1); % Flip to sort dates in ascending order
datastruct = rns_getepochbin(datastruct,detector_info);

try 
    str = ['select * from rns_dm.data_timestamps d where d.pt_id = ''' PtId ''''];
    tmp = rns_accessmssql_server(str);
    datastruct = rns_gettimestamps(datastruct,tmp);
catch
    fprintf('Timestamp Data not available.')
end

sp = char(ea_uigetdir(pwd,'Choose Directory to Save Output'));
fName = char(inputdlg('save output as...','Ouput File Name',1,{[PtId '_datastruct.mat']}));

if ~isempty(sp) && ~isempty(fName)
    disp(['saving ''' fName ''' in ''' sp ''''])
    save(fullfile(sp,fName),'datastruct'); 
    rns_done()
else
    disp('Error: datastruct not saved')
end

     %%% Option to Overwrite Data in pwd %%%
     %     reply = input('Would you like to overwrite previous data? ','s');
     %     if strcmp(lower(reply),'yes')
     %         disp('saving DataStruct.mat in Subject Directory....')
     %         save(fullfile(SUBJECTS_DIR,PtId,'DataStruct.mat'),'datastruct')
     %     else
     %         disp('data not saved')
     %     end
     % end
     % orderfields(datastruct,[1,3,2,8,4,12,9,10,11,14,5,6,7,13]);
     % orderfields(datastruct,[1,3,2,15,8,4,12,9,10,11,14,5,6,7,13]); % with EpochBin
     % clc


% function datastruct = rns_getepochbin(datastruct,detector_info)
% % Get Serial Dates
% % Dependent on detector_info date sorted in ascending order
% epoch_date = datenum({detector_info.epoch_dts},'yyyy-mm-dd HH:MM:SS.FFF');
% date = datenum({datastruct.TimeStampPatientLocalString},'ddd, mmm dd, yyyy  HH:MM:SS' );
% % Compare Dates
% sEpoch_date = sort(epoch_date);
% if ~isequal(sEpoch_date,epoch_date)
%     error('detector_info.epoch_dts not sorted')
% end
% for j=1:length(date)
%     for k = 1:length(epoch_date)
%         if k<length(epoch_date)
%             if date(j)<epoch_date(1)
%                 datastruct(j).EpochBin = 0;
%             elseif epoch_date(k)<date(j) || date(j)>epoch_date(k+1)
%                 datastruct(j).EpochBin = k;
%             end
%         elseif k==length(epoch_date)
%             if epoch_date(k)<date(j)
%                 datastruct(j).EpochBin = k;
%             end
%         end
%     end
% end
     
% function datastruct = rns_gettimestamps(datastruct,sqlts)
% 
% % Get Timestamps from MSSQL output
% %
% % Example:
% %       PtId = 'GN7322';
% %       str = ['select * from rns_dm.data_timestamps d where d.pt_id = ''' PtId ''''];
% %       sqlts = rns_accessmssql_server(str);
% %       timestamps = rns_gettimestamps(datastruct,sqlts);
% 
% % cellfun(@strfind ,{sqlts(:).file_nm}', repmat({datastruct(1).fileID}, [6058,1]),'uni',0)
% 
% nfiles=length(datastruct);
% for i = 1:nfiles
%     rns_progress(i/nfiles, 'reading timestamps from file %d of %d\n', i, nfiles);
%     index{i}=find(~cellfun(@isempty,regexp({sqlts(:).file_nm},datastruct(i).fileID))==1);
% end
% 
% for i = 1:nfiles
%     %rns_progress(i/nfiles, 'getting timestamps for file %d of %d\n', i, nfiles);
%     if ~isempty(index{i})
%         rns_progress(i/nfiles, 'converting str2double from file %d of %d\n', i, nfiles);
%         
%         tmp = sqlts(index{i});
%         
%         % Sort Timestamps and convert from str2double
%         idx = arrayfun(@(x) find(str2double({tmp(:).start_time})==x),sort(str2double({tmp(:).start_time})),'uni',0);
%         cnt=1;
%         for j = 1:length(idx)
%             if size(idx{j},2)>1
%               idx{j}=idx{j}(cnt);
%               cnt=cnt+1;
%             end
%             datastruct(i).Timestamps(j) = tmp(idx{j});
%             datastruct(i).Timestamps(j).start_time = str2double(tmp(idx{j}).start_time);
%             datastruct(i).Timestamps(j).duration = str2double(tmp(idx{j}).duration);
%         end    
%         
%     else 
%         datastruct(i).Timestamps = struct([]);
%     end
% end


function [chk,files] = rns_checkdir(SUBJECTS_DIR,PtId)
    dirdir = dir([SUBJECTS_DIR,filesep,PtId]);
    fls = {dirdir(~[dirdir.isdir]).name};
    lay = ~cellfun(@isempty,strfind(fls,'.lay'));
    dat = ~cellfun(@isempty,strfind(fls,'.DAT'));
    
    if ~isempty(lay) && ~isempty(dat)
        chk=1;
    else
        chk=0;
    end
    
    files.path = [SUBJECTS_DIR,filesep,PtId];
    files.all = fls;
    files.DAT = files.all(dat);
    files.lay = files.all(lay);

    
function [ECoG_hdr, ECoG_data] = RNSReadECoGData(DATFile, LAYFile)

%Example Usage
%
%DATFile = '100315/127392201131430000.DAT';
%LAYFile = '100315/127392201131430000.lay';
%[ECoG_hdr, ECoG_data] = ReadECoGData(DATFile, LAYFile)
%

lay = textread(LAYFile,'%s','delimiter','\n','whitespace','');

ECoG_hdr.NPConfigString = ReadHeader('NPConfigStr', lay, 's');
ECoG_hdr.PatientInitials = ReadHeader('PatientInitials', lay, 's');
ECoG_hdr.DeviceID = ReadHeader('DeviceSerialNumber', lay, 'n');
ECoG_hdr.TimeStampPatientLocalString = ReadHeader('ECoGTimeStampAsLocalTime', lay, 's');
ECoG_hdr.SamplingRate = ReadHeader('SamplingRate', lay, 'n');
ECoG_hdr.WaveformCount = ReadHeader('WaveformCount', lay, 'n');
ECoG_hdr.ChannelMap = ReadChannelMap(lay);
ECoG_hdr.TriggerReason = ReadHeader('TriggerReason', lay, 's');
ECoG_hdr.Annotations = ReadHeader('Annotations', lay, 's');
if strcmp(ReadHeader('AmplifierChannel1ECoGStorageEnabled',lay, 's'), 'On')
    ECoG_hdr.EnabledChannels(1) = 1; else ECoG_hdr.EnabledChannels(1) = 0; 
end
if strcmp(ReadHeader('AmplifierChannel2ECoGStorageEnabled',lay, 's'), 'On')
    ECoG_hdr.EnabledChannels(2) = 1; else ECoG_hdr.EnabledChannels(2) = 0; 
end
if strcmp(ReadHeader('AmplifierChannel3ECoGStorageEnabled',lay, 's'), 'On')
    ECoG_hdr.EnabledChannels(3) = 1; else ECoG_hdr.EnabledChannels(3) = 0; 
end
if strcmp(ReadHeader('AmplifierChannel4ECoGStorageEnabled',lay, 's'), 'On')
    ECoG_hdr.EnabledChannels(4) = 1; else ECoG_hdr.EnabledChannels(4) =0; 
end
if findstr(ECoG_hdr.TriggerReason, 'USER_SAVED'); 
    ECoG_hdr.EnabledChannels = [1 1 1 1];
end


fid = fopen(DATFile);

dat = fread(fid,'int16');
fclose(fid);   
                         
% populate channels
ChannelNum = 0;
for ChannelIndex = 1:4
     if ECoG_hdr.EnabledChannels(ChannelIndex)
         ChannelNum = ChannelNum + 1;
     	 ECoG_data{ChannelIndex} = dat(ChannelNum:ECoG_hdr.WaveformCount:end)'-512;
     else
         ECoG_data{ChannelIndex} = [];
     end
end

%--------------------------------------------------------------------------
% function [value] = ReadHeader(VariableName, lay, type)
% function to read variables from .lay header
%--------------------------------------------------------------------------


function [value] = ReadHeader(VariableName, lay, type)
switch type
    case 's'
        myvalue{1} = '';
    case 'n'
        myvalue{1} = 0;
end
VariableNum = 0;
for i = 1:length(lay)
    if ~isempty(strfind(lay{i}, [VariableName '=']))
        VariableNum = VariableNum+1;
        switch type
            case 'n'
                myvalue{VariableNum} = str2num(lay{i}(length(VariableName) + 2:end));
            case 's'
                myvalue{VariableNum} = lay{i}(length(VariableName) + 2:end);
        end
        
    end
end
if VariableNum <= 1
    value = myvalue{1};
else
    value = myvalue;
end

%--------------------------------------------------------------------------
% function [ChannelMap] = ReadChannelMap(lay)
% function to read ChannelMap from .lay header
%--------------------------------------------------------------------------

function [ChannelMap] = ReadChannelMap(lay)
ChannelMap{1} = ''; ChannelMap{2} = ''; ChannelMap{3} = ''; ChannelMap{4} = '';
for i = 1:length(lay)
    if ~isempty(findstr(lay{i},'[ChannelMap]'))
        for j = 1:4
            if ~isempty(findstr(lay{i+j},'='))
              ChannelNumber = str2num(lay{i+j}(findstr(lay{i+j},'=')+1:end));
              ChannelMap{ChannelNumber} = lay{i+j}(1:findstr(lay{i+j},'=')-1);
            end
        end        
    end
end

    
function [pathname] = ea_uigetdir(start_path, dialog_title)
% Pick a directory with the Java widgets instead of uigetdir

import javax.swing.JFileChooser;

if nargin == 0 || strcmp(start_path,'') % Allow a null argument.
    start_path = pwd;
end

jchooser = javaObjectEDT('javax.swing.JFileChooser', start_path);

jchooser.setFileSelectionMode(JFileChooser.FILES_AND_DIRECTORIES);
if nargin > 1
    jchooser.setDialogTitle(dialog_title);
end

jchooser.setMultiSelectionEnabled(true);

status = jchooser.showOpenDialog([]);

if status == JFileChooser.APPROVE_OPTION
    jFile = jchooser.getSelectedFiles();
    pathname{size(jFile, 1)}=[];
    for i=1:size(jFile, 1)
        pathname{i} = char(jFile(i).getAbsolutePath);
    end

elseif status == JFileChooser.CANCEL_OPTION
    pathname = [];
else
    error('Error occured while picking file.');
end

% function rns_progress(varargin)
% % Small function to show progress in command window
% %
% % Example:
% %       rns_progress(i/nfiles, 'reading file %d of %d\n', i, nfiles);
% 
% if nargin>1
%     strlen = length(sprintf(varargin{2:end}));
%     if varargin{3}==10 || varargin{3}==100 || varargin{3}==1000 || varargin{3}==10000 || varargin{3}==100000
%         strlen=strlen-1;
%     end
%     if varargin{3}~=1
%         fprintf([repmat('\b',[1 strlen]), sprintf(varargin{2:end})])
%     else   
%         fprintf(varargin{2:end})
%     end    
% end
% 
% function rns_done()
%         disp(char({' _____   ____  _   _ ______ ' 
%  '|  __ \ / __ \| \ | |  ____|'
%  '| |  | | |  | |  \| | |__   '
%  '| |  | | |  | | . ` |  __|  '
%  '| |__| | |__| | |\  | |____ '
%  '|_____/ \____/|_| \_|______| '}))


