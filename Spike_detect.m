%% Spike_detect

% To do: 
% - CHANNEL CLEAN-UP/ARTIFACT SUBTRACTION BEFORE DOING THIS
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


filename            = '2022-10-13_dmu005_002';
w_pre               = 0.5;  % in ms
w_post              = 2;    % in ms
sort                = 'yes';

%% Paths to load and save

load_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Extracted\');
temp_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Temp_Get_Spikes\');
save_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Processed\');
savename    = [filename '_MUA' '.mat'];

%% Perform spike detection and save to designated Temp and Processed subfolders

if exist(fullfile(save_dir,savename),'file') ==0

    % Load raw neural data
    raw_data    = load([load_dir filename],'-mat','data','sr');

    % Format for Get_spikes
    data_mat    = raw_data.data;
    sr          = raw_data.sr;
    nChan       = size(data_mat,1);
    L           = size(data_mat,2);

    % Common average re-referencing (artifact removal)
    data_mat    = bsxfun(@minus,data_mat,mean(data_mat,1));

    % Set parameters for Get_spikes
    param.w_pre         = w_pre/1000 * sr; % convert ms to s and multiply by sr to get samples
    param.w_post        = w_post/1000 * sr;
    param.detection     = 'both'; % detect both positive and negative going spikes
    param.sr            = sr; % ensure that the sampling rate is updated from the default in set_parameters()
    clear raw_data
    fprintf('Raw data extracted')

    %             % Check if _spikes.mat files exist already
    %             pathfiles   = what(path);
    %             pathfiles   = pathfiles.mat;

    % Initialize empty data matrix and cell array with file names
    rawfiles    = cell(nChan,1);
    spikefiles  = cell(nChan,1);

    % Loop through channels, saving each channel as separate .mat for Get_spikes
    for chi = 1:nChan

        temp_filename      = [filename '_ch' num2str(chi)];
        rawfiles{chi}      = [temp_filename '.mat'];
        spikefiles{chi}    = [temp_filename '_spikes'];

        data = data_mat(chi,:);
        save(fullfile(temp_dir,temp_filename),'data','sr') % save raw broadband data for each channel as .mat

        fprintf(['Channel ' num2str(chi) ' data saved to temp_dir, ready for input to Get_spikes.m\n'])

    end

    cd(temp_dir)
    fprintf('Running Get_spikes\n')
    Get_spikes(rawfiles,'par',param);

    %Combine separate _spikes files into one big struct. Save to Extracted folder.
    spikes             = struct;

    % Loop through _spikes.mat files
    fprintf('Saving detected spikes from Get_spikes into struct in ''Processed'' folder')
    for chi = 1:size(spikefiles,1);

        fieldname    = ['ch' num2str(chi)];
        spikes.(fieldname) = load(spikefiles{chi},'index','threshold','spikes','par');

    end

    cd(save_dir)
    save(savename,'spikes','L');
    fprintf([savename ' saved to ' save_dir])


% Check to see if spike sorting has already happened
else exist(fullfile(save_dir,savename)) ==2 
    prompt = [savename ' detected in ' save_dir '. Would you like to repeat spike detection and over-write previous data?'];
    answer = questdlg(prompt, ...
                      'Warning', ...
                      'YES', ...
                      'NO', 'NO')
    switch answer
        case 'NO'
            fprintf('MUA already performed. Exiting function.')
            return

        case 'YES'
            % Load raw neural data
            raw_data    = load([load_dir filename],'-mat','data','sr');
    
            % Format for Get_spikes
            data_mat    = raw_data.data;
            sr          = raw_data.sr;
            nChan       = size(data_mat,1);
            L           = size(data_mat,2);

            % Common average re-referencing (artifact removal)
            data_mat    = bsxfun(@minus,data_mat,mean(data_mat,1));
    
            % Set parameters for Get_spikes
            param.w_pre         = w_pre/1000 * sr;
            param.w_post        = w_post/1000 * sr;
            param.detection     = 'both';
            param.sr            = sr;
            clear raw_data
            fprintf('Raw data extracted')

%             % Check if _spikes.mat files exist already
%             pathfiles   = what(path);
%             pathfiles   = pathfiles.mat;
   
            % Initialize empty data matrix and cell array with file names
            rawfiles    = cell(nChan,1);
            spikefiles  = cell(nChan,1);
    
            % Loop through channels
            for chi = 1:nChan
        
                 % To temp folder, save each channel as separate .mat for Get_spikes
                 temp_filename      = [filename '_ch' num2str(chi)];
                 rawfiles{chi}      = [temp_filename '.mat'];
                 spikefiles{chi}    = [temp_filename '_spikes'];
        
                 data = data_mat(chi,:);
                 save(fullfile(temp_dir,temp_filename),'data','sr') % save raw broadband data for each channel as .mat
         
                 fprintf(['Channel ' num2str(chi) ' data saved to temp_dir, ready for input to Get_spikes.m\n'])
                   
            end

            cd(temp_dir)
            fprintf('Running Get_spikes\n')
            Get_spikes(rawfiles,'par',param);

            %Combine separate _spikes files into one big struct. Save to Extracted folder.
            spikes             = struct;
            
            % Loop through _spikes.mat files
            fprintf('Saving detected spikes from Get_spikes into struct in ''Processed'' folder')
            for chi = 1:size(spikefiles,1);
            
                fieldname    = ['ch' num2str(chi)];
                spikes.(fieldname) = load(spikefiles{chi},'index','threshold','spikes','par');
            
            end
            
            cd(save_dir)
            save(savename,'spikes','L');
            fprintf([savename ' saved to ' save_dir])
    
    end
end

%% THINK ABOUT INPUT TO DO_CLUSTERING - maybe saving to temporary folder isn't the best way

if sort == 'yes'

    cd(temp_dir)
    fprintf('Executing spike sorting. Go grab a coffee!');
    Do_clustering(spikefiles);

end
