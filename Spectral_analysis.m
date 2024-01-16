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

filename1   = '2023-05-25_dmu006_001.mat';

%% 1) Load broadband data

load_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Extracted\');
load([load_dir filename1],'data','sr','pl2idx')

%% 2) Quick vis raw data

nPts        = size(data,2);
timebase    = 0 : 1/sr : (nPts - 1)/sr;
chtoplot    = 1;

plot(timebase(1:160000),data(chtoplot,1:160000))
xlabel("Seconds")
ylabel("Voltage (mV)")
title(['Channel ' num2str(chtoplot) ' broadband trace'])

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
frexidx = dsearchn(hz',30);
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

