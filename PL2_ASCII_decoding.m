%% ASCII decoding

% Incorporate into any script requiring event extraction

clear;clc;
filepath = "C:\Users\kaspe\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\2023-09-27_port-test.pl2";
event = PL2EventTs(filepath,'Strobed'); 
event.char = char(event.Strobed);