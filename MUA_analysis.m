% Some simple MUA analyses

% to do: 
% - add way to retrieve experimental metadata to all analysis scripts
% - e.g. length of recording, time of day, etc

filename    = '2023-04-12_dmu006_003_MUA';
path        = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Processed\',filename);

load(path)

filename    = '2023-04-12_dmu006_003';
raw_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Extracted\',filename);
load(raw_dir)

%% Firing rate
% 
% % Mean MUA firing rates over recording session
% chanNames                   = fieldnames(spikes);
% nChan                       = length(fieldnames(spikes));
% MUA_mean_fr                 = zeros(nChan,1);
% 
% for chi = 1:nChan
% 
%     idx                     = chanNames{chi};
%     spiketimes              = spikes.(idx).index .* 1000;               % convert ms to s
%     MUA_mean_fr(chi)        = length(spiketimes) / (spiketimes(end) - spiketimes(1));
% 
% end
% 
% % Binned FR by channel
% binwidth                    = 10;                                        % in seconds
% edges                       = 0 : binwidth: L/sr ;                      % vector containing bin edges in time (s)
% MUA_fr_bins                 = zeros(nChan,length(edges)-1);       % initialize matrix
% 
% for chi = 1:nChan
% 
%     MUA_fr_bins(chi,:)      = histcounts(all_spikes{chi,1},edges) / binwidth;
% 
% end

%% MUA FR plot - TEST CH1

times1 = spikes.ch14.index ./ 1000; % convert ms to s

avg_fr = length(times1)/(times1(end)-times1(1));
isi = diff(times1) .* 1000;

binwidth = 5; % seconds
edges = [0:binwidth:(times1(end) + binwidth)];
fr_bins = histcounts(times1,edges)/binwidth;

figure;
plot(edges(1:end-1),fr_bins,'k'); % ,'LineWidth',1.5
title(['Firing Rate Ch14']);
xlabel('Time (s)');
ylabel('Firing Rate (Hz)');