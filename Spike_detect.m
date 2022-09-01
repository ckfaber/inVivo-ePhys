%% Spike_detect

% To do: 
% - convert to function; wrapper for Get_spikes
% - move the check to see if _spikes exists to earlier, before loading raw
% data, to save time

% function inputs
% filename (for .mat in Extracted subfolder)
% varargin: 
%
% - Name-value pairs using inputParser method: https://www.mathworks.com/help/matlab/ref/inputparser.html?s_tid=doc_ta
%   parameters for spike sorting via Get_spikes.m, otherwise use default.
%
% - whether spike sorting is needed (yes/no - if yes, tells
%   Do_clustering/Spike_sort wrapper function to look in temp folder for
%   _spikes.mat files to loop through them.


filename    = '2022-08-16_dmu005_001';

%% Load raw neural data

load_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Extracted\');
save_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Processed\');
raw_data    = load([load_dir filename],'-mat','data','sr');

data_mat    = raw_data.data;
sr          = raw_data.sr;
clear raw_data

%% Prepare for spike detection

% Initialize empty data matrix and cell array with file names
nChan       = size(data_mat,1);
batch_files = cell(nChan,1);

% Check if temp folder for Get_spikes already exists
path = fullfile(tempdir,'Get_spikes');
if exist(path) ~=7
    mkdir(tempdir,'Get_spikes');
end

% Check if _spikes.mat files exist already
pathfiles   = what(path);
pathfiles   = pathfiles.mat;
spikefiles  = pathfiles(find(contains(pathfiles,'spikes.mat')));
rawfiles    = pathfiles(find(~contains(pathfiles,'spikes.mat')));

if size(rawfiles,2) == nChan % MODIFY - CHECK IF FILENAMES MATCH FILENAME
    prompt = '_spikes.mat files with matching filename detected in tempdir. Repeat spike detection and overwrite existing files?';
    answer = questdlg(prompt, ...
                      'Warning', ...
                      'YES', ...
                      'NO', 'NO')
    switch answer
        case 'YES'

        % Loop through channels and save each to individual .mat file
        for chi = 1:nChan

         % To temp folder, save each channel as separate .mat for Get_spikes
         temp_filename      = [filename '_ch' num2str(chi)];
         data = data_mat(chi,:);
         save(fullfile(path,'Get_spikes',temp_filename),'data','sr') % save raw broadband data for each channel as .mat
         fprintf('Data saved to tempdir, ready for input to Get_spikes.m')

         % Spike detection via Get_spikes

         % if parameters detected in varargin
         % 
         %     param.detection = 'both';
         %     param.w_pre      = w_pre;
         %     param.w_post     = w_post;
         % 
         % end

        cd(fullfile(path,'Get_spikes'))
        Get_spikes(rawfiles,'par',param);

        end

        case 'NO'
            fprintf('Existing _spikes.mat files located in tempdir.\nType tempdir at the command line to locate for further analysis.\n')
    end
end

%% Combine separate _spikes files into one big struct. Save to Extracted folder.

% Add check for _MUA.mat before executing
% look into save_dir if it contains filename_MUA.mat.

% Initialize struct to store spike data
spikes             = struct;

% Loop through _spikes.mat files
for chi = 1:size(spikefiles,2);

    fieldname    = ['ch' num2str(chi)];
    spikes.(fieldname) = load(spikefiles{chi},'index','threshold','spikes','par');

end

cd(save_dir)
save([filename '_MUA' '.mat'],'spikes');

%% THINK ABOUT INPUT TO DO_CLUSTERING - maybe saving to temporary folder isn't the best way