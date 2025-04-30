clear all;
clc;
rng("default");

[y, Fs] = audioread("D:\webMushra\configs\resources\audio\normalised_TianHou_ref.wav");
y = y(:, 1);
[y_synth, Fss] = audioread("D:\webMushra\configs\resources\audio\normalised_TianHou_david.wav");
y_synth = y_synth(:, 1);
% Original audio spectrogram
subplot(2, 1, 1);
spectrogram(y, 256, 200, 256, Fs, 'yaxis');
title('Original Audio Spectrogram');
colorbar;

% Synthesized audio spectrogram
figure(1);
subplot(2, 1, 2);
spectrogram(y_synth, 256, 200, 256, Fss, 'yaxis');
title('Synthesized Audio Spectrogram');
colorbar;

% Save the figure
% saveas(gcf, 'spectrogram_comparison.png')

% % Define paths
% inputFolder = "MNIST_12"; 
% outputFolder = "synthMnist_12"; 
% 
% if ~exist(outputFolder, 'dir')
%     mkdir(outputFolder);
% end
% 
% allVoice = audioDatastore(inputFolder, 'FileExtensions', '.wav');
% 
% for i = 1:numel(allVoice.Files)
%     % Read the audio file
%     [y, Fs] = audioread(allVoice.Files{i});
% 
%     % Extract the left-hand channel and transpose it to a row vector
%     y = y(:, 1).';
% 
%     % Apply LPC analysis to get LPC coefficients (a) and gain (g)
%     [a, g] = lpcfit(y);
% 
%     % Use the coefficients and gain to synthesize a new audio vector
%     y_synth = lpcsynth(a, g);
% 
%     % Define the output file path
%     [~, name, ~] = fileparts(allVoice.Files{i});
%     outputFilePath = fullfile(outputFolder, strcat(name, '_synth.wav'));
% 
%     % Save the synthesized audio to the output folder
%     audiowrite(outputFilePath, y_synth, Fs);
% end
% 
% 
% 
% % Load synthesized and real voice audio files
% adsSynthVoice = audioDatastore('C:\Users\jabez\OneDrive\Documents\year 4\music signal analysis\lab_5_JC\synthMnist_12');
% allSynthVoice = readall(adsSynthVoice);
% 
% adsRealVoice = audioDatastore('C:\Users\jabez\OneDrive\Documents\year 4\music signal analysis\lab_5_JC\MNIST_12');
% allRealVoice = readall(adsRealVoice);
% 
% % Initialize empty structures for features
% synthVoiceFeatures = struct();
% realVoiceFeatures = struct();
% 
% % Process synthesized voice files
% Ls = length(allSynthVoice);
% for n = 1:Ls
%     data = allSynthVoice{n};
%     data = data(:, 1); % Extract left channel
% 
%     % Feature extraction
%     synthRMS = rms(data); % Root Mean Square energy
%     synthZCR = sum(abs(diff(data > 0))) / length(data); % Zero crossing rate
% 
%     synthVoiceFeatures(n).filename = adsSynthVoice.Files{n};
%     synthVoiceFeatures(n).label = 'synth';
%     synthVoiceFeatures(n).labelColourCode = [1, 0, 0]; % Red for synth
%     synthVoiceFeatures(n).RMS = synthRMS;
%     synthVoiceFeatures(n).ZCR = synthZCR;
% end
% 
% % Process real voice files
% Lr = length(allRealVoice);
% for n = 1:Lr
%     data = allRealVoice{n};
%     data = data(:, 1); % Extract left channel
% 
%     % Feature extraction
%     realRMS = rms(data); % Root Mean Square energy
%     realZCR = sum(abs(diff(data > 0))) / length(data); % Zero crossing rate
% 
%     realVoiceFeatures(n).filename = adsRealVoice.Files{n};
%     realVoiceFeatures(n).label = 'real';
%     realVoiceFeatures(n).labelColourCode = [0, 0, 1]; % Blue for real
%     realVoiceFeatures(n).RMS = realRMS;
%     realVoiceFeatures(n).ZCR = realZCR;
% end
% 
% % Convert feature structures to tables
% synthVoiceFeatures = struct2table(synthVoiceFeatures);
% realVoiceFeatures = struct2table(realVoiceFeatures);
% 
% % Display the tables
% disp(synthVoiceFeatures);
% disp(realVoiceFeatures);
% 
% % Scatter plot of ZCR vs. RMS for both real and synthesized voice
% figure(2);
% scatter([synthVoiceFeatures.ZCR], [synthVoiceFeatures.RMS], [], synthVoiceFeatures.labelColourCode, 'filled');
% hold on;
% scatter([realVoiceFeatures.ZCR], [realVoiceFeatures.RMS], [], realVoiceFeatures.labelColourCode, 'filled');
% 
% xlabel('Zero Crossing Rate');
% ylabel('RMS Energy');
% title('Synthesized vs. Real Voice Scatter Plot');
% legend('Synthesized Voice', 'Real Voice');
% hold off;
% 
% % Combined and normalize the data for proper visualization
% allFeatures = [synthVoiceFeatures; realVoiceFeatures];
% allFeatures = normalize(allFeatures, "range", "DataVariables", "ZCR");
% allFeatures = normalize(allFeatures, "range", "DataVariables", "RMS");
% 
% % Separate normalized features for scatter plot
% synthData = allFeatures(strcmp(allFeatures.label, 'synth'), :);
% realData = allFeatures(strcmp(allFeatures.label, 'real'), :);
% 
% figure(3);
% scatter(synthData.ZCR, synthData.RMS, [], synthData.labelColourCode, 'filled');
% hold on;
% scatter(realData.ZCR, realData.RMS, [], realData.labelColourCode, 'filled');
% 
% xlabel('Normalized Zero Crossing Rate');
% ylabel('Normalized RMS Energy');
% title('Normalized Synthesized vs. Real Voice Scatter Plot');
% legend('Synthesized Voice', 'Real Voice');
% hold off;
