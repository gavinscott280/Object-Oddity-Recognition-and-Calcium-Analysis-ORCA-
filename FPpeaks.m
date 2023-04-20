function [Peaks_raw,Peaks_processed] = FPpeaks(DFF,ZDFF,Time,Use_zscore,Pks_window_sz,Pks_exclusion,Transients,Sampling_freq,Filename,Filepath)
%Detects peaks in the trace
%   Simple peak detection with no thresholding
if Use_zscore == 'y'
    Trace = ZDFF;
else
    Trace = DFF;
end

[pks,locs,w,p] = findpeaks(Trace);
Peaks_raw = horzcat(pks,locs,w,p);

clearvars pks locs w p

%Size of moving window based on sampling frequency and user settings
Moving_window = Sampling_freq*Pks_window_sz;

% Calculate moving median and median average deviation (MAD) and restrict
% MAD to positive deflections above moving median

Mad = movmad(Trace,Moving_window,1);
Movmed = movmedian(Trace,Moving_window,1);
Positive_mad = [];
for i = 1:length(Mad)
    if Trace(i,1) > Movmed(i,1)
        Positive_mad(i,1) = Mad(i,1);
    else
        Positive_mad(i,1) = NaN;
    end
end

%calculate amplitudes of unprocessed peaks
Pk_medians = Movmed(Peaks_raw(:,2),1);
Amplitudes = Peaks_raw(:,1) - Pk_medians;
Peaks_raw(:,5) = Amplitudes;

%Delete outliers (as per user-defined parameters)
Trace_smoothed = [];
for i = 1:length(Trace)
    if Trace(i,1) > ((Pks_exclusion*Positive_mad(i,1)) + Movmed(i,1))
        Trace_smoothed(i,1) = NaN;
    else
        Trace_smoothed(i,1) = Trace(i,1);
    end
end

% Interpolate between deleted high amplitude regions to produce a smoothed
% trace. Currently performs interpolation via the modified akima piecewise
% cubic hermite method, but this can be optionally changed to various other
% fill methods
Trace_smoothed = fillmissing(Trace_smoothed,'makima');

%New peak detection matrix from smoothed trace
[pks,locs,w,p] = findpeaks(Trace_smoothed); %pks = absolute peak heights; locs = row index of each detected peak; w = peak widths; p = peak prominences
Smoothpeaks = horzcat(pks,locs,w,p);

%Obtain moving median and MAD of smoothed trace
Mad_smoothed = movmad(Trace_smoothed,Moving_window);
Smoothpeak_mads = Mad_smoothed(locs,1);
Movmed_smoothed = movmedian(Trace_smoothed,Moving_window);
Smoothpeak_medians = Movmed_smoothed(locs,1);

%locate true peaks and collect into a new array
Peaks_processed = [];
for i = 1:length(Smoothpeaks(:,1))
       if Smoothpeaks(i,1) > ((Transients*Smoothpeak_mads(i,1))+Smoothpeak_medians(i,1))
           Peaks_processed(i,1:4) = Smoothpeaks(i,1:4);
       elseif Smoothpeaks(i,1) <= ((Transients*Smoothpeak_mads(i,1))+Smoothpeak_medians(i,1))
           Peaks_processed(i,1:4) = NaN;
       end
end

Peaks_processed = Peaks_processed(sum(isnan(Peaks_processed),2) == 0,:);
Processed_medians = Movmed_smoothed(Peaks_processed(:,2),1);
Amplitudes_processed = Peaks_processed(:,1) - Processed_medians;
Peaks_processed(:,5) = Amplitudes_processed;

if isempty(Peaks_processed) == 1
    disp('Peak detection error: no accepted peaks after thresholding')
end

%plot for visualization
figure
tiledlayout (2,1)
ax1 = nexttile;
plot(Time,Trace,'b',Time,Movmed,'c-',Time(Peaks_raw(:,2),1),Peaks_raw(:,1),'r*')
title('Before Processing')
ylabel('dF/F')
xlabel('time (s)')
legend('dF/F','Moving Median','Peaks')
hold on
ax2 = nexttile;
plot(Time,Trace_smoothed,'b',Time,Movmed_smoothed,'c-',Time(Peaks_processed(:,2),1),Peaks_processed(:,1),'go')
title('After Processing')
ylabel('dFF')
xlabel('time (s)')
legend('dF/F','Moving Median','Accepted Peaks')
Figurename = [Filename, '_peaks', '.fig'];
cd(Filepath);
saveas(gcf, Figurename);
hold off

linkaxes([ax1 ax2],'xy')

end

