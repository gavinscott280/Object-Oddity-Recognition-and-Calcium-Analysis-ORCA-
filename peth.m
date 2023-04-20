function [Histo_inds,PETH,Processed] = peth(Epochs,Onset_lag,Offset_lag,Sampling_freq,Time,Processed,Intercept)
%peth takes the indices of each behaviour epoch, applies user settings, and
%creates the indices for peri-event time histograms

%Convert user settings from time (s) to closest row index. Get 
Onset = round(Onset_lag*Sampling_freq);
Offset = round(Offset_lag*Sampling_freq);
Time_inds = find(Time);
Fn = fieldnames(Epochs);

% Loops over each behaviour variable, and over each epoch within each
% variable, and accepts epochs that pass the user-defined filters and adds
% them to a new variable "Histo_inds"
for v = 1:length(Fn)
    for h = 1:length(Epochs)
        if ~isempty(Epochs(h).(Fn{v})) == 1
            if (min(Epochs(h).(Fn{v})) + Offset) <= max(Time_inds)
                Anchor = min(Epochs(h).(Fn{v})) + ((max(Epochs(h).(Fn{v})) - (round(max(Epochs(h).(Fn{v}))) * Intercept)));
                Start_row = Anchor + Onset;
                if (min(Epochs(h).(Fn{v})) + Offset) > max(Time_inds)
                    End_row = max(Time_inds);
                else
                    End_row = Anchor + Offset;
                end
                Histo_inds(h).(Fn{v}) = Time_inds(Start_row:End_row,1);
            elseif ~isempty(Epochs(h).(Fn{v})) == 0
                h = h+1;
            end
        end
    end
end

%Uses the indices collected within the Histo_inds variable to create PETHs
for p = 1:length(Fn)
    for y = 1:length(Histo_inds)
        if ~isempty(Histo_inds(y).(Fn{p})) == 1
            Inds = Histo_inds(y).(Fn{p});
            PETH.DFF(y).(Fn{p}) = Processed.Signal.DFF(Inds,1);
            PETH.ZDFF(y).(Fn{p}) = Processed.Signal.ZDFF(Inds,1);
        elseif ~isempty(Histo_inds(y).(Fn{p})) == 0
            y = y+1;
        end
    end
end

%Mean PETH
for b = 1:length(Fn)
    PETH.Means.DFF.(Fn{b}) = mean(horzcat(PETH.DFF.(Fn{b})),2);
    PETH.Means.ZDFF.(Fn{b}) = mean(horzcat(PETH.ZDFF.(Fn{b})),2);
end

Processed.PETH = PETH;
end