% First, expand CorrectStimuli to include the test ID too!
CorrectStimuli = {
    'english_test_1','C1_1','AI';
    'english_test_1','C2_1','AI';
    'english_test_1','C3_1','Human';
    'english_test_1','C4_1','AI';
    'english_test_1','C5_1','Human';

    'english_test_2','C1_1','AI';
    'english_test_2','C2_1','Human';
    'english_test_2','C3_1','AI';
    'english_test_2','C4_1','AI';

    'japanese_test_1','C1_1','AI';
    'japanese_test_1','C2_1','AI';
    'japanese_test_1','C3_1','AI';
    'japanese_test_1','C4_1','Human';

    'japanese_test_2','C1_1','AI';
    'japanese_test_2','C2_1','AI';
    'japanese_test_2','C3_1','Human';
    'japanese_test_2','C4_1','AI';
    'japanese_test_2','C5_1','AI';

    'mandarin_test_1','C1_1','AI';
    'mandarin_test_1','C2_1','Human';
    'mandarin_test_1','C3_1','Human';
    'mandarin_test_1','C4_1','AI';

    'mandarin_test_2','C1_1','AI';
    'mandarin_test_2','C2_1','Human';
    'mandarin_test_2','C3_1','AI';
    'mandarin_test_2','C4_1','Human';

    'cantonese_test_1','C1_1','AI';
    'cantonese_test_1','C2_1','Human';
    'cantonese_test_1','C3_1','Human';
    'cantonese_test_1','C4_1','Human';
    'cantonese_test_1','C5_1','Human';

    'cantonese_test_2','C1_1','AI';
    'cantonese_test_2','C2_1','Human';
    'cantonese_test_2','C3_1','AI';
    'cantonese_test_2','C4_1','Human'
};

% Create table
correctTable = cell2table(CorrectStimuli, 'VariableNames', {'TestID','Stimulus','CorrectAnswer'});

%% Assign correct answers to the main data table

data.CorrectAnswer = repmat({''}, height(data), 1);

for i = 1:height(data)

    stimID = data.responses_stimulus{i};
    testID = data.wm_id{i};

    % Only _1 stimuli (AI ID questions)
    if endsWith(stimID, '_1')

        % Search for a row where both testID and stimID match
        matchRow = strcmp(correctTable.TestID, testID) & strcmp(correctTable.Stimulus, stimID);

        if any(matchRow)
            data.CorrectAnswer{i} = correctTable.CorrectAnswer{matchRow};
        else
            data.CorrectAnswer{i} = ''; % No match found
        end

    end
end

% List of AI experience values in the same order as the 20 participants
ai_music_exp = [1, 1, 1, 1, NaN, NaN, 0, 1, 1, 0, 0, 1, 0, NaN, 0, NaN, NaN, NaN, 0, 0];

% Get the unique participant IDs
participants = unique(data.questionaire_uuid, 'stable'); % ensure same order

% Preallocate column
data.AIMusicExperience = NaN(height(data), 1);

% Loop through and assign the experience value to all rows of each participant
for i = 1:numel(participants)
    thisParticipant = participants{i};
    expVal = ai_music_exp(i);

    % Find all rows from this participant
    idx = strcmp(data.questionaire_uuid, thisParticipant);
    
    % Assign the experience value
    data.AIMusicExperience(idx) = expVal;
end
