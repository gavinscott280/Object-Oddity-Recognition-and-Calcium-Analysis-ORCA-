function [Signal,Control,Time] = hardcode_trim(Starttime,Endtime,Signal,Control,Time)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if ~isnan(Starttime) == 1
    temp = abs(Time - Starttime);
    [row] = find(ismember(Time,(max(Time(find(temp == min(abs(Starttime - Time))))))));
    Startframe = row;
elseif isnan(Starttime) == 1
    Startframe = 1;
end
clearvars temp row

if ~isnan(Endtime) == 1
    temp = abs(Time - Endtime);
    [row] = find(ismember(Time,(max(Time(find(temp == min(abs(Endtime - Time))))))));
    Endframe = row;
elseif isnan(Endtime) == 1
    [row] = find(Time == max(Time)); 
    Endframe = row;
end
clearvars temp row
Time = Time(Startframe:Endframe,1);
Signal = Signal(Startframe:Endframe,1);
Control = Control(Startframe:Endframe,1);
end

