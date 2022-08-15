% WIP script for reading in .pl2 files from Plexon electrophysiology system
% Prepared by: Chelsea Faber, Bradley Greger
% 
% Requirements: 
% - Plexon Offline SDK: https://plexon.com/software-downloads/#software-downloads-SDKs
% - Chronux 
% - wave_clus 
% - Signal Processing Toolbox

clear;
clc;

%% To-do: 

%    - quick time-frequency spectra?

%    - tidy data procedure to automate data down-sampling, filtering,
%   epoch-alignment, spike extraction, etc. based upon pre-defined
%   procedure/parameter saved in ExperimentLog file.
%        - update data directory so all .pl2 files are in common folder
%        - implement consistent naming convention for all experimental data
%    files

%% Set data loading/saving directories

% Files
file_name = '2021-09-17_test5';

% Hard-code file directories
load_path   = 'C:\Users\cfaber\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\';

save_dir    = 'C:\Users\cfaber\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Extracted';  

% Dont' change
load_path = [load_path file_name '.pl2'];
cd(save_dir)

%% Load data into matrix; export each channel as .mat for wave_clus spike sorting

[nChan,sampCounts]          = plx_adchan_samplecounts(load_path);
L                           = sampCounts(1);
number_of_channels          = 16;
data_mat                    = zeros(number_of_channels,L);              % initialize data matrix

broadband_ch_names          = {'WB01';'WB02';'WB03';'WB04';'WB05';'WB06';'WB07';'WB08';'WB09';'WB10';'WB11';'WB12';'WB13';'WB14';'WB15';'WB16'};

for k = 1:number_of_channels

    [sr, n, ts, fn, ad]     = plx_ad_v(load_path, broadband_ch_names{k});
    data_mat(k,:)           = ad;
    
end

% TO DO: omit this, to avoid having to save a bunch of individual .mat
% files just for Get_spikes. Can do that temporarily in future if necessary
cd(save_dir)
save([file_name '.mat'],'data_mat','sr');          

%% Load optical stimulation data

[Fs_stim, n, ts, fn, data_stim] = plx_ad_v(load_path, 'AI01');

data_stim                       = (data_stim/max(data_stim)*5)';         % normalize & scale to volts
L_stim                          = size(data_stim,2);                     % length of signal
time_basis_stim                 = 0:1/Fs_stim:(L_stim-1)/Fs_stim;        % time base

save([file_name '_opto_stims' '.mat'],'data_stim','Fs_stim','L_stim','time_basis_stim'); 
