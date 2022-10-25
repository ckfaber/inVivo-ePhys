% Some simple MUA analyses

% to do: 
% - add way to retrieve experimental metadata to all analysis scripts
% - e.g. length of recording, time of day, etc

filename    = '2022-10-13_dmu005_002_MUA';
path        = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Processed\',filename);

load(path)

filename    = '2022-10-13_dmu005_002';
raw_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Extracted\',filename);
load(raw_dir)

%% Firing rate

% Mean MUA firing rates over recording session
chanNames                   = fieldnames(spikes);
nChan                       = length(fieldnames(spikes));
MUA_mean_fr                 = zeros(nChan,1);

for chi = 1:nChan

    idx                     = chanNames{chi};
    spiketimes              = spikes.(idx).index .* 1000;               % convert ms to s
    MUA_mean_fr(chi)        = length(spiketimes) / (spiketimes(end) - spiketimes(1));

end

% Binned FR by channel
binwidth                    = 1;                                        % in seconds
edges                       = 0 : binwidth: L/sr ;                      % vector containing bin edges in time (s)
MUA_fr_bins                 = zeros(nNeuralChan,length(edges)-1);       % initialize matrix

for chi = 1:nNeuralChan

    MUA_fr_bins(chi,:)      = histcounts(all_spikes{chi,1},edges) / binwidth;

end

%% MUA FR plot

