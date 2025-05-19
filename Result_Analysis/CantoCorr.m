% Get unique participants
participants = unique(data.questionaire_uuid);

% Initialise results
fam_per_participant = NaN(numel(participants), 1);
acc_combined = NaN(numel(participants), 1);
acc_test1 = NaN(numel(participants), 1);
acc_test2 = NaN(numel(participants), 1);
responseScore_C2 = NaN(numel(participants), 1); % For plotting C2_1 response

for p = 1:numel(participants)
    thisP = participants{p};

    % Get Cantonese familiarity score
    row = strcmp(data.questionaire_uuid, thisP) & ...
          strcmp(data.wm_id, 'lang_fam') & ...
          strcmp(data.responses_stimulus, 'Lang_canto');
    if any(row)
        fam = data.responses_score(row);
        fam_per_participant(p) = fam(1);
    end

    % === Combined (AI only) ===
    isAI_Canto = (strcmp(data.wm_id, 'cantonese_test_1') | ...
                  strcmp(data.wm_id, 'cantonese_test_2')) & ...
                 endsWith(data.responses_stimulus, '_1') & ...
                 strcmp(data.CorrectAnswer, 'AI') & ...
                 strcmp(data.questionaire_uuid, thisP);
    if any(isAI_Canto)
        responses = data.responses_score(isAI_Canto);
        identifiedAsAI = responses <= 45;
        acc_combined(p) = sum(identifiedAsAI) / sum(isAI_Canto) * 100;
    end

    % === Test 1 (AI + Human, weighted) ===
    rows_t1_all = strcmp(data.wm_id, 'cantonese_test_1') & ...
                  endsWith(data.responses_stimulus, '_1') & ...
                  strcmp(data.CorrectAnswer, 'AI') & ...
                  strcmp(data.questionaire_uuid, thisP);
    valid_t1_all = rows_t1_all & ~isnan(data.Correct);
    if any(valid_t1_all)
        acc_test1(p) = mean(data.Correct(valid_t1_all)) * 100;
    end

    % === Test 2 (AI only) ===
    isTest2 = strcmp(data.wm_id, 'cantonese_test_2') & ...
              endsWith(data.responses_stimulus, '_1') & ...
              strcmp(data.CorrectAnswer, 'AI') & ...
              strcmp(data.questionaire_uuid, thisP);
    if any(isTest2)
        r2 = data.responses_score(isTest2);
        acc_test2(p) = sum(r2 <= 45) / sum(isTest2) * 100;
    end

    % === C2_1 Response Score (Human stimulus) ===
    row_c2 = strcmp(data.questionaire_uuid, thisP) & ...
             strcmp(data.wm_id, 'cantonese_test_1') & ...
             strcmp(data.responses_stimulus, 'C2_1');
    if any(row_c2)
        responseScore_C2(p) = data.responses_score(find(row_c2, 1));
    end
end

%% Filter valid participants
valid_comb = ~isnan(fam_per_participant) & ~isnan(acc_combined);
valid_1 = ~isnan(fam_per_participant) & ~isnan(acc_test1);
valid_2 = ~isnan(fam_per_participant) & ~isnan(acc_test2);
valid_c2 = ~isnan(fam_per_participant) & ~isnan(responseScore_C2);

%% Correlations
[r_comb, p_comb] = corr(fam_per_participant(valid_comb), acc_combined(valid_comb), 'rows','complete');
fprintf('\nCombined Cantonese AI Correlation: r = %.2f, p = %.3f\n', r_comb, p_comb);

[r_t1, p_t1] = corr(fam_per_participant(valid_1), acc_test1(valid_1), 'rows','complete');
fprintf('Test 1 Correlation: r = %.2f, p = %.3f\n', r_t1, p_t1);

[r_t2, p_t2] = corr(fam_per_participant(valid_2), acc_test2(valid_2), 'rows','complete');
fprintf('Test 2 Correlation: r = %.2f, p = %.3f\n', r_t2, p_t2);

%% Plot accuracy vs familiarity (3 main plots)
titles = {'All', 'Test 1', 'Test 2'};
acc_sets = {acc_combined, acc_test1, acc_test2};
valid_sets = {valid_comb, valid_1, valid_2};

for i = 1:3
    figure(i); clf;
    valid = valid_sets{i};
    x = fam_per_participant(valid);
    y = acc_sets{i}(valid);

    coeffs = polyfit(x, y, 1);
    xFit = linspace(min(x), max(x), 100);
    yFit = polyval(coeffs, xFit);

    plot(xFit, yFit, 'LineWidth', 2); hold on;
    scatter(x, y, 30, 'filled');
    ylim([0 100]);
    xlabel('Language Familiarity (Cantonese)');
    ylabel('Identification Accuracy (%)');
    title(sprintf('Correlation Between Familiarity and Identification Accuracy — %s', titles{i}));

    grid on;
end

%% Plot for C2_1 response score vs familiarity
figure(4); clf;
x = fam_per_participant(valid_c2);
y = responseScore_C2(valid_c2);

if numel(x) >= 2
    coeffs = polyfit(x, y, 1);
    xFit = linspace(min(x), max(x), 100);
    yFit = polyval(coeffs, xFit);
    plot(xFit, yFit, 'LineWidth', 2); hold on;
end

scatter(x, y, 30, 'filled');
ylim([0 100]);
xlabel('Language Familiarity (Cantonese)');
ylabel('Response Score to C2\_1 (Human Stimulus)');
title('Correlation Between Familiarity and Identification Accuracy — C2\_1 (Cantonese Test 1)');
yline(50, '--', 'Unsure Threshold');
grid on;

%% Weighted Accuracy calculations
wacc_combined = NaN(numel(participants),1);
wacc_test1 = NaN(numel(participants),1);
wacc_test2 = NaN(numel(participants),1);

for p = 1:numel(participants)
    thisP = participants{p};

    rows_comb = strcmp(data.wm_id, 'cantonese_test_1') | ...
                endsWith(data.responses_stimulus, '_1') & ...
                strcmp(data.CorrectAnswer, 'AI') & ...
                strcmp(data.questionaire_uuid, thisP);
    valid_comb = rows_comb & ~isnan(data.Correct);
    if any(valid_comb)
        wacc_combined(p) = mean(data.Correct(valid_comb)) * 100;
    end

    rows_t1 = strcmp(data.wm_id, 'cantonese_test_1') & ...
              endsWith(data.responses_stimulus, '_1') & ...
              strcmp(data.questionaire_uuid, thisP);
    valid_t1 = rows_t1 & ~isnan(data.Correct);
    if any(valid_t1)
        wacc_test1(p) = mean(data.Correct(valid_t1)) * 100;
    end

    rows_t2 = strcmp(data.wm_id, 'cantonese_test_2') & ...
              endsWith(data.responses_stimulus, '_1') & ...
              strcmp(data.questionaire_uuid, thisP);
    valid_t2 = rows_t2 & ~isnan(data.Correct);
    if any(valid_t2)
        wacc_test2(p) = mean(data.Correct(valid_t2)) * 100;
    end
end

%% Print weighted results
overall_wacc_combined = mean(wacc_combined, 'omitnan');
overall_wacc_test1 = mean(wacc_test1, 'omitnan');
overall_wacc_test2 = mean(wacc_test2, 'omitnan');

fprintf('\n**Overall Weighted Identification Accuracy**\n');
fprintf('Combined (Test 1 + 2): %.2f%%\n', overall_wacc_combined);
fprintf('Test 1:                %.2f%%\n', overall_wacc_test1);
fprintf('Test 2:                %.2f%%\n', overall_wacc_test2);
