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

filename   = '2022-08-16_dmu005_001.mat';

%% Load broadband data

load_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Extracted\');
load([load_dir filename],'data','sr','pl2idx')

save_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\CLF\Projects\dmu\Pilots\dmu005_NeuroNexus_Pilot\');

%% Filter 

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

%% Downsample LFPs

r                   = 10;                                     % down-sampling factor

L                   = size(lfp,2);
time                = 0 : 1/sr : (L-1)/sr ;                   % time base
downlfp             = zeros(size(lfp,1), size(lfp,2)/r);
for i = 1:size(lfp,1)

    downlfp(i,:) = decimate(lfp(i,:),r);

end
time                = decimate(time,r);


%% Plot down-sampled LFPs

start                   = 60;
stop                    = 70;
[startval,startidx]     =min(abs(time - start));
[stopval,stopidx]       =min(abs(time - stop));

gridsize = size(downlfp,1);

figure;
sgtitle('Low-Pass at 150 Hz')
for m = 1:gridsize
    % plot results
    hsp(m) = subplot(sqrt(gridsize),sqrt(gridsize),m);
    plot(time(startidx:stopidx),downlfp(m,startidx:stopidx),'k','LineWidth',0.5,'Color',[0.0 0.45 0.75]);
    hold on;
    xlim([time(startidx) time(stopidx)]);
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

%% Spectrogram (copy/pasted from bottom of Spike_align.m on 10/26/22

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
