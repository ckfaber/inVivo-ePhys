% Spectral analysis

% adding test line

% Playground for developing spectral analysis pipeline
% 
% Basic workflow:
% 
% - Low-pass filter OR band-pass filter (hypothesis-dependent)
% - SSE on requested vs actual filter
% - Quick vis for quality control
% 
% Consider when to use:
% 
% - Cross-correlograms of channel similarity
% - Power spectrum over time - complex morlet vs multitaper vs
%   filter-hilbert
% - LFP snippets around user-requested epoch (spikes, behavioral events, etc)
% - frequency band power during behavioral epochs (see Korotkova 2017)

% INPUTS
%   filename: name of .mat containing matrix of broadband neural data (output from
%             PL2_to_Mat())
%   
%   [filter type & parameters] - name:value pairs? think through best way
%             to do this
%
%   savepath: path to project directory in which to save?
%
% OUTPUTS

%% Hard-code file name

filename   = '2022-10-13_dmu005_001.mat';
meta        = split(filename,{'_','.'});
date        = char(meta(1));
subject     = char(meta(2));
session     = char(meta(3));

%% Load broadband data

load_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Extracted\');
load([load_dir filename],'data','sr','pl2idx')

save_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\CLF\Projects\dmu\Pilots\dmu005_NeuroNexus_Pilot\');

%% Elliptical low pass filter (from Bradley)

order = 3;
Rp = 1; % pass-band ripple in db
Rs = 60; % stop-band attenuation in db
Fc = 150; % cutoff frequency - 250 Hz will remove most low frequency LFP %this doesn't make sense? Will remove high frequency?
[z,p,k] = ellip(order,Rp,Rs,Fc/(sr/2),'low'); % building (setup) filter
% [z,p,k] = butter(order,Fc/(Fs/2),'high'); % butterworth filter
[SOS,G] = zp2sos(z,p,k);% convert to SOS structure to use filter analysis tool
% tool to look at filter
% fvtool(SOS);
tic;
lfp = filtfilt(SOS,G,data); %running filter
toc

%% Downsampling
r                   = sr/1250;                                % down-sampling factor to get to 1250-Hz (see Tingley et al, Nature 2021)
L                   = size(lfp,2);
time                = 0 : 1/sr : (L-1)/sr ;                   % time base

% fix issue where L/r is not an even number

downlfp             = zeros(size(lfp,1), ceil(L/r));
for i = 1:size(lfp,1)

    downlfp(i,:) = decimate(lfp(i,:),r);

end
downtime            = decimate(time,r);
%% Spectrogram

% data must be in time x channels
if size(data,1) < size(data,2) 
    data = data';
end

% set parameters for spectrogram: param structure with fields tapers, pad, Fs, fpass, err, trialave
params.tapers       = [3 5];            % default
params.pad          = -1;               % default, zero-padding data length to next power of 2 for computing efficiency 
params.Fs           = sr;               % pull from raw data
params.fpass        = [0 sr/400];       % range of frequencies supplied in output - 0 to nyquist default
params.err          = 0;                % default 0 for no error bars; 1 for theoretical error bars, 2 for jackknife
params.trialave     = 0;                % default 0 for no averaging by channel or by trial

winsize             = 1;
winstep             = 0.5;

% on unfiltered data
ch1                          = data(:,1);
[rawspec,rawtimes,rawfrex]   = mtspecgramc(ch1,[winsize winstep],params);

figure
subplot(211)
plot(downtime,downlfp(1,:),'k');
axis tight
xlabel('Time (s)')
ylabel('Voltage (mV)')
title('Channel 1 LFP')
subtitle(['Downsampled to 1250-Hz'])

subplot(212)
imagesc(rawtimes,rawfrex,10*log10(rawspec)'); 
axis xy; 
c = colorbar; c.Label.String = 'Power'
xlabel('Time (s)')
ylabel('Frequency (Hz)')
title(['Channel 1 spectrogram'])
%subtitle(['Subject ' subject ' on ' date])

% Export figure
cd(save_dir)
set(gca,'color','none')
exportgraphics(gcf,[date subject session '_spectrogram.emf'],'BackgroundColor','none','ContentType','vector')

%% Plot down-sampled LFPs

start                   = 10;
stop                    = 12;
[startval,startidx]     =min(abs(downtime - start));
[stopval,stopidx]       =min(abs(downtime - stop));

% One Channel only
ch_to_plot = 1;
figure
plot(downtime(startidx:stopidx),downlfp(ch_to_plot,startidx:stopidx),'k');
axis tight
xlabel('Time (s)')
ylabel('Voltage (mV)')
title(['Channel ' num2str(ch_to_plot) ' LFP snippet (150-Hz)'])
set(gca,'color','none')
exportgraphics(gcf,[filename 'LFP-snippet-3.emf'],'BackgroundColor','none','ContentType','vector')

% All channels overlaid
figure;
for f = 1:size(downlfp,1)
    plot(downtime(startidx:stopidx), downlfp(f,startidx:stopidx))
    hold on
    xlim([downtime(startidx) downtime(stopidx)])
end


% All channels in subplots
gridsize = size(downlfp,1);
figure;
sgtitle('Low-Pass at 150 Hz')
for m = 1:gridsize
    % plot results
    hsp(m) = subplot(sqrt(gridsize),sqrt(gridsize),m);
    plot(downtime(startidx:stopidx),downlfp(m,startidx:stopidx),'k','LineWidth',0.5);
    hold on;
    xlim([downtime(startidx) downtime(stopidx)]);
%     ylabel('Volts');
%     xlabel('Seconds');
    t = title(['Channel ' num2str(m)]);
    t.FontSize = 10;
    t.FontWeight = 'normal';

    set(gca,'color','none')
    drawnow;  
end
linkaxes(hsp);

cd(save_dir)
exportgraphics(gcf,[filename 'LFP.emf'],'BackgroundColor','none','ContentType','vector')

%% Cross-correlation

channel1 = 5;
channel2 = 9;

figure;
[c,lags] = xcorr(downlfp(channel1,:),downlfp(channel2,:),'normalized');
lags_time = lags*(1/sr);
plot(lags_time,c,'k-')
axis([-4 4 -1 1])
ylabel('Correlation');
xlabel('Seconds');
title(['Cross-correlation between channels ' num2str(channel1) ' and ' num2str(channel2)])


% subplot(1,2,2)
% [c,lags] = xcorr(data_hp_filt(channel1,:),data_hp_filt(channel2,:),'normalized');
% plot(lags_time,c)
% axis([-4 4 -1 1])
% title('APs: High-pass filtered')
% ylabel('Correlation');
% xlabel('Seconds');

%% Spectrogram (copy/pasted from bottom of Spike_align.m on 10/26/22

% ch_to_plot = 5;
% 
% % Set up multitaper parameters (affects how smooth/precise frequency power is estimated in short-time FFT) 
% params.tapers               = [5 9]; 
% params.pad                  = 2; % padding to next highest power of 2 for computation efficiency
% params.Fs                   = sr;
% params.fpass                = [0 100]; % frequency band - min and max  
% params.trialave             = 0;
% params.err                  = 0;
% 
% movingwin                   = [0.250 0.025];
% 
% % Run and plot
% [Slfp,tlfp,flfp]            = mtspecgramc(lowpass_data(ch_to_plot,:)',movingwin,params);
% 
% figure
% subplot(211)
% plot(time_base,lowpass_data(ch_to_plot,:),'Color',[.2 .2 .2])
% title(['LFP from channel ' num2str(ch_to_plot)])
% xlabel('Time (s)')
% ylabel('mV')
% xline([stim_times(1),stim_times(10)],'b--','Linew',2)
% 
% subplot(212)
% imagesc(tlfp,flfp,10*log10(Slfp)');
% axis xy; % plots low frequencies at bottom
% caxis([-100 -20])
% title('Spectrogram')
% xlabel('Time (s)')
% ylabel('Frequency (Hz)')
% h = colorbar;
% h.Label.String = 'Power';
% xline([stim_times(1),stim_times(10)],'b--','Linew',2)
