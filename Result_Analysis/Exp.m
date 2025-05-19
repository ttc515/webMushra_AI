% Get list of unique participants
participants = unique(data.questionaire_uuid);

% Initialise
acc_exp = [];
acc_noexp = [];
all_acc = [];
all_exp = [];

acc_per_participant = NaN(numel(participants), 1); % For plotting
exp_status = NaN(numel(participants), 1);          % Store extracted experience values

for i = 1:numel(participants)
    pid = participants{i};
    
    % Extract rows for this participant
    isThisP = strcmp(data.questionaire_uuid, pid);
    
    % Get experience value (assume all rows for a participant have the same value)
    expVal = unique(data.AIMusicExperience(isThisP));
    expVal = expVal(~isnan(expVal)); % Remove NaNs if any

    if isempty(expVal)
        continue; % Skip participant with no valid AIMusicExperience
    end
    
    exp_status(i) = expVal;

    % Identify _1 stimuli (AI identification)
    idx = isThisP & endsWith(data.responses_stimulus, '_1');
    correctResp = data.Correct(idx);

    if any(~isnan(correctResp))
        acc = 100 * sum(correctResp == 1) / sum(~isnan(correctResp));
        acc_per_participant(i) = acc;

        if expVal == 1
            acc_exp(end+1) = acc;
        elseif expVal == 0
            acc_noexp(end+1) = acc;
        end

        all_acc(end+1) = acc;
        all_exp(end+1) = expVal;
    end
end

% Display group means
fprintf('--- Identification Accuracy ---\n');
fprintf('With AI Music Experience: %.2f%%\n', mean(acc_exp, 'omitnan'));
fprintf('Without AI Music Experience: %.2f%%\n', mean(acc_noexp, 'omitnan'));

% t-test
[~, p_ttest] = ttest2(acc_exp, acc_noexp);
fprintf('t-test p-value: %.4f\n', p_ttest);

% Correlation
if numel(all_acc) > 1 && numel(unique(all_exp)) > 1
    [r_corr, p_corr] = corr(all_exp', all_acc', 'rows','complete');
    fprintf('Correlation (r) between AI music experience and accuracy: %.2f, p = %.4f\n', r_corr, p_corr);
else
    fprintf('Not enough data to compute correlation.\n');
end

% Plotting
validIdx = ~isnan(exp_status) & ~isnan(acc_per_participant);
experienceValid = exp_status(validIdx);
accuracyValid = acc_per_participant(validIdx);

figure;
gscatter(experienceValid, accuracyValid, experienceValid, 'br', 'ox', 8);
xticks([0 1]);
xticklabels({'No AI Music Experience', 'With AI Music Experience'});
xlabel('AI Music Experience');
ylabel('Identification Accuracy (%)');
title('Identification Accuracy vs. AI Music Experience');
grid on;
hold on;

% Add mean lines
yline(mean(accuracyValid(experienceValid == 1)), '--r', 'Mean (Experienced)', 'LabelHorizontalAlignment', 'left');
yline(mean(accuracyValid(experienceValid == 0)), '--b', 'Mean (Not Experienced)', 'LabelHorizontalAlignment', 'left');
legend({'No Experience','Experienced','Mean (Not Experienced)', 'Mean (Experienced)'}, 'Location', 'best');

% Display participant count
fprintf('Number of participants with valid experience data: %d\n', numel(accuracyValid));

% Assuming all_exp and all_acc contain only non-NaN matched data
% If not already cleaned, add:
valid_corr_idx = ~isnan(all_exp) & ~isnan(all_acc);
x = all_exp(valid_corr_idx); % AI music experience (0 or 1)
y = all_acc(valid_corr_idx); % Identification accuracy (%)

% Plot
figure;
scatter(x, y, 80, 'filled');
xlabel('AI Music Experience (0 = No, 1 = Yes)');
ylabel('Identification Accuracy (%)');
title('Correlation Between AI Music Experience and Identification Accuracy');
grid on;
hold on;

% Add regression line
p = polyfit(x, y, 1); % Linear fit
x_fit = linspace(min(x), max(x), 100);
y_fit = polyval(p, x_fit);
plot(x_fit, y_fit, '--k', 'LineWidth', 1.5);

% Annotate correlation value
[r_corr, p_corr] = corr(x', y');
text(0.05, max(y)*0.95, sprintf('r = %.2f, p = %.4f', r_corr, p_corr), ...
     'FontSize', 12, 'BackgroundColor', 'w');

legend('Participant', 'Linear Fit', 'Location', 'best');
