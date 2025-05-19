% List of unique participants
participants = unique(data.questionaire_uuid);

% Initialize arrays to store participant IDs and their accuracies
participant_ids = {};
participant_accuracies = [];

% Loop through each participant to calculate identification accuracy
for i = 1:numel(participants)
    participant_id = participants{i};
    idx = strcmp(data.questionaire_uuid, participant_id) & endsWith(data.responses_stimulus, '_1');
    correct_responses = data.Correct(idx);
    
    if any(~isnan(correct_responses))
        accuracy = 100 * sum(correct_responses == 1) / sum(~isnan(correct_responses));
        participant_ids{end+1} = participant_id;
        participant_accuracies(end+1) = accuracy;
    end
end

% Convert to table for easier handling
participant_accuracies_table = table(participant_ids', participant_accuracies', ...
    'VariableNames', {'ParticipantID', 'Accuracy'});

% Find the participant with the highest accuracy
[best_accuracy, best_idx] = max(participant_accuracies_table.Accuracy);
best_participant_id = participant_accuracies_table.ParticipantID{best_idx};

% Display the best participant's ID and accuracy
fprintf('Best Performing Participant:\n');
fprintf('ID: %s\n', best_participant_id);
fprintf('Identification Accuracy: %.2f%%\n', best_accuracy);

% Retrieve language familiarity scores for the best participant
idx_lang_fam = strcmp(data.questionaire_uuid, best_participant_id) & startsWith(data.wm_id, 'Lang_');
lang_fam_stimuli = data.responses_stimulus(idx_lang_fam);
lang_fam_scores = data.responses_score(idx_lang_fam);

% Define the list of languages and their corresponding stimulus identifiers
languages = {'Cantonese', 'Japanese', 'Mandarin', 'English'};
stim_ids = {'Lang_canto', 'Lang_jp', 'Lang_man', 'Lang_eng'};

% Loop through each language to retrieve and display the familiarity score
fprintf('\nLanguage Familiarity Scores:\n');
for i = 1:length(stim_ids)
    % Index based on participant ID and responses_stimulus value
    idx = strcmp(data.questionaire_uuid, best_participant_id) & strcmp(data.responses_stimulus, stim_ids{i});
    
    % Retrieve and display the familiarity score
    if any(idx)
        score = data.responses_score(idx);
        fprintf('%s: %.2f\n', languages{i}, score);
    else
        fprintf('%s: Not Available\n', languages{i});
    end
end


% Get unique participant IDs
participants = unique(data.questionaire_uuid);

% Initialise arrays
participant_ids = {};
participant_accuracies = [];

% Compute identification accuracy per participant
for i = 1:numel(participants)
    participant_id = participants{i};
    idx = strcmp(data.questionaire_uuid, participant_id) & endsWith(data.responses_stimulus, '_1');
    correct_responses = data.Correct(idx);

    if any(~isnan(correct_responses))
        acc = 100 * sum(correct_responses == 1) / sum(~isnan(correct_responses));
        participant_ids{end+1} = participant_id;
        participant_accuracies(end+1) = acc;
    end
end

% Convert to table
resultsTable = table(participant_ids', participant_accuracies', ...
    'VariableNames', {'ParticipantID', 'Accuracy'});

% Sort by accuracy descending
resultsTable = sortrows(resultsTable, 'Accuracy', 'descend');

% Add columns for language familiarity
lang_stims = {'Lang_canto', 'Lang_jp', 'Lang_man', 'Lang_eng'};
lang_labels = {'CantoneseFam', 'JapaneseFam', 'MandarinFam', 'EnglishFam'};

for l = 1:length(lang_stims)
    scores = NaN(height(resultsTable),1);
    for i = 1:height(resultsTable)
        pid = resultsTable.ParticipantID{i};
        row = strcmp(data.questionaire_uuid, pid) & ...
              strcmp(data.responses_stimulus, lang_stims{l});
        if any(row)
            scores(i) = data.responses_score(find(row, 1)); % Get the first match
        end
    end
    resultsTable.(lang_labels{l}) = scores;
end

% Show top 10 participants
top10 = resultsTable(1:min(10, height(resultsTable)), :)

% Optional: Display as formatted output
disp('Top 10 Participants by Identification Accuracy:')
disp(top10)


