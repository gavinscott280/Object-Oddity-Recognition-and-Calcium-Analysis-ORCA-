function [DFF,DFF_test,AUC,AUC_test,ZAUC_test,ZDFF,ZDFF_test,ZDFF_norm2baseline,ControlDFF,Baseline,Zbaseline,Baseline_auc,Processed] = dFF(Time,Signal,Control,Iso_fit,Fit1,Filename,Filepath)
%DFF calculates dF/F of photometry signal, plots the results, and
%calculates z-scores and area under the curve
%   
DFF = ((Signal - Iso_fit) ./ Iso_fit).*100; %dF/F of whole session
temp_x = 1:numel(Time); temp_x = temp_x';
ControlDFF = ((Control - Fit1(temp_x)) ./ Fit1(temp_x)).*100; %dF/F of control channel (used to check signal quality)
ZDFF = zscore(DFF); %z-scored dF/F of signal over whole session
AUC = trapz(DFF >= 0); %area under the curve of whole session
ZAUC = trapz(ZDFF >= 0);


%Plot the results
figure
tiledlayout(2,1)
ax1 = nexttile;
plot(Time,DFF)
hold on
title('dF/F')
xlabel('Time (s)')
ylabel('dF/F')
ax2 = nexttile;
plot(Time,ZDFF)
title('z-scored dF/F')
xlabel('Time (s)')
ylabel('dF/F z-score')

Figurename = [Filename, '_trace', '.fig'];
cd(Filepath);
saveas(gcf, Figurename);

% Check signal quality
figure
tiledlayout(2,1)

ax1 = nexttile;
plot(Time,DFF)
title('dF/F')
ylabel('dF/F')
xlabel('Time')

ax2 = nexttile;
plot(Time,ControlDFF)
title('Isosbestic data')
ylabel('dF/F')
xlabel('Time')

linkaxes([ax1 ax2],'xy')

Figurename = [Filename, '_quality', '.fig'];
cd(Filepath);
saveas(gcf, Figurename);

%Separate the session into baseline and test
[row] = find((Time) == 0);

DFF_test = DFF(row:end);
ZDFF_test = ZDFF(row:end);
AUC_test = trapz(DFF_test(DFF_test >= 0));
ZAUC_test = trapz(ZDFF_test(ZDFF_test >= 0));

Baseline = DFF(1:(row -1));
Zbaseline = ZDFF(1:(row - 1));
Baseline_auc = trapz(Baseline);
%Zbaseline_auc = trapz(ZBaseline(Zbaseline >= 0));

% Calculates a z-scored dF/F for the test using the baseline for
% normalization
ZDFF_norm2baseline = (DFF_test - mean(Baseline))./std(Baseline);

Processed.Signal.DFF = DFF;
Processed.Signal.DFF_test = DFF_test;
Processed.Signal.ZDFF = ZDFF;
Processed.Signal.ZDFF_test = ZDFF_test;
Processed.Signal.DFF_baselinezscore = ZDFF_norm2baseline;
Processed.Signal.ControlDFF = ControlDFF;
Processed.Signal.Baseline = Baseline;
Processed.Signal.ZBaseline = Zbaseline;
Processed.Means.meanDFF = mean(DFF);
Processed.Means.meanDFF_test = mean(DFF_test);
Processed.Means.meanZDFF = mean(ZDFF);
Processed.Means.meanZDFF_test = mean(ZDFF_test);
Processed.Means.meanDFF_baselinezscore = mean(ZDFF_norm2baseline);
Processed.Means.AUC = AUC;
Processed.Means.AUC_test = AUC_test;
Processed.Means.ZAUC = ZAUC;
Processed.Means.ZAUC_test = ZAUC_test;
Processed.Means.AUC_baseline = Baseline_auc;



end

