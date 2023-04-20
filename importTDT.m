function [Filepath,Filename,Raw_data,Signal,Control,Time,Behav_start,Sampling_freq] = importTDT(Filepath) %
%importTDT imports a single TDT data tank to Matlab

% Import data tank
Raw_data = TDTbin2mat(Filepath);
Filename = Raw_data.info.blockname;

%Signal and Control channels
Signal = Raw_data.streams.x465A.data';
Control = Raw_data.streams.x405A.data';

%Other info
Sampling_freq = Raw_data.streams.x465A.fs;

%Create timestamps using sampling frequency
Time(1,:) = 1:numel(Raw_data.streams.x465A.data); Time = (Time/Raw_data.streams.x465A.fs)';

%Reserve an unaltered timestamp array that starts at zero
Raw_time(1,:) = 1:numel(Raw_data.streams.x465A.data); Raw_time = (Raw_time/Raw_data.streams.x465A.fs)';

%Create a shifted timestamp array with 0s == test start (Change as needed based on what events are keylogged in Synapse)
temp = abs(Time - Raw_data.epocs.door.onset);
[row] = find(ismember(Time,(max(Time(find(temp == min(abs(Raw_data.epocs.door.onset - Time))))))));
Behav_start = Time(row, 1);
Time = Raw_time - Behav_start;
end

