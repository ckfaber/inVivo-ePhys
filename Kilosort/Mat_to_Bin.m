%% Change to your file/folder path

filename = '2022-08-16_dmu005_001'; % Do not include the '.mat' in the file name here
filepath = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Extracted\');

%% Don't change these:
f = [filepath filename];

% Load data and make type int16
load(f,'data'); % loads neural data matrix (channels x time)
dati = int16(data); % converts to int16

% Export as binary file
fid = fopen([filepath 'Kilosort\' filename '.bin'],'w');
fwrite(fid, dati, 'int16');
fclose(fid);
