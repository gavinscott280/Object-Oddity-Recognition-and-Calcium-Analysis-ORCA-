function [Iso_fit,Fit1,Fit2] = iso_fit(Signal,Control,Time,Filename,Filepath)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
figure

tiledlayout(2,1) %use tiled layouts to link x-axes across graphs
ax1 = nexttile;

plot(Control)
temp_x = 1:length(Time); %note -- using a temporary x variable due to computational constraints in matlab
temp_x = temp_x'; %transpose
Fit1 = fit(temp_x,Control,'exp2'); %fit isosbestic data with a biexponential decay
hold on
plot(Fit1(temp_x),'LineWidth',5) %plot for visualization

title('isosbestic data fit with biexponential')
xlabel('frame number')
ylabel('F (mean pixel value')

%linearly scale fit to 470 data using robustfit
Fit2 = robustfit(Fit1(temp_x),Signal); %scale biexponential decay to the raw 470 data using robust fit
Iso_fit = Fit1(temp_x)*Fit2(2)+Fit2(1); %save scaled biexponential fit into structure

ax2 = nexttile;

plot(Signal) %plot raw 465 data
hold on
plot(Iso_fit,'LineWidth',5) %plot scaled fit

title('linearly scaled biexponential fit over signal channel data')
xlabel('frame number')
ylabel('F (mean pixel value')

linkaxes([ax1 ax2],'x')

Figurename = [Filename, '_fit', '.fig'];
cd(Filepath);
saveas(gcf, Figurename);
end

