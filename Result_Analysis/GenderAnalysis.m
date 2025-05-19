participants = unique(data.questionaire_uuid);

acc_male = [];
acc_female = [];
sq_male = [];
sq_female = [];

for p = 1:numel(participants)
    thisP = strcmp(data.questionaire_uuid, participants{p});

    % Gender row
    idxGender = thisP & strcmp(data.wm_id, 'gender');

    % Determine gender based on whether 'M' or 'F' stimulus is marked 1
    genderRows = find(idxGender);
    gender = '';
    for g = genderRows'
        if strcmp(data.responses_stimulus{g}, 'M') && data.responses_score(g) == 1
            gender = 'M';
            break
        elseif strcmp(data.responses_stimulus{g}, 'F') && data.responses_score(g) == 1
            gender = 'F';
            break
        end
    end

    if isempty(gender)
        continue
    end

    % Identification accuracy (_1 stimuli)
    idxID = thisP & endsWith(data.responses_stimulus, '_1');
    correctResp = data.Correct(idxID);

    if any(~isnan(correctResp))
        acc = 100 * sum(correctResp == 1) / sum(~isnan(correctResp));
        if gender == 'M'
            acc_male(end+1) = acc;
        elseif gender == 'F'
            acc_female(end+1) = acc;
        end
    end

    % Sound quality (_2 stimuli)
    idxSQ = thisP & endsWith(data.responses_stimulus, '_2');
    scores = data.responses_score(idxSQ);

    if any(~isnan(scores))
        meanSQ = mean(scores);
        if gender == 'M'
            sq_male(end+1) = meanSQ;
        elseif gender == 'F'
            sq_female(end+1) = meanSQ;
        end
    end
end

% Compute means
mean_acc_male = mean(acc_male, 'omitnan');
mean_acc_female = mean(acc_female, 'omitnan');
mean_sq_male = mean(sq_male, 'omitnan');
mean_sq_female = mean(sq_female, 'omitnan');

% Perform t-tests
[~, p_acc] = ttest2(acc_male, acc_female);
[~, p_sq] = ttest2(sq_male, sq_female);

% Display results
fprintf('\n--- Identification Accuracy ---\n');
fprintf('Male: %.2f%%\n', mean_acc_male);
fprintf('Female: %.2f%%\n', mean_acc_female);
fprintf('t-test p-value (accuracy): %.4f\n', p_acc);

fprintf('\n--- Sound Quality Ratings ---\n');
fprintf('Male: %.2f\n', mean_sq_male);
fprintf('Female: %.2f\n', mean_sq_female);
fprintf('t-test p-value (sound quality): %.4f\n', p_sq);
