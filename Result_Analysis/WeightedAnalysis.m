%% Weighted identification analysis — ALL RESPONSES

% Initialize counts
total_success = 0;
total_pass = 0;
total_correct = 0;
total_incorrect = 0;

% Loop through all responses
for i = 1:height(data)

    stimID = data.responses_stimulus{i};

    % Only consider _1 stimuli (AI identification)
    if endsWith(stimID, '_1')

        resp = data.responses_score(i);
        answ = data.CorrectAnswer{i};

        % Skip if no correct answer available
        if isempty(answ)
            continue
        end

        % Classification
        if resp >= 56
            if strcmp(answ, 'AI')
                total_success = total_success + 1;
            elseif strcmp(answ, 'Human')
                total_correct = total_correct + 1;
            end

        elseif resp <= 44
            total_incorrect = total_incorrect + 1;

        elseif resp >= 45 && resp <= 55
            if strcmp(answ, 'AI')
                total_pass = total_pass + 1; % Pass category (Turing test success)
            else
                total_correct = total_correct + 1; % Acceptable for Human clips
            end
        end

    end
end

%% Compute overall weighted accuracy

total_considered = total_success + total_correct + total_incorrect;

if total_considered > 0
    overall_accuracy = 100 * (total_correct) / total_considered;
else
    overall_accuracy = NaN;
end

fprintf('\nOverall weighted AI Identification Accuracy (ALL responses): %.2f%%\n', overall_accuracy);

% Optionally, show counts
fprintf('Success: %d | Pass: %d | Correct: %d | Incorrect: %d\n', ...
    total_success, total_pass, total_correct, total_incorrect);