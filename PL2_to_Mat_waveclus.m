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

%    - Automate spike sorting with wave_clus --> how to set default
%    settings but be able to go back and manually sort after? 

%    - combine sorted spikes into matrix --> ID optical responders &
%    standardize metric/doc

%    - tidy data procedure to automate data down-sampling, filtering,
%   epoch-alignment, spike extraction, etc. based upon pre-defined
%   procedure/parameter saved in ExperimentLog file.
%        - update data directory so all .pl2 files are in common folder
%        - implement consistent naming convention for all experimental data
%    files

%% Set data loading/saving directories

% Files
file_name = '2022-08-02_dmu005-002';

% Hard-code file directories
load_path   = 'C:\Users\cfaber\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\';

save_dir    = 'C:\Users\cfaber\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Extracted';  

% Dont' change
load_path = [load_path file_name '.pl2'];
cd(save_dir)

%% Load data into matrix; export each channel as .mat for wave_clus spike sorting

% NOTE: this breaks if the default ordering of the analog channels is
% changed, which it spontaneously did after updating Omniplex. Many
% empty/0-valued analog channels occur BEFORE the 16-channels of neural
% analog data. 

% UPDATE: think that the issue is that the WB data is not being saved - WTF
% PLEXON?!?! Need to reconfigure the PlexControl settings. 

[nChan,sampCounts]          = plx_adchan_samplecounts(load_path);
L                           = sampCounts(1);
number_of_channels          = 16;
data_mat                    = zeros(number_of_channels,L);             % initialize data matrix

for k = 0:number_of_channels-1

    [sr, n, ts, fn, ad]     = plx_ad_v(load_path, 33);
    data_mat(k+1,:)         = ad;
    data = data_mat(k+1,:);
    save([file_name '_ch' num2str(k+1) '.mat'],'data','sr') % save raw broadband data for each channel as .mat
end

sr                          = sr;                                       % sampling frequency
L                           = size(data_mat,2);                         % length of signal
time_basis                  = 0:1/sr:(L-1)/sr;                          % time base

cd(save_dir)
save([file_name '.mat'],'data_mat','sr');          
batch_txt = what; batch_txt = batch_txt.mat;
batch_input = [file_name '_batch.txt'];
writecell(batch_txt,batch_input);  % save txt file with names of each .mat file for broadband data

%% Wave_clus spike sorting

Get_spikes(batch_input);

% set parameters for automated spike sorting:
param.min_clus              = 20;
param.max_spk               = 50000;
par.maxtemp                 = 0.251;
set(0, 'DefaultFigureWindowStyle', 'normal');
Do_clustering('09172021test2_ch5_spikes.mat'); % test file for now; use 'all' to run all files in current directory

%% Load optical stimulation data

[Fs_stim, n, ts, fn, data_stim] = plx_ad_v(load_path, 'AI01');

data_stim                       = (data_stim/max(data_stim)*5)';         % normalize & scale to volts
L_stim                          = size(data_stim,2);                     % length of signal
time_basis_stim                 = 0:1/Fs_stim:(L_stim-1)/Fs_stim;        % time base

save([file_name '_opto_stims' '.mat'],'data_stim','Fs_stim','L_stim','time_basis_stim'); 
