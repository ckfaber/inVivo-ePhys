% Spectral analysis
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

[file,path] = uigetfile('*.mat');
export = true; % set to true or false for exporting graphics to new subfolder

%% 1) Load broadband data

load([path file],'data','sr','pl2idx')


%% 

savename    = strsplit(file,'.');
savename    = char(savename(1));

newdir = savename;

savedir = [path newdir];

if exist(savedir) == 7
    fprintf(['Directory ' newdir ' exists\n'])
else
    fprintf(['Directory ' newdir ' does not exist\n'])
    mkdir(savedir)
    fprintf(['New directory ' newdir ' created.\n'])
end

%% 2) Quick vis raw data - full recording

% Parameters for plotting
[nChan,nPts] = size(data);
timebase    = 0 : 1/sr : (nPts - 1)/sr;

figure
for chi = 1:nChan
    subplot(4,4,chi)
    plot(timebase,data(chi,:),'Color',[0.2 0.2 0.2])
    xlabel('Time (s)')
    ylabel('Voltage (mV)')
    title(['Channel ' num2str(chi)])
    set(gca,'color','none')
end
sgtitle({'Broadband data',strrep(savename,'_','\_')})

% Export figure
set(gcf,'color','none')
exportgraphics(gcf,[savedir '\' savename '_BB-full.pdf'],'BackgroundColor','none','ContentType','vector')

%% 3) Quick vis raw data - snippet

% Select parameters for figures 
chtoplot    = 4;
swin        = 4; % in seconds, size of random broadband snippet to plot

% Random generation of snippet window
winsize     = swin*sr;
t1 = 

% Individual channel
figure
plot(timebase(1:tidx),data(chtoplot,1:tidx))
xlabel("Seconds")
ylabel("Voltage (mV)")
title(['Channel ' num2str(chtoplot) ' broadband trace'])

% All channels
figure
for chi = 1:nChan
    subplot(4,4,chi)
    plot(timebase(1:tidx))

%% 3) Quick discrete FFT

% Time-domain averaged data
ERP = mean(data,1);

% FFT
f = fft(ERP);
f = f/nPts;

% Frequency vector
hz = linspace(0,sr,nPts);
nyquist = sr/2;

% Amplitudes
amps = 2*abs(f);

% Plot
frexidx = dsearchn(hz',25);
plot(hz(1:frexidx),amps(1:frexidx),Color=[0.2 0.2 0.2])
axis tight
xlabel('Hz')
ylabel('Amplitude')
title('DFFT')


%% Filter 
% low pass filter from Bradley

order = 3;
Rp = 1; % pass-band ripple in db
Rs = 60; % stop-band attenuation in db
Fc = 250; % cutoff frequency - 250 Hz will remove most low frequency LFP %this doesn't make sense? Will remove high frequency?
Fs = sr; % sampling frequency of data (the specific Fs should be in the data file)
[z,p,k] = ellip(order,Rp,Rs,Fc/(Fs/2),'low'); % building (setup) filter
% [z,p,k] = butter(order,Fc/(Fs/2),'high'); % butterworth filter
[SOS,G] = zp2sos(z,p,k);% convert to SOS structure to use filter analysis tool
% tool to look at filter
% fvtool(SOS);
tic;
lfp = filtfilt(SOS,G,data); %running filter
toc

%% Spectrogram

