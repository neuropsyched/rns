function datastruct = rns_getepochbin(datastruct,detector_info)

% Get Serial Dates
% Dependent on detector_info date sorted in ascending order
epoch_date = datenum({detector_info.epoch_dts},'yyyy-mm-dd HH:MM:SS.FFF');
date = datenum({datastruct.TimeStampPatientLocalString},'ddd, mmm dd, yyyy  HH:MM:SS' );
% Compare Dates
sEpoch_date = sort(epoch_date);
if ~isequal(sEpoch_date,epoch_date)
    error('detector_info.epoch_dts not sorted')
end
for j=1:length(date)
for k = 1:length(epoch_date)
    if k<length(epoch_date)
        if date(j)<epoch_date(1)
            datastruct(j).EpochBin = 0;
        elseif epoch_date(k)<date(j) || date(j)>epoch_date(k+1)
            datastruct(j).EpochBin = k;
        end
    elseif k==length(epoch_date)
        if epoch_date(k)<date(j)
            datastruct(j).EpochBin = k;
        end
    end
end
end
