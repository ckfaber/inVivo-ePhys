%% lowpass_BATCH.m

% Script for batch low-pass filtering and downsampling raw data.
%
% Prepared by: Chelsea Faber
% Mirzadeh Lab, Barrow Neurological Institute
%
% kasper.chelsea@gmail.com
%
%% Get file paths from browser

% From file browser, select all .pl2 files to be loaded. For Dropbox data,
% be sure to first "Make Available Offline"
[file,path] = uigetfile('*.mat','MultiSelect','on');
%filepaths = strcat(path,file);

%% Run lowpass_down.m function for all files

cellfun(@(x) lowpass_down(x,path),file)