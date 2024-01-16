% PL2_to_Mat_BATCH
% Script for batch loading .pl2 files to .mat
%
% Prepared by: Chelsea Faber
% Mirzadeh Lab, Barrow Neurological Institute
%
% kasper.chelsea@gmail.com
%
% Requirements: 
% For full documentation, please see the README and Getting
% Started guides at https://github.com/ckfaber/inVivo-ePhys
%% Get file paths from browser

% From file browser, select all .pl2 files to be loaded. For Dropbox data,
% be sure to first "Make Available Offline"
[file,path] = uigetfile('*.pl2','MultiSelect','on');
%filepaths = strcat(path,file);

%% Run PL2_to_Mat.m function for all files

cellfun(@(x) PL2_to_Mat(x,path),file)