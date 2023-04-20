figure
tiledlayout(2,1)
ax1 = nexttile;
plot(Time(305264:(end-20)),Aligned_behav(:,1))
area(Aligned_behav(:,1))
hold on
ax2 = nexttile;
plot(Time(305264:(end-20)),Aligned_behav(:,2))
area(Aligned_behav(:,2))
hold off

figure
tiledlayout(2,1)
ax1 = nexttile;
plot(Behav_disc(:,1))
area(Behav_disc(:,1))
hold on
ax2 = nexttile;
plot(Behav_disc(:,2))
area(Behav_disc(:,2))
hold off
%%
figure
plot(DFF(293935:end,:));
hold on
area(Aligned_behav(:,1),'FaceAlpha',0.7);
area(Aligned_behav(:,2),'FaceAlpha',0.7);
legend ('dF/F','Left Object','Right Object');
hold off