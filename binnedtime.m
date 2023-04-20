function [DFF_binned,ZDFF_binned,ZDFF_baselinezscore_binned,Time_binned] = binnedtime(Time,DFF,ZDFF,ZDFF_norm2baseline,Binlength,Sampling_freq)
%binnedtime divides the trace into bins of user-defined length

% NOTE: This function currently cannot handle cases in which the final time
% bin is shorter than the rest and will throw an array dimensions error.
% The function needs to be updated to handle these cases (Possibly by using
% a cell array instead of matrix).

% The number of frames in a bin is calculated from the bin length in
% seconds and the sampling frequency
Bin = floor(Sampling_freq * Binlength);

Num_bins = numel(Time)/Bin; % Number of bins across the entire trace

% Populates arrays with the binned data from the whole trace
for i = 1:round(Num_bins)
    if Bin*i <= numel(Time)
        DFF_binned(:,i) = DFF(((Bin*i - Bin)+1):(Bin*i),1);
        ZDFF_binned(:,i) = ZDFF(((Bin*i - Bin)+1):(Bin*i),1);
        Time_binned(:,i) = Time(((Bin*i - Bin)+1):(Bin*i),1);
    end
end

% Number of bins only during the test (for binning the z-score dF/F that is
% normalized to the baseline recording

[row] = find((Time) == 0);
Testtime = Time(row:end);
Num_bins_test = numel(Testtime)/Bin;

% Populates an array with the binned data from the test
for k = 1:(round(Num_bins_test))
    if Bin*k <= numel(ZDFF_norm2baseline)
        ZDFF_baselinezscore_binned(:,k) = ZDFF_norm2baseline(((Bin*k - Bin)+1):(Bin*k),1);
    end
end