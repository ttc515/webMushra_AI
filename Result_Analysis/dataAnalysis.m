%read table and add col before analyse
clc
%% Compute if participant was correct
data.Correct = nan(height(data),1);

for i = 1:height(data)
    if endsWith(data.responses_stimulus{i}, '_1') && ~isempty(data.CorrectAnswer{i})
        if strcmp(data.CorrectAnswer{i},'AI') && data.responses_score(i)<50
            data.Correct(i) = 1;
        elseif strcmp(data.CorrectAnswer{i},'Human') && data.responses_score(i)>50
            data.Correct(i) = 1;
        else
            data.Correct(i) = 0;
        end
    end
end

%% Calculate accuracy, familiarity, and sound quality per participant

participants = unique(data.questionaire_uuid);

IDaccuracy = nan(length(participants),1);
LangFam = nan(length(participants),1);
SQscore = nan(length(participants),1);

for p = 1:length(participants)
    thisP = strcmp(data.questionaire_uuid, participants{p});

    % Identification accuracy
    idxID = thisP & endsWith(data.responses_stimulus, '_1');
    correctResp = data.Correct(idxID);
    if any(~isnan(correctResp))
        IDaccuracy(p) = 100 * sum(correctResp==1) / sum(~isnan(correctResp));
    end

    % Language familiarity (mean familiarity ratings)
    idxFam = thisP & strcmp(data.wm_type,'languageFamiliarity');
    LangFam(p) = mean(data.responses_score(idxFam));

    % Sound Quality ratings (average over _2 stimuli)
    idxSQ = thisP & endsWith(data.responses_stimulus, '_2');
    SQscore(p) = mean(data.responses_score(idxSQ));
end

%% Correlations

% Familiarity vs Identification Accuracy
[r1, p1] = corr(LangFam, IDaccuracy, 'rows','complete');
fprintf('Correlation between Language Familiarity and AI Identification Accuracy: r = %.2f, p = %.3f\n', r1, p1);

% Familiarity vs Sound Quality ratings
[r2, p2] = corr(LangFam, SQscore, 'rows','complete');
fprintf('Correlation between Language Familiarity and Sound Quality Rating: r = %.2f, p = %.3f\n', r2, p2);

% Identification Accuracy vs Sound Quality
[r3, p3] = corr(IDaccuracy, SQscore, 'rows','complete');
fprintf('Correlation between Identification Accuracy and Sound Quality Rating: r = %.2f, p = %.3f\n', r3, p3);

%% Visualisations

figure;
scatter(LangFam, IDaccuracy, 'filled');
xlabel('Language Familiarity');
ylabel('AI Identification Accuracy (%)');
title('Familiarity vs AI Identification Accuracy');
lsline;

figure;
scatter(LangFam, SQscore, 'filled');
xlabel('Language Familiarity');
ylabel('Sound Quality Rating');
title('Familiarity vs Sound Quality');
lsline;

figure;
scatter(IDaccuracy, SQscore, 'filled');
xlabel('AI Identification Accuracy (%)');
ylabel('Sound Quality Rating');
title('Identification Accuracy vs Sound Quality');
lsline;

%% Identify which tests are Test 1 and which are Test 2

% Define Test 1 and Test 2 test IDs
Test1_IDs = {'english_test_1','japanese_test_1','mandarin_test_1','cantonese_test_1'};
Test2_IDs = {'english_test_2','japanese_test_2','mandarin_test_2','cantonese_test_2'};

% Prepare arrays
IDaccuracy_T1 = nan(length(participants),1);
IDaccuracy_T2 = nan(length(participants),1);
SQscore_T1 = nan(length(participants),1);
SQscore_T2 = nan(length(participants),1);

for p = 1:length(participants)
    thisP = strcmp(data.questionaire_uuid, participants{p});

    % ---------- Identification accuracy ----------
    % Test 1
    idxID_T1 = thisP & endsWith(data.responses_stimulus, '_1') & ismember(data.wm_id, Test1_IDs);
    correct_T1 = data.Correct(idxID_T1);
    if any(~isnan(correct_T1))
        IDaccuracy_T1(p) = 100 * sum(correct_T1==1) / sum(~isnan(correct_T1));
    end

    % Test 2
    idxID_T2 = thisP & endsWith(data.responses_stimulus, '_1') & ismember(data.wm_id, Test2_IDs);
    correct_T2 = data.Correct(idxID_T2);
    if any(~isnan(correct_T2))
        IDaccuracy_T2(p) = 100 * sum(correct_T2==1) / sum(~isnan(correct_T2));
    end

    % ---------- Sound Quality ----------
    % Test 1
    idxSQ_T1 = thisP & endsWith(data.responses_stimulus, '_2') & ismember(data.wm_id, Test1_IDs);
    SQscore_T1(p) = mean(data.responses_score(idxSQ_T1));

    % Test 2
    idxSQ_T2 = thisP & endsWith(data.responses_stimulus, '_2') & ismember(data.wm_id, Test2_IDs);
    SQscore_T2(p) = mean(data.responses_score(idxSQ_T2));
end

%% Correlations - Test 1

[r1_T1, p1_T1] = corr(LangFam, IDaccuracy_T1, 'rows','complete');
[r2_T1, p2_T1] = corr(LangFam, SQscore_T1, 'rows','complete');

%% Correlations - Test 2

[r1_T2, p1_T2] = corr(LangFam, IDaccuracy_T2, 'rows','complete');
[r2_T2, p2_T2] = corr(LangFam, SQscore_T2, 'rows','complete');

%% Display results

fprintf('\n --- Test 1 ---\n');
fprintf('Familiarity vs AI ID accuracy: r = %.2f, p = %.3f\n', r1_T1, p1_T1);
fprintf('Familiarity vs Sound Quality: r = %.2f, p = %.3f\n', r2_T1, p2_T1);

fprintf('--- Test 2 ---\n');
fprintf('Familiarity vs AI ID accuracy: r = %.2f, p = %.3f\n', r1_T2, p1_T2);
fprintf('Familiarity vs Sound Quality: r = %.2f, p = %.3f\n', r2_T2, p2_T2);

%% Plotting

% Identification accuracy
figure;
scatter(LangFam, IDaccuracy_T1, 'filled');
xlabel('Language Familiarity');
ylabel('AI ID Accuracy (%) - Test 1');
title('Test 1: Familiarity vs AI Identification Accuracy');
lsline;

figure;
scatter(LangFam, IDaccuracy_T2, 'filled');
xlabel('Language Familiarity');
ylabel('AI ID Accuracy (%) - Test 2');
title('Test 2: Familiarity vs AI Identification Accuracy');
lsline;

% Sound quality
figure;
scatter(LangFam, SQscore_T1, 'filled');
xlabel('Language Familiarity');
ylabel('Sound Quality - Test 1');
title('Test 1: Familiarity vs Sound Quality');
lsline;

figure;
scatter(LangFam, SQscore_T2, 'filled');
xlabel('Language Familiarity');
ylabel('Sound Quality - Test 2');
title('Test 2: Familiarity vs Sound Quality');
lsline;

%% Standard deviations - to understand variability

% Language familiarity
std_fam = std(LangFam, 'omitnan');
% Identification accuracy
std_acc = std(IDaccuracy, 'omitnan');
% Sound quality
std_sq = std(SQscore, 'omitnan');

fprintf('\n--- Standard Deviations ---\n');
fprintf('Language Familiarity std: %.2f\n', std_fam);
fprintf('Identification Accuracy std: %.2f\n', std_acc);
fprintf('Sound Quality Rating std: %.2f\n', std_sq);

%% Perceived AI vs Sound Quality Rating

% Initialize arrays to store results
ThoughtAI_SQ = []; % Sound quality ratings when participant thought it was AI
ThoughtHuman_SQ = []; % When they thought it was Human

for i = 1:height(data)

    % Look only at _2 stimuli (Sound Quality ratings)
    if endsWith(data.responses_stimulus{i}, '_2')

        % Get participant and test ID
        participant = data.questionaire_uuid{i};
        testID = data.wm_id{i};
        stimID = data.responses_stimulus{i};

        % Find the corresponding _1 row (identification response)
        correspondingStim = erase(stimID, '_2');
        IDrow = strcmp(data.questionaire_uuid, participant) & ...
                strcmp(data.wm_id, testID) & ...
                strcmp(data.responses_stimulus, [correspondingStim, '_1']);

        if any(IDrow)
            IDscore = data.responses_score(IDrow); % The participant's AI/Human response

            % Classify: did they think it was AI?
            if IDscore < 50
                ThoughtAI_SQ(end+1) = data.responses_score(i); %#ok<SAGROW>
            else
                ThoughtHuman_SQ(end+1) = data.responses_score(i); %#ok<SAGROW>
            end

        end
    end
end

%% Categorize sound quality ratings into four groups

% 1 = Poor, 2 = Bad, 3 = Good, 4 = Excellent

% For when participants thought it was AI
cat_AI = ones(size(ThoughtAI_SQ)); % Default to Poor
cat_AI(ThoughtAI_SQ >= 25 & ThoughtAI_SQ <= 49) = 2; % Bad
cat_AI(ThoughtAI_SQ >= 50 & ThoughtAI_SQ <= 74) = 3; % Good
cat_AI(ThoughtAI_SQ >= 75) = 4; % Excellent

% For when participants thought it was Human
cat_Human = ones(size(ThoughtHuman_SQ)); % Default to Poor
cat_Human(ThoughtHuman_SQ >= 25 & ThoughtHuman_SQ <= 49) = 2; % Bad
cat_Human(ThoughtHuman_SQ >= 50 & ThoughtHuman_SQ <= 74) = 3; % Good
cat_Human(ThoughtHuman_SQ >= 75) = 4; % Excellent


%% Count number of ratings in each category

counts_AI = [sum(cat_AI == 1), sum(cat_AI == 2), sum(cat_AI == 3), sum(cat_AI == 4)];
counts_Human = [sum(cat_Human == 1), sum(cat_Human == 2), sum(cat_Human == 3), sum(cat_Human == 4)];

fprintf('\n When participants thought it was AI:\n');
fprintf('Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_AI);

fprintf('\nWhen participants thought it was Human:\n');
fprintf('Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_Human);

%% Build observed counts table

observed = [counts_AI; counts_Human];

%% Manually compute chi-square test (better for >2 categories)

% Row and column totals
row_totals = sum(observed, 2);
col_totals = sum(observed, 1);
total = sum(observed(:));

% Compute expected counts
expected = (row_totals * col_totals) / total;

% Compute chi-square statistic
chi2 = sum(((observed - expected).^2) ./ expected, 'all');

% Degrees of freedom
df = (size(observed,1)-1) * (size(observed,2)-1);

% Compute p-value
p = 1 - chi2cdf(chi2, df);

% Display results

fprintf('\n Chi-square statistic: %.3f\n', chi2);
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

%% Categorize ratings (Poor/Bad/Good/Excellent)

% Helper function
categorize = @(scores) [ sum(scores <= 24), ...
                         sum(scores >= 25 & scores <= 49), ...
                         sum(scores >= 50 & scores <= 74), ...
                         sum(scores >= 75) ];

% Test 1 counts
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

categorize = @(scores) [ sum(scores <= 24), ...
                         sum(scores >= 25 & scores <= 49), ...
                         sum(scores >= 50 & scores <= 74), ...
                         sum(scores >= 75) ];

% Counts for Test 1
counts_AI_T1 = categorize(AI_SQ_T1);
counts_Ref_T1 = categorize(Ref_SQ_T1);

% Counts for Test 2
counts_AI_T2 = categorize(AI_SQ_T2);
counts_Ref_T2 = categorize(Ref_SQ_T2);

%% Display

fprintf('\n--- Test 1 ---\n');
fprintf('AI samples: Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_AI_T1);
fprintf('Reference track: Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_Ref_T1);

fprintf('\n--- Test 2 ---\n');
fprintf('AI samples: Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_AI_T2);
fprintf('Reference track: Poor: %d, Bad: %d, Good: %d, Excellent: %d\n', counts_Ref_T2);

%% Grouping participants based on Cantonese and Mandarin familiarity

% Thresholds
highCantonese = 90;
lowMandarin = 65;
highMandarin = 90;

% Unique participants
participants = unique(data.questionaire_uuid);

% Preallocate
Group1_accuracy = []; % High Cantonese, Low Mandarin
Group2_accuracy = []; % High Cantonese, High Mandarin

for p = 1:length(participants)

    thisP = strcmp(data.questionaire_uuid, participants{p});

    % Get Cantonese familiarity
    idxCanto = thisP & strcmp(data.responses_stimulus, 'Lang_canto');
    canto_fam = mean(data.responses_score(idxCanto));

    % Get Mandarin familiarity
    idxMand = thisP & strcmp(data.responses_stimulus, 'Lang_man');
    mand_fam = mean(data.responses_score(idxMand));

    % Only proceed if both familiarity scores exist
    if ~isnan(canto_fam) && ~isnan(mand_fam)

        % Calculate AI identification accuracy for Cantonese Test 2
        idxCantoT2 = thisP & strcmp(data.wm_id, 'cantonese_test_2') & ...
                     endsWith(data.responses_stimulus, '_1');

        correctResp = data.Correct(idxCantoT2);
        if any(~isnan(correctResp))
            IDaccuracy = 100 * sum(correctResp==1) / sum(~isnan(correctResp));
        else
            IDaccuracy = NaN;
        end

        % Grouping
        if canto_fam > highCantonese && mand_fam < lowMandarin
            Group1_accuracy(end+1) = IDaccuracy;
        elseif canto_fam > highCantonese && mand_fam > highMandarin
            Group2_accuracy(end+1) = IDaccuracy;
        end
    end
end

%% Display average accuracies

mean_G1 = mean(Group1_accuracy, 'omitnan');
mean_G2 = mean(Group2_accuracy, 'omitnan');

fprintf('\n Mean AI ID accuracy (High Cantonese, Low Mandarin): %.2f%%\n', mean_G1);
fprintf('Mean AI ID accuracy (High Cantonese, High Mandarin): %.2f%%\n', mean_G2);

%% Statistical comparison

% Check if both groups have enough data
if numel(Group1_accuracy) > 1 && numel(Group2_accuracy) > 1
    % t-test
    [h, p] = ttest2(Group1_accuracy, Group2_accuracy);
    fprintf('t-test p-value comparing Group 1 and Group 2: %.3f\n', p);
else
    fprintf('Not enough data in one or both groups to perform a t-test.\n');
end

