function [data,rec_length] = rns_datastruct2array(datastruct)

for i = 1:length(datastruct)
    try %legacy
        datacell{:,i,:} = cell2mat(datastruct(i).Data')'; %time x channel
    catch
        datacell{:,i,:} = datastruct(i).Data';
    end
end

for i = 1:length(datacell)
    rec_length(i) = length(datacell{i});
end

data = zeros(max(rec_length),4,length(datacell)); %time x channel x trial
for i = 1:length(datacell)
    l = length(datacell{i});
    data(1:l,:,i) = datacell{i};
end