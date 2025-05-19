clear all
clc
opts = detectImportOptions('mushra_noloop_nowav (4).csv', 'Delimiter', ';');
dataPtB = readtable('mushra_noloop_nowav (4).csv', opts);

dataADH = readtable('restructured_A_aligned_structure.xlsx');

dataADH.responses_comment = [];
dataPtB.responses_comment = [];

data = [dataADH;dataPtB];

writetable(dataPtB, 'outputPTB.xlsx'); 
