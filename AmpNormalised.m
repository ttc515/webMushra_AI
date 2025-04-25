% Peak normalisation script (British English)
% Resamples files to match reference if needed
clc
clear all
% === Setup ===
audioFolder = 'D:\webMushra\configs\resources\audio\';
refFile = fullfile(audioFolder, 'Smbdytolv_ref.wav');

% Create output folder
outputFolder = fullfile(audioFolder, 'normalised');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% === Load reference audio ===
if ~isfile(refFile)
    error('Reference file "%s" not found.', refFile);
end

[refAudio, refFs] = audioread(refFile);
refPeak = max(abs(refAudio));

% === List of files to be normalised (excluding reference) ===
files = {
    'Smbdytolv_r.wav'
    'Smbdytolv_audit.wav'
    'Smbdytolv_CD.wav'
    'Smbdytolv_crab.wav'
    'Smbdytolv_mj.wav'
    '39_AI_ace.wav'
    '1_AImodel.wav'
    '1_cm.wav'
    '1_cover1.wav'
    '1_cover2.wav'
    '1_ref.wav'
    '1_WanK.wav'
    '1min_ref.wav'
    '1min_suno.wav'
    '39_39.wav'
    'CantoIndie.wav'
    'CantoIndie2.wav'
    'CantoRap.wav'
    'Choco.wav'
    'Eng_suno.wav'
    '39_AI_kim.wav'
    '39_ref.wav'
    '39_suno.wav'
    '39_VT.wav'
    'Callmyname.wav'
    'Mandarin_suno.wav'
    'ManIndie2.wav'
    'ManIndie3.wav'
    'Eyes_SUNO.wav'
    'IN_K.wav'
    'JP_suno.wav'
    'Kafu.wav'
    'Kafu1.1.wav'
    'Man_suno2.wav'
    'Suno_CantoRap.wav'
    'TianHou_boi.wav'
    'TianHou_david.wav'
    'TianHou_justin.wav'
    'Suno_CantoPop.wav'
    'TianHou_xzhq.wav'
    'Utawaku.wav'
    'VoisonaUI.wav'
    'TianHou_ref.wav'
    'Tianhou_school.wav'
};

% === Normalisation Loop ===
for i = 1:length(files)
    inputFile = fullfile(audioFolder, files{i});

    if ~isfile(inputFile)
        warning('File "%s" not found. Skipping...', inputFile);
        continue;
    end

    [audioIn, fs] = audioread(inputFile);

    % Resample if sampling rate doesn't match reference
    if fs ~= refFs
        fprintf('Resampling "%s" from %d Hz to %d Hz...\n', files{i}, fs, refFs);
        audioIn = resample(audioIn, refFs, fs);
        fs = refFs;
    end

    % Peak normalisation
    peak = max(abs(audioIn));
    if peak > 0
        scalingFactor = refPeak / peak;
        audioOut = audioIn * scalingFactor;
    else
        audioOut = audioIn;
    end

    

    % Save normalised file to output folder
    [~, name, ext] = fileparts(files{i});
    outFile = fullfile(outputFolder, ['normalised_' name ext]);
    audiowrite(outFile, audioOut, fs);

    fprintf('Normalised "%s" -> "%s"\n', files{i}, outFile);
end

disp('All files have been resampled (if needed) and peak-normalised.');
