function [Signal] = denoise(Filename,Filepath,Signal,Time,Sampling_freq,Cutoff)
%denoise Applies a low-pass butterworth filter to remove high-frequency
%noise. Largely unnecessary because the signal is already low-passed by
%Synapse. But may be useful in some alternate application.

%Apply filter
Original = Signal;
[b,a] = butter(2,Cutoff/Sampling_freq);
Signal = filter(b,a,Original);

%Plot for visualization
figure
x = Time;
hold on
plot(x,Original,'r',x,Signal,'b')
title('Denoising Result')
hold off

%Save result
Figurename = [Filename, '_denoising', '.fig'];
cd(Filepath);
saveas(gcf, Figurename);
end

