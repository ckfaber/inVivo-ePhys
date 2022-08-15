%% Spike_detect

%    - Automate spike sorting with wave_clus --> how to set default
%    settings but be able to go back and manually sort after? 

%    - combine sorted spikes into matrix --> ID optical responders &
%    standardize metric/doc

%% Prepare for spike detection

% Save each channel as separate .mat for Get_spikes
% data = data_mat(k,:);
% save([file_name '_ch' num2str(k) '.mat'],'data','sr') % save raw broadband data for each channel as .mat

% Create cell array containing all filenames for Get_spikes
% txt                     = [file_name '_ch' num2str(k+2) '.mat'];
% save(txt,'data','sr') % save raw broadband data for each channel as .mat
% batch_txt{k+2}           = txt;
% 
% 
% batch_txt = what; batch_txt = batch_txt.mat;
% batch_input = [file_name '_batch.txt'];
% writecell(batch_txt,batch_input);  % save txt file with names of each .mat file for broadband data

%% Spike detection
Get_spikes(batch_input);

% set parameters for automated spike sorting:
param.min_clus              = 20;
param.max_spk               = 50000;
par.maxtemp                 = 0.251;
set(0, 'DefaultFigureWindowStyle', 'normal');
Do_clustering('09172021test2_ch5_spikes.mat'); % test file for now; use 'all' to run all files in current directory

