function [Sig_trimmed,Ctrl_trimmed,Time_trimmed,Num_trimmed_frames] = trim_plot(Signal,Control,Time)
%UNTITLED3 Summary of this function goes here
Signal = Signal';
Control = Control';
    
figure
tiledlayout(2,1)
    
ax1 = nexttile;
plot(Time,Signal)
hold on
    
ax2 = nexttile;
plot(Time,Control)
hold on
    
linkaxes([ax1 ax2],'x')
[x,y] = ginput;
temp = abs(Time - x);
[row] = find(ismember(Time,(max(Time(find(temp == min(abs(x - Time))))))));
    
Sig_trimmed = Signal(row:end);
Ctrl_trimmed = Control(row:end);
Time_trimmed = Time(row:end,1);
Num_trimmed_frames = row-1;
Signal = Sig_trimmed';
Control = Ctrl_trimmed';
Time = Time_trimmed';
end

