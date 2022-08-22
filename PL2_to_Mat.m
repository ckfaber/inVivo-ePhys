%% PL2_to_Mat
% Script for extracting data from .pl2 files from Plexon electrophysiology
% system, and saving to .mat

% Prepared by: Chelsea Faber, Bradley Greger
% Mirzadeh Lab, Barrow Neurological Institute

% kasper.chelsea@gmail.com

% Requirements: 
% - Plexon Offline SDK: https://plexon.com/software-downloads/#software-downloads-SDKs

clear;
clc;

%% To-do: 

%    - convert to function: 
%       - inputs: 
%       - array of file names? or just one at a time for now
%       - list of non-neural data channels desired
%    - improve hard-coding of centralized data repository - fullfile?

%% Set data loading/saving directories

% Files
file_name = '2021-09-17_test5';

% Hard-code file directories
load_dir   = 'C:\Users\cfaber\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\';

% Dont' change
load_path   = [load_dir file_name '.pl2'];
save_dir    = [load_dir 'Extracted'];
cd(save_dir)

%% Load data

% Load Omniplex metadata
pl2idx      = PL2GetFileIndex(load_path);

% Load neural data into matrix
if exist([file_name '.mat'],'file') ==2

    fprintf('Data have already been extracted to Extracted folder.');

elseif exist([file_name '.mat'],'file') ==0

    [nChan,sampCounts]          = plx_adchan_samplecounts(load_path);
    L                           = sampCounts(1);
    number_of_channels          = 16;
    data_mat                    = zeros(number_of_channels,L);              % initialize data matrix

    broadband_ch_names          = {'WB01';'WB02';'WB03';'WB04';'WB05';'WB06';'WB07';'WB08';'WB09';'WB10';'WB11';'WB12';'WB13';'WB14';'WB15';'WB16'};

    for k = 1:number_of_channels

        [sr, n, ts, fn, ad]     = plx_ad_v(load_path, broadband_ch_names{k});
        data_mat(k,:)           = ad;
    
    end

    save([file_name '.mat'],'data_mat','sr','pl2idx');
    fprintf('Data extracted successfully.')

end
%% Load optical stimulation data

[Fs_stim, n, ts, fn, data_stim] = plx_ad_v(load_path, 'AI01');

data_stim                       = (data_stim/max(data_stim)*5)';         % normalize & scale to volts
L_stim                          = size(data_stim,2);                     % length of signal
time_basis_stim                 = 0:1/Fs_stim:(L_stim-1)/Fs_stim;        % time base

save([file_name '_opto_stims' '.mat'],'data_stim','Fs_stim','L_stim','time_basis_stim'); 
