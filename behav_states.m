function [Processed] = behav_states(Processed,Concat_epochs)
%Divides and concatenates all frames for each behaviour variable
%   Detailed explanation goes here
Fn = fieldnames(Concat_epochs);
for r = 1:length(Fn)
    Temp_dff = Processed.Signal.DFF((Concat_epochs.(Fn{r})),1);
    Temp_zdff = Processed.Signal.ZDFF((Concat_epochs.(Fn{r})),1);
    Processed.Behav.DFF.(Fn{r}) = Temp_dff;
    Processed.Behav.ZDFF.(Fn{r}) = Temp_zdff;
end

