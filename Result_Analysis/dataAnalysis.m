%read table and add col before analyse
clc
%% Compute if participant was correct
% Initialise
data.Correct = nan(height(data),1);

for i = 1:height(data)
    if endsWith(data.responses_stimulus{i}, '_1') && ~isempty(data.CorrectAnswer{i})
        score = data.responses_score(i);
        label = data.CorrectAnswer{i};

        if strcmp(label, 'AI') && score <= 45
            data.Correct(i) = 1; % Correct: identified AI confidently
        elseif strcmp(label, 'Human') && score >= 56
            data.Correct(i) = 1; % Correct: identified Human confidently
        elseif (score > 45 && score <= 55)
            data.Correct(i) = 0.5; % Uncertain: AI passed test
        else
            data.Correct(i) = 0; % Incorrect judgment
        end
    end
end


%% Calculate AI identification accuracy per participant (AI samples only)

% Get unique participants
participants = unique(data.questionaire_uuid);

% Preallocate
IDaccuracy = nan(length(participants), 1);
LangFam = nan(numel(participants),1);

for p = 1:length(participants)
    thisP = strcmp(data.questionaire_uuid, participants{p});

    % Filter for AI _1 samples only
    idxID = thisP & ...
            endsWith(data.responses_stimulus, '_1') & ...
            strcmp(data.wm_id, 'lang_fam') & ...
            strcmp(data.CorrectAnswer, 'AI');

    correctResp = data.Correct(idxID);
    if any(~isnan(correctResp))
        IDaccuracy(p) = 100 * sum(correctResp == 1) / sum(~isnan(correctResp));
    end
end

% Compute and print overall mean
mean_IDaccuracy = mean(IDaccuracy, 'omitnan');
fprintf('\nOverall Mean AI Identification Accuracy: %.2f%%\n', mean_IDaccuracy);






%% Standard deviations - to understand variability

% Language familiarity
std_fam = std(LangFam, 'omitnan');


%fprintf('\n--- Standard Deviations ---\n');
%fprintf('Language Familiarity std: %.2f\n', std_fam);


%% Perceived AI vs Sound Quality Rating



% Initialise arrays to store sound quality ratings
ThoughtAI_SQ = [];       % When participant thought it was AI
ThoughtHuman_SQ = [];    % When they thought it was Human
Unsure_SQ = [];          % When participant was unsure (Correct == 0.5)

for i = 1:height(data)
    % Only process sound quality ratings (_2 stimuli)
    if endsWith(data.responses_stimulus{i}, '_2')

        % Get participant and test ID
        participant = data.questionaire_uuid{i};
        testID = data.wm_id{i};
        stimID = data.responses_stimulus{i};

        % Find the corresponding _1 stimulus (identification)
        correspondingStim = erase(stimID, '_2');
        IDrow = strcmp(data.questionaire_uuid, participant) & ...
                strcmp(data.wm_id, testID) & ...
                strcmp(data.responses_stimulus, [correspondingStim, '_1']);

        if any(IDrow)
            correctValue = data.Correct(IDrow);

            if correctValue == 1
                label = data.CorrectAnswer(IDrow);
                if strcmp(label, 'AI')
                    ThoughtAI_SQ(end+1) = data.responses_score(i); %#ok<SAGROW>
                elseif strcmp(label, 'Human')
                    ThoughtHuman_SQ(end+1) = data.responses_score(i); %#ok<SAGROW>
                end
            elseif correctValue == 0.5
                Unsure_SQ(end+1) = data.responses_score(i); %#ok<SAGROW>
            end
        end
    end
end

% Categorise function
categorise = @(scores) [sum(scores <= 24), ...
                        sum(scores >= 25 & scores <= 49), ...
                        sum(scores >= 50 & scores <= 74), ...
                        sum(scores >= 75)];

% Apply to each group
counts_AI    = categorise(ThoughtAI_SQ);
counts_Human = categorise(ThoughtHuman_SQ);
counts_Unsure = categorise(Unsure_SQ);

% Display counts
fprintf('\nWhen participants thought it was AI:\n');
fprintf('Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_AI);

fprintf('\nWhen participants thought it was Human:\n');
fprintf('Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_Human);

fprintf('\nWhen participants were unsure:\n');
fprintf('Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_Unsure);

% Build contingency table
observed = [counts_AI; counts_Human; counts_Unsure];

% Chi-square analysis
row_totals = sum(observed, 2);
col_totals = sum(observed, 1);
total = sum(observed(:));
expected = (row_totals * col_totals) / total;

chi2 = sum(((observed - expected).^2) ./ expected, 'all');
df = (size(observed,1)-1) * (size(observed,2)-1);
p = 1 - chi2cdf(chi2, df);

fprintf('\nChi-square statistic: %.3f\n', chi2);
fprintf('Degrees of freedom: %d\n', df);
fprintf('Chi-square test p-value: %.3e\n', p);




%% Real answer vs Sound Quality Rating — Test 1 and Test 2

% Define Test 1 and Test 2 test IDs
Test1_IDs = {'english_test_1','japanese_test_1','mandarin_test_1','cantonese_test_1'};
Test2_IDs = {'english_test_2','japanese_test_2','mandarin_test_2','cantonese_test_2'};

% Initialize arrays
ActualAI_SQ_T1 = [];
ActualHuman_SQ_T1 = [];
ActualAI_SQ_T2 = [];
ActualHuman_SQ_T2 = [];

for i = 1:height(data)

    % Only _2 stimuli (Sound Quality)
    if endsWith(data.responses_stimulus{i}, '_2')

        participant = data.questionaire_uuid{i};
        testID = data.wm_id{i};
        stimID = data.responses_stimulus{i};

        correspondingStim = erase(stimID, '_2');
        IDrow = strcmp(data.questionaire_uuid, participant) & ...
                strcmp(data.wm_id, testID) & ...
                strcmp(data.responses_stimulus, [correspondingStim, '_1']);

        if any(IDrow)
            correct = data.CorrectAnswer{IDrow};

            % Test 1
            if ismember(testID, Test1_IDs)
                if strcmp(correct,'AI')
                    ActualAI_SQ_T1(end+1) = data.responses_score(i);
                elseif strcmp(correct,'Human')
                    ActualHuman_SQ_T1(end+1) = data.responses_score(i);
                end
            end

            % Test 2
            if ismember(testID, Test2_IDs)
                if strcmp(correct,'AI')
                    ActualAI_SQ_T2(end+1) = data.responses_score(i);
                elseif strcmp(correct,'Human')
                    ActualHuman_SQ_T2(end+1) = data.responses_score(i);
                end
            end
        end
    end
end


%% Test 1 counts
counts_AI_T1 = categorize(ActualAI_SQ_T1);
counts_Human_T1 = categorize(ActualHuman_SQ_T1);

% Test 2 counts
counts_AI_T2 = categorize(ActualAI_SQ_T2);
counts_Human_T2 = categorize(ActualHuman_SQ_T2);

%% Display results

fprintf('\n--- Test 1 (Same song) ---\n');
fprintf('Actual AI samples: Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_AI_T1);
fprintf('Actual Human samples: Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_Human_T1);

fprintf('\n--- Test 2 (Different songs) ---\n');
fprintf('Actual AI samples: Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_AI_T2);
fprintf('Actual Human samples: Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_Human_T2);

%% Real answer vs Sound Quality Rating — AI vs Reference

% Initialize arrays
AI_SQ_T1 = [];
Ref_SQ_T1 = [];
AI_SQ_T2 = [];
Ref_SQ_T2 = [];

for i = 1:height(data)

    % Only _2 stimuli
    if endsWith(data.responses_stimulus{i}, '_2')

        participant = data.questionaire_uuid{i};
        testID = data.wm_id{i};
        stimID = data.responses_stimulus{i};

        correspondingStim = erase(stimID, '_2');

        % Is this a reference?
        if contains(correspondingStim, 'reference')

            % Test 1 or Test 2
            if ismember(testID, Test1_IDs)
                Ref_SQ_T1(end+1) = data.responses_score(i);
            elseif ismember(testID, Test2_IDs)
                Ref_SQ_T2(end+1) = data.responses_score(i);
            end

        else
            % Otherwise, check if it’s an AI clip based on the correct answer
            IDrow = strcmp(data.questionaire_uuid, participant) & ...
                    strcmp(data.wm_id, testID) & ...
                    strcmp(data.responses_stimulus, [correspondingStim, '_1']);

            if any(IDrow)
                correct = data.CorrectAnswer{IDrow};

                if strcmp(correct,'AI')
                    if ismember(testID, Test1_IDs)
                        AI_SQ_T1(end+1) = data.responses_score(i);
                    elseif ismember(testID, Test2_IDs)
                        AI_SQ_T2(end+1) = data.responses_score(i);
                    end
                end
            end
        end
    end
end

%% Categorize ratings


% Counts for Test 1
counts_AI_T1 = categorize(AI_SQ_T1);
counts_Ref_T1 = categorize(Ref_SQ_T1);

% Counts for Test 2
counts_AI_T2 = categorize(AI_SQ_T2);
counts_Ref_T2 = categorize(Ref_SQ_T2);

%% Display

fprintf('\n--- Test 1 ---AI vs Reference\n');
fprintf('AI samples: Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_AI_T1);
fprintf('Reference track: Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_Ref_T1);

fprintf('\n--- Test 2 ---AI vs Reference\n');
fprintf('AI samples: Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_AI_T2);
fprintf('Reference track: Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_Ref_T2);

%% Grouping participants based on Cantonese and Mandarin familiarity
% Does mandarin affect Canto ID acc?
% Thresholds for Mandarin
veryLowMandarin = 30;
lowMandarin = 50;
moderateMandarin = 80;
highCantonese = 90;

% Unique participants
participants = unique(data.questionaire_uuid);

% Preallocate accuracy arrays
G_verylow = [];
G_low = [];
G_moderate = [];
G_high = [];

for p = 1:length(participants)

    thisP = strcmp(data.questionaire_uuid, participants{p});

    % Get familiarity
    idxCanto = thisP & strcmp(data.responses_stimulus, 'Lang_canto');
    idxMand = thisP & strcmp(data.responses_stimulus, 'Lang_man');
    canto_fam = mean(data.responses_score(idxCanto));
    mand_fam = mean(data.responses_score(idxMand));

    if ~isnan(canto_fam) && ~isnan(mand_fam) && canto_fam > highCantonese

        % AI-only responses in Cantonese Test 2
        idxCantoT2 = thisP & ...
                     strcmp(data.wm_id, 'cantonese_test_2') & ...
                     endsWith(data.responses_stimulus, '_1') & ...
                     strcmp(data.CorrectAnswer, 'AI');
        correctResp = data.Correct(idxCantoT2);

        if any(~isnan(correctResp))
            IDaccuracy = 100 * sum(correctResp==1) / sum(~isnan(correctResp));

            % Group based on Mandarin familiarity
            if mand_fam <= veryLowMandarin
                G_verylow(end+1) = IDaccuracy;
            elseif mand_fam <= lowMandarin
                G_low(end+1) = IDaccuracy;
            elseif mand_fam <= moderateMandarin
                G_moderate(end+1) = IDaccuracy;
            else
                G_high(end+1) = IDaccuracy;
            end
        end
    end
end

% Compute group stats
means = [mean(G_verylow,'omitnan'), mean(G_low,'omitnan'), ...
         mean(G_moderate,'omitnan'), mean(G_high,'omitnan')];
errors = [std(G_verylow,'omitnan')/sqrt(sum(~isnan(G_verylow))), ...
          std(G_low,'omitnan')/sqrt(sum(~isnan(G_low))), ...
          std(G_moderate,'omitnan')/sqrt(sum(~isnan(G_moderate))), ...
          std(G_high,'omitnan')/sqrt(sum(~isnan(G_high)))];

% Labels
labels = {'Very Low', 'Low', 'Moderate', 'High'};

% Plot
figure;
bar(means, 'FaceColor', [0.3 0.6 0.8]); hold on;
errorbar(1:4, means, errors, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);
set(gca, 'XTickLabel', labels, 'XTick', 1:4);
ylabel('AI Identification Accuracy (%)');
ylim([0 100]);
xlabel('Mandarin Familiarity (Only Participants with High Cantonese)');
title('AI Identification Accuracy — Cantonese Test 2 (AI Samples Only)');
grid on;

% Thresholds
highCantonese = 90;
veryLowMandarin = 30;

% Get list of unique participants
participants = unique(data.questionaire_uuid);

% Initialise counter
count = 0;

for p = 1:length(participants)
    thisP = strcmp(data.questionaire_uuid, participants{p});

    % Extract their familiarity scores
    idxCanto = thisP & strcmp(data.responses_stimulus, 'Lang_canto');
    idxMand = thisP & strcmp(data.responses_stimulus, 'Lang_man');

    canto_fam = mean(data.responses_score(idxCanto));
    mand_fam = mean(data.responses_score(idxMand));

    % Check if they match the criteria
    if ~isnan(canto_fam) && ~isnan(mand_fam) && ...
       canto_fam > highCantonese && mand_fam <= veryLowMandarin
        count = count + 1;
    end
end

fprintf('Number of participants with High Cantonese and Very Low Mandarin: %d\n', count);


%% Dataset and participants count
% Find all rows where:
% - The stimulus is a _1 stimulus (AI identification)
% - The correct answer is 'AI'

isAI = endsWith(data.responses_stimulus, '_1') & strcmp(data.CorrectAnswer, 'AI');

% Total number of AI responses in the dataset
numAIresponses = sum(isAI);

fprintf('Total number of AI responses in the data: %d\n', numAIresponses);

isHuman = endsWith(data.responses_stimulus, '_1') & strcmp(data.CorrectAnswer, 'Human');

% Total number of AI responses in the dataset
numHumanresponses = sum(isHuman);

fprintf('Total number of Human responses in the data: %d\n', numHumanresponses);

% Optional: how many unique participants
participants = unique(data.questionaire_uuid);
fprintf('Number of participants: %d\n', numel(participants));

%% How samples perform


% Filter AI-labelled _1 stimuli
isAI = endsWith(data.responses_stimulus, '_1') & strcmp(data.CorrectAnswer, 'AI');

stimuli = data.responses_stimulus(isAI);
tests = data.wm_id(isAI);

uniquePairs = unique(table(stimuli, tests), 'rows');

% Initialise results table
results = table();
results.Stimulus = strings(height(uniquePairs),1);
results.Test = strings(height(uniquePairs),1);
results.Pass = zeros(height(uniquePairs),1);
results.Believable = zeros(height(uniquePairs),1);
results.Success = zeros(height(uniquePairs),1);
results.Total = zeros(height(uniquePairs),1);
results.WeightedScore = zeros(height(uniquePairs),1);

for s = 1:height(uniquePairs)
    stim = uniquePairs.stimuli{s};
    test = uniquePairs.tests{s};

    rows = strcmp(data.responses_stimulus, stim) & ...
           strcmp(data.wm_id, test) & ...
           strcmp(data.CorrectAnswer, 'AI');

    ratings = data.responses_score(rows);

    % Count categories
    nPass = sum(ratings >= 50 & ratings <= 60);
    nClose = sum(ratings > 60 & ratings <= 70);
    nSuccess = sum(ratings > 70);

    total = nPass + nClose + nSuccess;

    % Weighted deception score: Pass=1, Close=2, Success=3
    weighted = 1 * nPass + 2 * nClose + 3 * nSuccess;

    % Save to results
    results.Stimulus(s) = stim;
    results.Test(s) = test;
    results.Pass(s) = nPass;
    results.Believable(s) = nClose;
    results.Success(s) = nSuccess;
    results.Total(s) = total;
    results.WeightedScore(s) = weighted;
end

% Sort by deception score
results = sortrows(results, 'WeightedScore', 'descend');

% Display
disp(results);
