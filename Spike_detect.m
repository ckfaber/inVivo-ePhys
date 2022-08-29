%% Spike_detect

% To do: 
% convert to function; wrapper for Get_spikes

% function inputs
% filename (for .mat in Extracted subfolder)
% varargin: parameters for spike sorting via Get_spikes.m, otherwise use
% default. Name-value pairs using inputParser method: https://www.mathworks.com/help/matlab/ref/inputparser.html?s_tid=doc_ta

filename    = '2022-08-16_dmu005_001';

%% Load raw neural data

load_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Extracted\');
raw_data    = load([load_dir filename],'-mat','data','sr');

data_mat    = raw_data.data;
sr          = raw_data.sr;
clear raw_data

%% Prepare for spike detection

% Initialize empty data matrix and cell array with file names
nChan       = size(data_mat,1);
batch_files = cell(nChan,1);

% Extract path to temporary folder
path        = tempdir;

% Check if temp folder for Get_spikes already exists
if exist(fullfile(path,'Get_spikes')) ~=7
    mkdir(path,'Get_spikes');
end

% Loop through channels and save each to individual .mat file
for chi = 1:nChan

    % To temp folder, save each channel as separate .mat for Get_spikes
    temp_filename            = [filename '_ch' num2str(chi)];
    data = data_mat(chi,:);
    save(fullfile(path,'Get_spikes',temp_filename),'data','sr') % save raw broadband data for each channel as .mat
    batch_files{chi}         = [temp_filename '.mat'];

end

%% Spike detection via Get_spikes

% if parameters detected in varargin
% 
%     param.detection = 'both';
%     param.w_pre      = w_pre;
%     param.w_post     = w_post;
% 
% end

cd(fullfile(path,'Get_spikes'))
Get_spikes(batch_files,'par',param);

%% Combine separate _spikes files into one big struct. Save to Extracted folder.

% what to include? 
% - index
% - spikes
% - threshold
% - par??? <- should be the same for each channel, seems redundant to have
% duplicates around. 



