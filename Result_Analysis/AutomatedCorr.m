participants = unique(data.questionaire_uuid);
numStimuli = height(correctTable);
results = [];

% Map TestID to familiarity label
famMap = containers.Map( ...
    {'english_test_1','english_test_2', ...
     'japanese_test_1','japanese_test_2', ...
     'mandarin_test_1','mandarin_test_2', ...
     'cantonese_test_1','cantonese_test_2'}, ...
    {'Lang_eng','Lang_eng', ...
     'Lang_jp','Lang_jp', ...
     'Lang_man','Lang_man', ...
     'Lang_canto','Lang_canto'} ...
);

for s = 1:numStimuli
    testID = correctTable.TestID{s};
    stim = correctTable.Stimulus{s};
    lang_fam_tag = famMap(testID);

    fam_vec = NaN(numel(participants), 1);
    response_vec = NaN(numel(participants), 1);

    for p = 1:numel(participants)
        thisP = participants{p};

        % Get that participant's lang familiarity
        row_fam = strcmp(data.questionaire_uuid, thisP) & ...
                  strcmp(data.wm_id, 'lang_fam') & ...
                  strcmp(data.responses_stimulus, lang_fam_tag);
        if any(row_fam)
            fam_vec(p) = data.responses_score(find(row_fam,1));
        end

        % Get their response to this stimulus
        row_resp = strcmp(data.questionaire_uuid, thisP) & ...
                   strcmp(data.wm_id, testID) & ...
                   strcmp(data.responses_stimulus, stim);
        if any(row_resp)
            response_vec(p) = data.responses_score(find(row_resp,1));
        end
    end

    % Compute correlation
    valid = ~isnan(fam_vec) & ~isnan(response_vec);
    if sum(valid) >= 3
        [r, pval] = corr(fam_vec(valid), response_vec(valid), 'rows','complete');
    else
        r = NaN;
        pval = NaN;
    end

    results = [results; {testID, stim, correctTable.CorrectAnswer{s}, lang_fam_tag, r, pval, sum(valid)}];
end

stimCorrTable = cell2table(results, ...
    'VariableNames', {'TestID', 'Stimulus', 'CorrectAnswer', 'LangTag', 'Correlation_r', 'pValue', 'N_Valid'});
stimCorrTable = sortrows(stimCorrTable, 'Correlation_r', 'descend');

disp(stimCorrTable);

% Parameters
testID = 'cantonese_test_2';
stim = 'C2_1';
lang_fam_tag = 'Lang_canto';

% Get unique participants
participants = unique(data.questionaire_uuid);

% Initialise vectors
fam_vec = NaN(numel(participants), 1);
response_vec = NaN(numel(participants), 1);

for p = 1:numel(participants)
    thisP = participants{p};

    % Get language familiarity score
    row_fam = strcmp(data.questionaire_uuid, thisP) & ...
              strcmp(data.wm_id, 'lang_fam') & ...
              strcmp(data.responses_stimulus, lang_fam_tag);
    if any(row_fam)
        fam_vec(p) = data.responses_score(find(row_fam, 1));
    end

    % Get response score to the stimulus
    row_resp = strcmp(data.questionaire_uuid, thisP) & ...
               strcmp(data.wm_id, testID) & ...
               strcmp(data.responses_stimulus, stim);
    if any(row_resp)
        response_vec(p) = data.responses_score(find(row_resp, 1));
    end
end

% Filter valid entries
valid = ~isnan(fam_vec) & ~isnan(response_vec);
x = fam_vec(valid);
y = response_vec(valid);

% Plot
figure; clf;
scatter(x, y, 30, 'filled'); hold on;

% Add regression line if enough data
if numel(x) >= 2
    coeffs = polyfit(x, y, 1);
    xFit = linspace(min(x), max(x), 100);
    yFit = polyval(coeffs, xFit);
    plot(xFit, yFit, 'LineWidth', 2);
end

% Styling
xlabel('Language Familiarity (Cantonese)');
ylabel('Response Score for C2\_1 (Human)');
title('Correlation Between Familiarity and Identification: test 2 C2');
yline(50, '--', 'Unsure threshold');
ylim([0 100]);
grid on;
