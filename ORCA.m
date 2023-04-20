%% ORCA: Object/oddity Recognition and Calcium Analysis

%Gavin A. Scott (2023)

%A fiber photometry analysis pipeline specialized for handling TDT data
%tanks and object exploration data

% General instructions: This pipeline is designed to be run step-by-step.
% Highlight each section of the script and "run section"



clear
addpath(genpath('C:\Users\gavin\Documents\MATLAB\TDTSDK')); %Set this file path to the appropriate one on your computer
addpath(genpath('C:\Users\gavin\Documents\MATLAB\FP_Analysis_master')); %Same here
%% FP Analysis settings

%Preprocessing
Noise_remove = 'n'; %Select whether to apply low pass butterworth filter for denoising ('y' or 'n'). Applicable if Synapse settings don't already remove high frequency noise.
Cutoff = 100; %input high cutoff frequency for low pass butterworth filter. This value should be set as <= the Nyquist value (sampling rate/2).
Trim_start = 'n'; %Displays an interactive plot to trim the beginning of the trace where there is often a large start artifact
Starttime = NaN; %Manually set start frame. Set to NaN if not in use
Endtime = NaN; %Manually set end frame. Set to NaN if not in use
Binlength = 60; %Length in seconds of bins for binned analysis

%Peak Detection Settings
Use_zscore = 'y'; %select whether to use the z-scored trace or the raw trace
Pks_window_sz = 15; %size (s) of moving window for peak thresholding
Pks_exclusion = 2; %Events greater than n times value of MAD above median of moving window will be thresholded out
Transients = 3; %Transients defined as greater than n times value of MAD above moving median of thresholded trace

%Behavioural Analysis Settings
Behav_start_frame = 1300; %start frame used in MultiKeyVideoStopwatch(if behaviour video was analyzed starting from a different frame than the photometry trace)
    Behav_start_frame = Behav_start_frame + 1;
Min_epoch = 0; %Minimum duration (s) of an exploration bout
Max_epoch = 2000; %Maximum duration (s) of an exploration bout (if desired). Can be set to the length of the whole trial if no maximum needed.
Min_separation = 0.75; %Minimum time (s) between exploration bouts
Onset_lag = -1; %Start time axis of peri-event time histograms at -n(s) from event onset
Offset_lag = 1; %End time axis of peri-event time histograms at +n(s) from event onset
Intercept = 1; %Choose what point within each exploration bout to anchor the PETHs to (cont..) 
% (Normalized as proportion of elapsed time in exploration bout; 1 == start; 0.5 == middle; 0 = end)
Combine_vars = {'Var1','Var2'}; %Combine the indices of select behaviour variables (e.g. combined exploration of left and right objects)
%% Import TDT Data
% This section creates variables to import a raw photometry trace, set file
% names and directories, and define basic settings for the analysis

%Get data tank
Filepath = uigetdir; %User navigates to and selects folder containing photometry trace
[Filepath,Filename,Raw_data,Signal,Control,Time,Behav_start,Sampling_freq] = importTDT(Filepath); 
%% Denoise
if Noise_remove == 'y'
    Signal = denoise(Filename,Filepath,Signal,Time,Sampling_freq,Cutoff);
end
%% Trim timeseries
if Trim_start == 'n'
    [Signal,Control,Time] = hardcode_trim(Starttime,Endtime,Signal,Control,Time);
elseif Trim_start == 'y'
    [Signal, Control, Time, Num_frames_trimmed] = trim_plot(Signal,Control,Time);
end
%% Isosbestic Channel Correction
[Iso_fit,Fit1,Fit2] = iso_fit(Signal,Control,Time,Filename,Filepath);
%% Import discrete behaviour timeseries and align with Ca2+ trace
Behav_disc_file = uigetfile;
Behav_disc_file = strcat(Filepath,'/',Behav_disc_file);
Behav_disc = readtable(Behav_disc_file); Behav_disc = table2array(Behav_disc);
[Lookup, Aligned_behav,Behav_time,Behav_FPS] = align_timeseries(Behav_disc,Behav_start_frame,Behav_start,Time,Raw_data);
[Epochs, Concat_epochs] = epochs(Aligned_behav, Min_epoch, Max_epoch, Min_separation, Sampling_freq,Time,Lookup);
%% dF/F, area under the curve
[DFF,DFF_test,AUC,AUC_test,ZAUC_test,ZDFF,ZDFF_test,ZDFF_norm2baseline,ControlDFF,Baseline,Zbaseline,Baseline_auc,Processed] = dFF(Time,Signal,Control,Iso_fit,Fit1,Filename,Filepath);
%% Peak Detection
[Peaks_raw,Peaks_processed] = FPpeaks(DFF,ZDFF,Time,Use_zscore,Pks_window_sz,Pks_exclusion,Transients,Sampling_freq,Filename,Filepath);
%% Analyze signal by behaviour variables
[Histo_inds,PETH,Processed] = peth(Epochs,Onset_lag,Offset_lag,Sampling_freq,Time,Processed,Intercept);
[Processed] = behav_states(Processed,Concat_epochs);
%% Time Binning
[DFF_binned,ZDFF_binned,ZDFF_baselinezscore_binned,Time_binned] = binnedtime(Time,DFF,ZDFF,ZDFF_norm2baseline,Binlength,Sampling_freq);
[Binned_peaks,Binned_processed_pks,Time_ind_binned] = binnedpeaks(Time,Peaks_raw,Peaks_processed,Binlength,Sampling_freq);
%% Custom

%% Save Variables
save(Filename);






