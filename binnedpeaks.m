function [Binned_peaks,Binned_processed_pks,Time_ind_binned] = binnedpeaks(Time,Peaks_raw,Peaks_processed,Binlength,Sampling_freq)
% Separates peaks into time bins


Time_ind = find(Time);
Bin = round(Sampling_freq * Binlength);
Num_bins = numel(Time_ind)/Bin; % Number of bins across the entire trace
Binned_peaks = [];
Binned_processed_pks = [];

%Generate the indices for each bin
for i = 1:round(Num_bins)
    if Bin*i <= numel(Time)
        Time_ind_binned(:,i) = Time_ind(((Bin*i - Bin)+1):(Bin*i),1);
    end
end

% Place raw, unprocessed peaks into bins
for j = 1:round(Num_bins)
    if Bin*j <= numel(Time)
        Inds = find(Peaks_raw(:,2) <= max(Time_ind_binned(:,j)) & Peaks_raw(:,2) >= min(Time_ind_binned(:,j)));
        Binned_peaks(j).height(:,:) = Peaks_raw(Inds,1);
        Binned_peaks(j).locations(:,:) = Peaks_raw(Inds,2);
        Binned_peaks(j).widths(:,:) = Peaks_raw(Inds,3);
        Binned_peaks(j).prominences(:,:) = Peaks_raw(Inds,4);
        Binned_peaks(j).amplitudes(:,:) = Peaks_raw(Inds,5);
    end
end

clear Inds

% Repeat for processed peaks
for q = 1:round(Num_bins)
    if Bin*q <= numel(Time)
        Inds = find(Peaks_processed(:,2) <= max(Time_ind_binned(:,q)) & Peaks_processed(:,2) >= min(Time_ind_binned(:,q)));
        Binned_processed_pks(q).height(:,:) = Peaks_processed(Inds,1);
        Binned_processed_pks(q).locations(:,:) = Peaks_processed(Inds,2);
        Binned_processed_pks(q).widths(:,:) = Peaks_processed(Inds,3);
        Binned_processed_pks(q).prominences(:,:) = Peaks_processed(Inds,4);
        Binned_processed_pks(q).amplitudes(:,:) = Peaks_processed(Inds,5);
    end
end