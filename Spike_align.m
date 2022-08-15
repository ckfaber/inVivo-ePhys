%% Spike Alignment
% Prepared by Chelsea Faber

% Requirements:
% - Neural data extracted by PL2_to_Mat_waveclus.m from .pl2 file 
% - Signal Processing Toolbox
% - Chronux package

% Goals:
% - visualize and quantify sorted spikes that respond to the laser
% - visualize and quantify MUA changes in response to the laser

% To do: 
% - huge artifacts in HPF data surrounding optical stims - way to flatten
% line?
% - MUA over time, overlay with raster optical stims
% - spike rates over time for each neuron in each channel, plus averages
% - automate script for all channels/convert to function?

%% 

clear;clc;close all

%% Hard-coding directory and experimental ID

% Copy/paste directory and experimental ID
load_dir                 = 'C:\Users\chels\OneDrive - Barrow Neurological Institute\Project 3 - MUA of DMH\Pilots\Outputs\';  
exp_ID                   = '09172021test2';

% Don't change these 
cd(load_dir)

rawdata_filename              = [exp_ID '.mat'];
highpass_filename             = [exp_ID '_highpass_data.mat'];
lowpass_filename              = [exp_ID '_lowpass_data.mat'];
opto_filename                 = [exp_ID '_opto_stims.mat'];

%% Load data

% Raw neural data
load(rawdata_filename)

n_chan                       = size(data_mat,1);
L                            = size(data_mat,2);
time_base                    = 0 : 1/sr : (L-1)/sr ;

% Opto data
load(opto_filename)                                                 

% High-pass filter 
if exist(highpass_filename,'file') == 2
    
    % Load it if you've already done this to save time
    load(highpass_filename)
    fprintf('Loading high-pass filter data \n')

else
    
    %High-pass filter 
    highpass_threshold      = 250;
    highpass_data           = highpass(data_mat',highpass_threshold,sr)'; % using this for now, flattens baseline better

    save(highpass_filename,'highpass_data'); 

    fprintf("High-pass filtering data using Matlab's high-pass function \n")
    
end

% Low-pass filter
if exist(lowpass_filename,'file') == 2
    
    % Load it if you've already done this to save time
    load(lowpass_filename)
    fprintf('Loading low-pass filter data \n')

else
    
    %Low-pass filter 
    order = 5;
    Fc = 250;                           % cutoff frequency
    [z,p,k] = butter(order,Fc/(sr/2),'low');
    [SOS,G] = zp2sos(z,p,k);            % convert to SOS structure to use filter analysis tool

    lowpass_data = filtfilt(SOS,G,data_mat);
    save(lowpass_filename,'lowpass_data'); 

    fprintf("Low-pass filtering data \n")
    
end

%% Retrieve MUA from output files of Get_Spikes

% Create cell array containing spike indices {1,:}, shapes {2,:}, & thresholds {3,:} from each channel's _spikes.mat file
all_spikes                   = cell(n_chan,3);
for chi = 1:n_chan
    
    temp_filename            = [exp_ID '_ch' num2str(chi) '_spikes'];
    load(temp_filename,'threshold','index','spikes');
    
    all_spikes{chi,1}        = index/1000; % convert ms to s
    all_spikes{chi,2}        = spikes;
    all_spikes{chi,3}        = threshold;

    clear threshold index spikes
    
end

clear temp_filename

%% Retrieve optical stimulation data & compute stimulus epochs
% to do: add overlay of stimulations to plot

% Find time-indices of optical stimulations: 
peak_threshold              = 4.8;                                      %in mV

% Find peak amplitudes and times (in s) of optical stims
[stim_peaks,stim_times]     = findpeaks(data_stim,Fs_stim,'MinPeakHeight',peak_threshold,'Annotate','peaks'); 

n_stims                     = size(stim_times,2);                       % number of optical stimulations
stim_interval               = round(min(diff(stim_times)),2);           % time duration between pulses
stim_hz                     = round(1/stim_interval);                   % calculate stimulation frequency (in Hz) from duration between pulses
    
% Indices
epoch_starts                = [1 (find(diff(stim_times) > 1) + 1)]; % stim data indices
epoch_start_times           = stim_times(epoch_starts);
epoch_start_idx             = round(epoch_start_times * sr); % neural data indices

%epoch_size                 = size(stim_times,2) / size(epoch_starts,2);
%epoch_mid_idx              = epoch_starts + floor(epoch_size/2);

% HPF snippets around stimulus epochs
epoch_window                = 1 * sr; 
epoch_timebase              = -0.2 * epoch_window : 1 * epoch_window - 1;

[epoch_timebase_mat,epoch_start_idx_mat] = meshgrid(epoch_timebase, epoch_start_idx);
epoch_snippets_idx          = epoch_timebase_mat + epoch_start_idx_mat;

% Plot for single channel
ch_to_plot                  = 5;
channel_highpass            = highpass_data(5,:);
channel_epoch_snippets      = channel_highpass(epoch_snippets_idx);

figure
plot(epoch_timebase/sr,channel_epoch_snippets')
xlabel('Time (s)')
ylabel('Voltage (mV)')
title(['High-pass snippets during optical stim, channel ' num2str(ch_to_plot)])
legend('Epoch 1','Epoch 2')
%% Find latencies between stims and spikes

ch_to_plot                  = 5;

% Find times & distances of spikes closest to stims
[k,dist]                    = dsearchn(all_spikes{ch_to_plot,1}',stim_times');            % dsearchn requires column vectors 

channel_responses           = all_spikes{ch_to_plot}(k); % in seconds
channel_response_idx        = round(channel_responses*sr); % neural data indices

% to do: index/plot all waveforms near optical stimulation - see if they are successfully sorted by
% wave_clus

%% Firing rate - right now for MUA, need to update for sorted neurons later

% Mean MUA firing rates over recording session
MUA_mean_fr                 = zeros(n_chan,1);

for chi = 1:n_chan
    
    temp_idx                = all_spikes{chi,1};
    MUA_mean_fr(chi)        = length(temp_idx) / (temp_idx(end) - temp_idx(1));

end

% Binned FR by channel
binwidth                    = 1;                                        % in seconds
edges                       = 0 : binwidth: L/sr ;                      % vector containing bin edges in time (s)
MUA_fr_bins                 = zeros(n_chan,length(edges)-1);            % initialize matrix

for chi = 1:n_chan

    MUA_fr_bins(chi,:)      = histcounts(all_spikes{chi,1},edges) / binwidth;

end

%% Plot Firing Rates for all channels...

% figure;
% sgtitle(['Multi-unit firing rates'])        % title for grid of subplots
% 
% for m = 1:n_chan
% 
%     % Create grid of subplots
%     mua(m) = subplot(sqrt(n_chan),sqrt(n_chan),m);
% 
%     % 
%     plot(edges(1:end-1),MUA_fr_bins(m,:),'k','Linewidth',1);
%     hold on;
%     yline(MUA_mean_fr(m),'r--','Linewidth',1);
% 
%     xlim([0 edges(end)]);
%     ylabel('Hz');
%     xlabel('Time (s)');
%     t = title(['Channel ' num2str(m)]);
%     t.FontSize = 10;
%     t.FontWeight = 'normal';
% 
% end
% 
% linkaxes(mua)

%% ...or just for one:

ch_to_plot = 5;

figure;clf
subplot(211)
plot(edges(1:end-1),MUA_fr_bins(ch_to_plot,:),'k','Linewidth',1)
title(['MUA firing rate from channel ' num2str(ch_to_plot)])
hold on
yline(MUA_mean_fr(ch_to_plot),'r--','Linewidth',1)
h = stem(stim_times,repmat(20,size(stim_times,2),1)','Marker','none','Color',[0 0.4470 0.7410],'LineWidth',0.5);
xlabel('Time (s)'); ylabel('Firing Rate (Hz)')
legend('','Mean FR',[num2str(stim_hz) ' Hz Stimulation'])

subplot(212)
plot(time_base,highpass_data(ch_to_plot,:),'Color',[.2 .2 .2])
hold on
yline(all_spikes{ch_to_plot,3},'r-','LineWidth',1)
h = stem(stim_times,repmat(-0.3,size(stim_times,2),1)','Marker','none','Color',[0 0.4470 0.7410],'LineWidth',0.5,'BaseValue',-0.4);
xlabel('Time (s)')
ylabel('Voltage (mV)')
title(['High-pass filtered data from channel ' num2str(ch_to_plot)])
legend('','Spike threshold',[num2str(stim_hz) ' Hz Stimulation'])

%% Plot AP snippets

AP_samples                  = size(all_spikes{ch_to_plot,2},2);
AP_timebase                 = round(-0.5*AP_samples:0.5*AP_samples-1) / sr; 

figure;
plot(AP_timebase,all_spikes{ch_to_plot,2},'-o') 
ylabel('Voltage (mV)');
xlabel('Time (\mus)');
title(['Spike waveforms from channel ' num2str(ch_to_plot)])

%% Plot High-Pass filtered data for all channels

% figure;
% sgtitle(['High-Pass at ' num2str(highpass_threshold) ' Hz'])        % title for grid of subplots
% 
% for m = 1:n_chan
% 
%     % Create grid of subplots
%     hsp(m) = subplot(sqrt(n_chan),sqrt(n_chan),m);
% 
%     % Plot channels over time
%     plot(time_base,highpass_data(m,:),'k','LineWidth',0.5,'Color',[0.0 0.45 0.75]);
%     hold on;
% 
%     % Plot voltage threshold for each channel (from Get_spikes.m)
%     yline(spike_thresholds(m),'k--','LineWidth',1) 
% 
%     % Plot optical stimulations
%     %plot(time_basis_stim,data_stim,'r','LineWidth',0.5,'Color',[0.85 0.32 0.01]);
%     
%     % Make prettier
%     xlim([0 time_base(end)]);
%     ylabel('mV');
%     xlabel('Seconds');
%     t = title(['Channel = ' num2str(m)]);
%     t.FontSize = 10;
%     t.FontWeight = 'normal';
% 
%     if m == 1
%         legend('Neural','Threshold');
%     end
% 
%     drawnow;
% end
% linkaxes(hsp);

%% Plot spectrogram

% to do: learn more about multi-taper parameters - seeing spectral leaking into
% higher frequencies

ch_to_plot = 5;

% Set up multitaper parameters (affects how smooth/precise frequency power is estimated in short-time FFT) 
params.tapers               = [5 9]; 
params.pad                  = 2; % padding to next highest power of 2 for computation efficiency
params.Fs                   = sr;
params.fpass                = [0 100]; % frequency band - min and max  
params.trialave             = 0;
params.err                  = 0;

movingwin                   = [0.250 0.025];

% Run and plot
[Slfp,tlfp,flfp]            = mtspecgramc(lowpass_data(ch_to_plot,:)',movingwin,params);

figure
subplot(211)
plot(time_base,lowpass_data(ch_to_plot,:),'Color',[.2 .2 .2])
title(['LFP from channel ' num2str(ch_to_plot)])
xlabel('Time (s)')
ylabel('mV')
xline([stim_times(1),stim_times(10)],'b--','Linew',2)

subplot(212)
imagesc(tlfp,flfp,10*log10(Slfp)');
axis xy; % plots low frequencies at bottom
caxis([-100 -20])
title('Spectrogram')
xlabel('Time (s)')
ylabel('Frequency (Hz)')
h = colorbar;
h.Label.String = 'Power';
xline([stim_times(1),stim_times(10)],'b--','Linew',2)

%% Load in sorted spikes 

load times_09172021test2_ch5.mat                     % wave_clus output file

%% What channel are the sorted spikes from? 
% need to figure out how to extract this from the times.mat file that has
% ch5 in the name already - don't want to hard code every time

channel        = 5;


%% Create cell array containing all sorted spike times for channel

cluster_class           = [cluster_class cluster_class(:,2).*sr];   % add column with indices of spikes, from time
neurons                 = unique(cluster_class(:,1));               % number of unique neuron clusters in channel

All_neurons             = cell(length(neurons),1);                  % preallocate cell array
for j = 1:length(neurons)    
 
    neuron_idx          = find(cluster_class(:,1) == (j-1));        % find indices for sorted neurons
    All_neurons{j}      = cluster_class(neuron_idx,:);              % store spike times in All_neurons
    
end 
