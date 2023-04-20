function [Binned_inds,PETH] = peth_binned(Epochs,Onset_lag,Offset_lag,Sampling_freq,Time,Lookup,Processed,Time_ind_binned)
%peth takes the indices of each behaviour epoch, applies user settings, and
%creates the indices for peri-event time histograms
%   Detailed explanation goes here

Onset = round(Onset_lag*Sampling_freq);
Offset = round(Offset_lag*Sampling_freq);
Time_inds = find(Time);
Cutoff = min(Time_ind_binned(:,4));
Fn = fieldnames(Epochs);
for v = 1:length(Fn)
    for h = 1:length(Epochs)
        if ~isempty(Epochs(h).(Fn{v})) == 1
            if min(Epochs(h).(Fn{v})) >= Cutoff && (min(Epochs(h).(Fn{v})) + Offset) <= max(Time_inds)
                Start_row = min(Epochs(h).(Fn{v})) + Onset;
                End_row = min(Epochs(h).(Fn{v})) + Offset; %Need to deal with if the PETH window is longer than the end of the trace
                Binned_inds(h).(Fn{v}) = Time_inds(Start_row:End_row,1);
            elseif ~isempty(Epochs(h).(Fn{v})) == 0
                h = h+1;
            %elseif (min(Epochs(h).(Fn{v})) + Offset) > max(Time_inds)
                %Start_row = min(Epochs(h).(Fn{v})) + Onset;
                %End_row = max(Time_inds);
                %Histo_inds(h).(Fn{v}) = Time_inds(Start_row:End_row,1);
            end
        end
    end
end

Fn2 = fieldnames(Binned_inds);
for p = 1:length(Fn2)
    for y = 1:length(Binned_inds)
        if ~isempty(Binned_inds(y).(Fn2{p})) == 1
            Inds = Binned_inds(y).(Fn2{p});
            PETH.Binned.DFF(y).(Fn2{p}) = Processed.Signal.DFF(Inds,1);
            PETH.Binned.ZDFF(y).(Fn2{p}) = Processed.Signal.ZDFF(Inds,1);
        elseif ~isempty(Binned_inds(y).(Fn2{p})) == 0
            y = y+1;
        end
    end
end

for b = 1:length(Fn2)
    PETH.Means.Binned.DFF.(Fn2{b}) = mean(horzcat(PETH.Binned.DFF.(Fn2{b})),2);
    PETH.Means.Binned.ZDFF.(Fn2{b}) = mean(horzcat(PETH.Binned.ZDFF.(Fn2{b})),2);
end

Processed.PETH = PETH;
end