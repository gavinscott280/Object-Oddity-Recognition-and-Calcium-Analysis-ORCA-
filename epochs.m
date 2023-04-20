function [Epochs, Concat_epochs] = epochs(Aligned_behav, Min_epoch, Max_epoch, Min_separation,Sampling_freq,Time,Lookup)
%epochs Locates, separates, and serializes individual epochs of each
%behaviour variable using user-defined parameters for epoch length and
%separation.

%Convert user settings from s to frames
Max = round(Max_epoch * Sampling_freq);
Min = round(Min_epoch * Sampling_freq);
Separation = round(Min_separation * Sampling_freq);

Epochs = [];

for e = 1:size(Aligned_behav,2);
    Indices = find(Aligned_behav(:,e)); % Find the indices of the rows that equal 1
    %Step 1: Locate clusters of adjacent frames where behaviour == true;
    %Either separate or combine with nearby clusters based on minimum
    %separation setting.
    Clusters = {};
    Cur_cluster = 1;
    for i = 1:length(Indices)
        if i - 1 == 0
            Clusters{Cur_cluster}(1) = Indices(i);
        else
            if Indices(i) - Indices(i - 1) == 1
                Clusters{Cur_cluster}(end+1) = Indices(i);
            elseif Indices(i) - Indices(i-1) > 1 && Indices(i) - Indices(i-1) < Separation
                Clusters{Cur_cluster}(end+1) = Indices(i);
            elseif Indices(i) - Indices(i-1) >= Separation
                Cur_cluster = Cur_cluster+1;
                Clusters{Cur_cluster} = Indices(i);
            end
        end
    end
    %Step 2: Look for clusters that meet criteria set by min and max length
    %settings and place the indices of those clusters into structure containing behaviour
    %epochs.
    for o = 1:length(Clusters)
        if numel(Clusters{o}) >= Min && numel(Clusters{o}) <= Max
            Field = strcat('Var',(mat2str(e)));
            Epochs(o).(Field) = Clusters{o};
            Epochs(o).(Field) = Epochs(o).(Field)';
        elseif numel(Clusters{o}) < Min || numel(Clusters{o}) > Max
            o = o+1;
        end
    end
end
Pad_time = find(Time == min(Lookup(:,1)));
Fn = fieldnames(Epochs);
% Increase the row indices of the behaviour events by adding the number of
% frames from before behaviour started so that the row indices are aligned
% to the Ca2+ timestamps.
for p = 1:length(Epochs)
    for d = 1:length(Fn)
        if ~isempty(Epochs(p).(Fn{d})) == 1
            Epochs(p).(Fn{d}) = Epochs(p).(Fn{d}) + (Pad_time - 1);
        elseif ~isempty(Epochs(p).(Fn{d})) == 0
            Epochs(p).(Fn{d}) = Epochs(p).(Fn{d});
        end
    end
end

%Vertically concatenate the behavioural events so that indexing them in
%other functions is simpler.
for i = 1:length(Fn)
    Concat_epochs.(Fn{i}) = vertcat(Epochs.(Fn{i}));
end

end


