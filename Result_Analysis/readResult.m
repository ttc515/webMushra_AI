clear all
clc
opts = detectImportOptions('mushra_noloop_nowav_R.csv', 'Delimiter', ';');
data = readtable('mushra_noloop_nowav_R.csv', opts);
writetable(data, 'output.xlsx'); 
% %% Group by stimulus and compute mean + std deviation
% stimuli = unique(data.responses_stimulus);
% mean_scores = zeros(length(stimuli), 1);
% std_scores = zeros(length(stimuli), 1);
% 
% for i = 1:length(stimuli)
%     idx = strcmp(data.responses_stimulus, stimuli{i});
%     mean_scores(i) = mean(data.responses_score(idx));
%     std_scores(i) = std(data.responses_score(idx));
% end
% 
% % Display table
% resultTable = table(stimuli, mean_scores, std_scores)
% 
% %% Plot bar chart with error bars
% figure;
% bar(mean_scores);
% hold on;
% errorbar(1:length(mean_scores), mean_scores, std_scores, '.k');
% set(gca, 'XTickLabel', stimuli);
% xlabel('Stimulus');
% ylabel('Mean Score');
% title('Average Scores per Stimulus with Standard Deviation');
% hold off;
% 
% %% Optional: One-way ANOVA to test for rating differences between stimuli
% [p, tbl, stats] = anova1(data.responses_score, data.responses_stimulus);
% title('ANOVA: Do ratings differ significantly between stimuli?');
% 
% %% If desired, post-hoc comparisons
% multcompare(stats);
