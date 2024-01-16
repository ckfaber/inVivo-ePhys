%% PL2_Batch_Extract

files = {'2023-07-04_dmu006_001.pl2';
'2023-07-04_dmu006_002.pl2'};

%% 
nRec = size(files,1);
for reci = 1:nRec
    
    filename = files{reci};
    fprintf(['Extracting file ' num2str(reci) ' of ' num2str(nRec) ', ' filename '\n'])
    PL2_to_Mat(filename);

end
