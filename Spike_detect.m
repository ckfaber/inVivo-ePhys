%% Spike_detect

% To do: 
% convert to function; wrapper for Get_spikes


%    - Automate spike sorting with wave_clus --> how to set default
%    settings but be able to go back and manually sort after? 

%    - combine sorted spikes into matrix --> ID optical responders &
%    standardize metric/doc

% function inputs
% filename (for .mat in Extracted subfolder)
% parameters for spike sorting via Get_spikes.m

filename    = '2022-08-16_dmu005_001';

%% Load raw neural data

load_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Extracted\');
raw_data    = load([load_dir filename],'-mat','data','sr');

data_mat    = raw_data.data;
sr          = raw_data.sr;
clear raw_data

%% Prepare for spike detection

nChan       = size(data_mat,1);
batch_files = cell(nChan,1);

path        = tempdir;

% Check if temp folder for Get_spikes already exists (typically deleted
% every 30 days)
if exist(fullfile(path,'Get_spikes')) ~=7
    mkdir(path,'Get_spikes');
end

for chi = 1:nChan

    % To temp folder, save each channel as separate .mat for Get_spikes
    temp_filename            = [filename '_ch' num2str(chi)];
    data = data_mat(chi,:);
    save(fullfile(path,'Get_spikes',temp_filename),'data','sr') % save raw broadband data for each channel as .mat

    batch_files{chi}         = [temp_filename '.mat'];

end

%% Spike detection

% To do: 
% path to temp folder for Get_spikes
% path to where to save spikes?
% save all channel spikes to one big struct, in Extracted folder, or
% project-specific directory?

cd(fullfile(path,'Get_spikes'))
Get_spikes(batch_files);


%% Combine separate _spikes files into one big struct



%% Spike clustering 
% 
% set parameters for automated spike sorting:
% param.min_clus              = 20;
% param.max_spk               = 50000;
% par.maxtemp                 = 0.251;
% set(0, 'DefaultFigureWindowStyle', 'normal');

% Do_clustering('09172021test2_ch5_spikes.mat'); % test file for now; use 'all' to run all files in current directory

