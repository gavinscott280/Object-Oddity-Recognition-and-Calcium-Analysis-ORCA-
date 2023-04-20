function [Lookup, Aligned_behav,Behav_time,Behav_FPS] = align_timeseries(Behav_disc,Behav_start_frame,Behav_start,Time,Raw_data)
%Takes csv input from ObjExplorationTimer and aligns the behaviour output
%with Ca2+ frames

%   Align behaviour time and ca2+ time
Behav_frames = Raw_data.epocs.Cam1.data; %frame numbers

% I originally wrote the lines below because the ending timestamps are slightly different
% between the calcium trace and the behaviour timeseries and it seemed to
% intermittently cause problems, but the majority of the time it doesn't
% seem to matter. Comment it back in if necessary.

%if (size(Behav_disc,1) + (Behav_start_frame)) > max(Raw_data.epocs.Cam1.data)
    %Ind = max(Raw_data.epocs.Cam1.data) - (Behav_start_frame-1);
    %Behav_disc = Behav_disc(1:Ind,:);
%end

Behav_FPS = numel(Behav_frames)/max(Raw_data.epocs.Cam1.onset); %Behaviour frames/second
Behav_vars = size(Behav_disc,2); %Number of behaviour variables
Vid_start_time = ((Behav_start_frame)/Behav_FPS) - Behav_start; %calculate the video start timestamp
Behav_time = Raw_data.epocs.Cam1.onset; %timestamps for the behaviour video

% In order to make array dimensions equal, need to  remove all frames from
% the behaviour timeseries that weren't scored for object exploration

% Find the row index in the behaviour timeseries where the session starts
% (e.g. after baseline recording in start box) and remove behaviour frames
% from during the baseline recording
temp = abs(Behav_time - Behav_start);
[row] = find(ismember(Behav_time,(max(Behav_time(find(temp == min(abs(Behav_start - Behav_time))))))));
Behav_start_frame = Behav_time(row, 1);
Behav_time = Behav_time - Behav_start_frame;

%Find the row index for the beginning of the object exploration timeseries
%and remove the rest of the frames that weren't scored
temp = abs(Behav_time - Vid_start_time);
[row] = find(ismember(Behav_time,(max(Behav_time(find(temp == min(abs(Vid_start_time - Behav_time))))))));
Behav_time = Behav_time(row:end);



% Locate the closest behaviour video frame for each row in the Ca2+
% timeseries
Closest = [];
for i = 1:size(Time)
    t = Time(i,1);
    b = Behav_time;
    if min(abs(b(:,1) - t)) <= 1/Behav_FPS %matched behaviour frames should not be any further than 1/behaviour fps from a given FP frame
       [~,ind] = min(abs(b - t));
       Closest(i,:) = ind;
    else
       Closest(i,:) = NaN; %overly distant frames (tails of timeseries outside behav recording) assigned as NaN
    end
end

% make frame lookup table
Lookup = [];
Lookup(:,1) = Time;
Lookup(:,2) = Closest;
[ind,~] = find(~isnan(Lookup(:,2)) == 1);
Lookup = Lookup(ind,:);

%Align behaviour to lookup table

Aligned_behav = [];
for v = 1:Behav_vars
    Aligned_behav(:,v) = Behav_disc(Lookup(:,2),v);
end