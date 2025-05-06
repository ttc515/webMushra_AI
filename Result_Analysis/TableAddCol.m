CorrectStimuli = {
    'C1_1','C2_1','C3_1','C4_1','C5_1',... % English Test 1
    'C1_1','C2_1','C3_1','C4_1',...         % English Test 2
    'C1_1','C2_1','C3_1','C4_1',...         % Japanese Test 1
    'C1_1','C2_1','C3_1','C4_1','C5_1',...  % Japanese Test 2
    'C1_1','C2_1','C3_1','C4_1',...         % Mandarin Test 1
    'C1_1','C2_1','C3_1','C4_1',...         % Mandarin Test 2
    'C1_1','C2_1','C3_1','C4_1','C5_1',...  % Cantonese Test 1
    'C1_1','C2_1','C3_1','C4_1'             % Cantonese Test 2
    };
disp(CorrectStimuli)

CorrectAnswer = {
    'AI','AI','Human','AI','Human',...      % English Test 1
    'AI','Human','AI','AI',...              % English Test 2
    'AI','AI','AI','Human',...              % Japanese Test 1
    'AI','AI','Human','AI','AI',...         % Japanese Test 2
    'AI','Human','Human','AI',...           % Mandarin Test 1
    'AI','Human','AI','Human',...           % Mandarin Test 2
    'AI','Human','Human','Human','Human',...% Cantonese Test 1
    'AI','Human','AI','Human'               % Cantonese Test 2
    };

correctTable = table(CorrectStimuli', CorrectAnswer', 'VariableNames', {'CorrectStimuli','CorrectAnswer'});

%%
% Initialise

data.CorrectAnswer = repmat({''}, height(data), 1);


for i = 1:height(data)

    stimID = data.responses_stimulus{i};
    testID = data.wm_id{i};

    
    if endsWith(stimID, '_1')

       
        if strcmp(testID,'english_test_1')
            testNum = 1;
        elseif strcmp(testID,'english_test_2')
            testNum = 2;
        elseif strcmp(testID,'japanese_test_1')
            testNum = 3;
        elseif strcmp(testID,'japanese_test_2')
            testNum = 4;
        elseif strcmp(testID,'mandarin_test_1')
            testNum = 5;
        elseif strcmp(testID,'mandarin_test_2')
            testNum = 6;
        elseif strcmp(testID,'cantonese_test_1')
            testNum = 7;
        elseif strcmp(testID,'cantonese_test_2')
            testNum = 8;
        else
            testNum = NaN;
        end

        stimMatches = strcmp(CorrectStimuli, stimID); % rows in correctTable with this stimID
        whichStim = find(stimMatches); % indices in CorrectStimuli

        % Pick the correct occurrence
        if ~isempty(whichStim) && length(whichStim) >= testNum
            tableRow = whichStim(testNum); % Pick the nth occurrence
            data.CorrectAnswer{i} = CorrectAnswer{tableRow};
        else
            data.CorrectAnswer{i} = ''; % No match 
        end

    end
end

