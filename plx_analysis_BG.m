%% WIP script for reading in .pl2 files from Plexon electrophysiology system
% 
% Prepared by: Chelsea Faber, Bradley Greger
% 
% Reqs: 
% - Plexon Offline SDK: https://plexon.com/software-downloads/#software-downloads-SDKs
% - Chronux: 
% - wave_clus: 
% - Signal Processing Toolbox

clear;
clc;

%% To-do: 

%    - quick time-frequency spectra?

%    - spike sorting with wave_clus

%    - standardize identification of spikes responding to optical stims -
%    set criteria for responders vs. non-responders

%    - tidy data procedure to automate data down-sampling, filtering,
%   epoc-alignment, spike extraction, etc. based upon pre-defined
%   procedure/parameter saved in ExperimentLog file.
%        - update data directory so all .pl2 files are in common folder
%        - implement consistent naming convention for all experimental data
%    files

%% Set data loading/saving directories

load_dir = 'C:\Users\chels\OneDrive - Barrow Neurological Institute\Data_Raw\InVivo_Ephys\';
file_name = '09172021test2';
ext = '.pl2';

load_path = [load_dir file_name ext];
%[file,path] = uigetfile('*.pl2');
%file_name = [path file];

%save_dir = 'C:\Users\cfaber\OneDrive - Barrow Neurological Institute\Project 3 - MUA of DMH\Pilots\Outputs\';                                 % where to save pre-processed  data
%save_folder = ['']
%% Load data into matrix

[nChan,sampCounts] = plx_adchan_samplecounts(load_path);
L = sampCounts(1);
number_of_channels = 16;
raw_data = zeros(number_of_channels,L);         % initialize data matrix

for k = 0:number_of_channels-1
    [adfreq, n, ts, fn, ad] = plx_ad_v(load_path, k);
    raw_data(k+1,:) = ad;
end

Fs = adfreq;                                    % sampling frequency
L = size(raw_data,2);                           % length of signal
time_basis = 0:1/Fs:(L-1)/Fs;                   % time base

%save([file_name '.mat'],'raw_data');            % save raw broadband data as .mat

%% Load optical stimulation data

[adfreq, n, ts, fn, data_stim] = plx_ad_v(load_path, 'AI01');

% scale stimulation data to volts
data_stim = (data_stim/max(data_stim)*0.050)';  % don't think this is correct, fix
Fs_stim = adfreq;                               % sampling frequency
L = size(data_stim,2);                          % length of signal
time_basis_stim = 0:1/Fs_stim:(L-1)/Fs_stim;    % time base

save([file_name 'opto_stims' '.mat'],'data_stim','Fs_stim','L','time_basis_stim'); 

%% FFT of 1st neural channel:

nPts = length(raw_data(1,:));
fCoefs = fft(raw_data(1,:))/nPts; % fast fourier, normalized

% extract the frequencies:
hz = linspace(0,Fs/2,floor(nPts/2)+1);
ampl = 2*abs(fCoefs(1:length(hz)));

figure(1), clf
stem(hz,ampl,'ks-','linew',1,'markersize',3,'markerfacecolor','w')
set(gca,'xlim',[0 20])
xlabel('Frequency (Hz)'), ylabel('Amplitude (a.u.)')

%% high-pass filter data
sr = Fs; 
order = 3;
Rp = 1;                             % pass-band ripple in db
Rs = 60;                            % stop-band attenuation in db
Fc = 250;                           % cutoff frequency
[z,p,k] = ellip(order,Rp,Rs,Fc/(sr/2),'high');
[SOS,G] = zp2sos(z,p,k);            % convert to SOS structure to use filter analysis tool

data_hp_filt = filtfilt(SOS,G,raw_data);

%% plot one channel of data and stimulation data

channel = 16;                        % channel 5 has good APs

figure; 
hp1 = plot(time_basis,data_hp_filt(channel,:),'LineWidth',0.5); 
hp1.Color = [0.0 0.45 0.75];
hold on
hp2 = plot(time_basis_stim,data_stim,'LineWidth',0.5);
hp2.Color = [0.85 0.32 0.01];
xlim([0 time_basis(end)])
ylabel('mV');
xlabel('Seconds');
title(['High-Pass Data, Channel: ' num2str(channel)])
legend('Neural','Stimulation');


%% low-pass filter data
% higher the order, the more rigorous the filter is. 

order = 5;
Fc = 250;                           % cutoff frequency
[z,p,k] = butter(order,Fc/(Fs/2),'low');
[SOS,G] = zp2sos(z,p,k);            % convert to SOS structure to use filter analysis tool

data_lp_filt = filtfilt(SOS,G,raw_data);

%% plot all channels of low-pass data

grid_size = 16;

figure;
sgtitle('Low-Pass at 150 Hz')
for m = 1:grid_size
    % plot results
    hsp(m) = subplot(sqrt(grid_size),sqrt(grid_size),m);
    plot(time_basis,data_lp_filt(m,:),'k','LineWidth',0.5,'Color',[0.0 0.45 0.75]);
    hold on;
    plot(time_basis_stim,data_stim,'r','LineWidth',0.5,'Color',[0.85 0.32 0.01]);
    xlim([0 time_basis(end)]);
    ylabel('Volts');
    xlabel('Seconds');
    t = title(['Channel = ' num2str(m)]);
    t.FontSize = 10;
    t.FontWeight = 'normal';

    if m == 1
        legend('Neural','Stimulation');
    end

    drawnow;  
end
linkaxes(hsp);

%% Cross Correlation between two channels
channel1 = 5;
channel2 = 9;

figure;
sgtitle(['Cross-correlation between channels ' num2str(channel1) ' and ' num2str(channel2)])

[c,lags] = xcorr(data_lp_filt(channel1,:),data_lp_filt(channel2,:),'normalized');
lags_time = lags*(1/Fs);
subplot(1,2,1)
plot(lags_time,c)
axis([-4 4 -1 1])
title('LFPs: Low-pass filtered')
ylabel('Correlation');
xlabel('Seconds');

subplot(1,2,2)
[c,lags] = xcorr(data_hp_filt(channel1,:),data_hp_filt(channel2,:),'normalized');
plot(lags_time,c)
axis([-4 4 -1 1])
title('APs: High-pass filtered')
ylabel('Correlation');
xlabel('Seconds');
