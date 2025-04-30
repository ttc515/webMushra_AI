clear all
opts = detectImportOptions('mushra_noloop_nowav_updated.csv', 'Delimiter', ';');
data = readtable('mushra_noloop_nowav_updated.csv', opts);

