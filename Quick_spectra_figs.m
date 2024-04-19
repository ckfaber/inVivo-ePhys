function Quick_spectra_figs(fname,path,export,ftype,ctype)
% Generates plots for manual inspection of data before more detailed
% processing.
%
% FINISH THIS DOCUMENTATION: 
% 
% INPUTS
%   fname: name of *LFP.mat containing:
%          - LFP: channel x time matrix of low-pass filtered, common-median
%                 referenced, mean-centered, and down-sampled data (see lowpass_down.m)
%          - downsr: downsampled sampling rate in Hz
%          - downtime: downsampled timebase, in seconds
%          - 
%   
%
%   savepath: path to project directory in which to save?
%
% OUTPUTS
% 
%% 1) Load LFP data

% Files
filename    = fname;
filepath    = [path filename];
fileparts   = strsplit(filename,'.');
fileparts   = strsplit(fileparts{1},'_');

savename    = strjoin(fileparts(1:3),{'_','_'});
savedir     = [path strjoin(fileparts(1:2),{'_'})];

load(filepath)

%% Figure 1: LFP
%
% Generates figure with nChan subplots for each channel's full recording
% span

sr = downsr;
time = downtime;
[nChan,nPts] = size(LFP);

% All channels separate
f1 = figure(1)
t = tiledlayout(4,4,'TileSpacing','tight');
for chi = 1:nChan
    nexttile % only works for 16-channels, revise as needed
    plot(time,LFP(chi,:),'Color',[0.2 0.2 0.2])
    axis tight
    title(['Channel ' num2str(chi)])
    set(gca,'color','none','box','off','TickDir','out','YMinorTick','on','XMinorTick','on')
end
title(t,'LFP','FontSize',12)
subtitle(t,'250-Hz; CMR and Mean-Centered','FontSize',10)
xlabel(t,"Time (s)")
ylabel(t,"Voltage (mV)")

%% Figure 2: LFP-overlaid
% 
% All channels overlaid (with nudged y-axis) in one figure
figure(2)
for chi = 1:nChan
    nudge = chi-1;
    plot(time,LFP(chi,:)+0.3*nudge,'linew',1);
    hold on
end
f2=gca;
f2.YAxis.Visible ="off"
f2.XAxis.FontSize = 8
annotation('rectangle',[0 0 1 1],'Color','w');
axis tight
set(f2,'color','none','box','off','TickDir','out')
lg = legend('Ch.1','Ch.2','Ch.3','Ch.4', ...
    'Ch.5','Ch.6.','Ch.7','Ch.8', ...
    'Ch.9','Ch.10','Ch.11','Ch.12', ...
    'Ch.13','Ch.14','Ch.15','Ch.16');
lg.Orientation = "vertical";
lg.NumColumns = 4;
lg.Location = "southoutside";
lg.Box = "off";
lg.FontSize = 8;
xlabel('Time (s)','FontSize',8);
title('LFP','FontSize',12);
subtitle('250-Hz; CMR and Mean-Centered','FontSize',10);

%% Figure 3: LFP-overlaid-snip
% 
% Randomly selected x-s window overlaid LFP for all channels
winL = 2; % in seconds

% Trim LFPs (randomize window selection)
t1 = randi([0 floor(time(end))-winL]);
t2 = t1+winL;
tidx = dsearchn(time',[t1;t2]);

figure(3),clf
for chi = 1:nChan
    nudge = chi-1;
    plot(time(tidx(1):tidx(2)),(LFP(chi,tidx(1):tidx(2))+0.05*nudge),'linew',1);
    hold on
end

f3=gca;
f3.YAxis.Visible ="off"
f3.XAxis.FontSize = 8

x1 = floor(f3.XLim(1));
x2 = floor(f3.XLim(2))-1;
x3 = x2+1;

xticks([x1 x2 x3])
xticklabels({0,1,2})
xlabel('Time (s)','FontSize',10,'FontWeight','bold')

annotation('rectangle',[0 0 1 1],'Color','w');
axis tight
set(f3,'color','none','box','off','TickDir','out')
title('LFP snippet')
subtitle(['(' num2str(x1) '-' num2str(x3) 's)'],'FontSize',10)

lg = legend('Ch.1','Ch.2','Ch.3','Ch.4', ...
    'Ch.5','Ch.6.','Ch.7','Ch.8', ...
    'Ch.9','Ch.10','Ch.11','Ch.12', ...
    'Ch.13','Ch.14','Ch.15','Ch.16');
lg.Orientation = "vertical";
lg.NumColumns = 4;
lg.Location = "southoutside";
lg.Box = "off";
lg.FontSize = 8;

%% Figure 4: Power spectra

params.tapers = [5 9]; % 
params.Fs = downsr; % sampling rate

[powers,frex] = mtspectrumc(LFP',params); % data must be in matrix time x channels/trials
powers = powers';

params.trialave = 1;
[avgpower,avgfrex] = mtspectrumc(LFP',params);

figure(4)
f4 = tiledlayout(4,4,"TileSpacing","tight")

for chi = 1:nChan
    nexttile
    plot(frex,avgpower,'Color',[0.2 0.2 0.2])
    alpha(0.5)
    hold on
    plot(frex,powers(chi,:),'r')
    xlim([0 10])
    title(['Ch.' num2str(chi)])
    xlabel('Frequency (Hz)')
    ylabel('Power')
end

title(f4,'Discrete Power Spectra','FontWeight','bold')
subtitle(f4,'mtspectrumc multitaper estimate [5 9]','FontSize',10)
lg = legend({'Average Power','Channel Power'},'Orientation','horizontal')
lg.Layout.Tile = 'South';


%% Figure 5: Channel Spectrograms

params.trialave = 0;
[spec,t,frex] = mtspecgramc(LFP',[1 0.75],params);

figure(5)

fidx = dsearchn(frex',100);

figure(5)
f5 = tiledlayout(4,4,'TileSpacing','none')
for chi = 1:nChan
    nexttile
    imagesc(t,frex(1:fidx),10*log10(spec(:,1:fidx,chi))')
    axis xy
    title(['Ch. ' num2str(chi)])
end

xlabel(f5,'Time (s)')
ylabel(f5,'Frequency (Hz)')
title(f5,'Spectrograms by Channel','FontWeight','bold')
subtitle(f5,'mtspecgramc; [5 9] tapers, [1 0.75] movingwin')

%% Figure 6: Average Spectrogram

params.trialave = 1;
[specavg,t,frex] = mtspecgramc(LFP',[1 0.75],params);

figure(6)
imagesc(t,frex(1:fidx),10*log10(specavg(:,1:fidx))')
axis xy
title('Channel-Averaged Spectrogram')
c = colorbar;
c.Label.String = 'Power (dB)';
xlabel('Time (s)')
ylabel('Frequency (Hz)')
subtitle(strrep(savename,'_','\_'),'FontSize',10)
annotation('rectangle',[0 0 1 1],'Color','w');
f6 = gca;
set(f6,'color','none','box','off','TickDir','out')

%% Figure 7: Spectrum

ERP = mean(LFP,1);

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

%% Figure 8: Spectrum w/ Welch's Correction

win     = 2 * sr; % in points
nbins   = floor(nPts / win);

% new vector of frequencies for 2s windows
hzW     = linspace(0, sr, win);

% initialize time-frequency matrix
welch = zeros(1,length(hzW));

% Hann taper - OPTIONAL
hwin = .5*(1-cos(2*pi*(1:win) / (win-1)));

% loop over time windows
for ti = 1 : nbins

    % extract signal window
    tidx = (ti-1) * win + 1 : ti * win;
    tmp = ERP(tidx);

    % FFT
    x = fft(hwin .* tmp) / win;

    % append to matrix
    welch = welch + 2 * abs(x(1 : length(hzW)));

end 

welch = welch / nbins;

frexidx = dsearchn(hzW',30);

figure,clf
plot(hzW(1:frexidx),welch(1:frexidx),'k','linew',2)
axis tight
xlabel('Hz')
ylabel('Amplitude')
title("Welch's FFT")
subtitle("2s window")

%% Export

if export
    fprintf('Preparing to export figures\n')

    % Check whether repo exists
    if exist(savedir) ~=7
        fprintf(['Creating new repository for figures: \n' strrep(savedir,'\','\\') '\n'])
        mkdir(savedir)  
    end
    
    % Export
    exportgraphics(f1,[savedir '\' savename '_LFP' ftype],'BackgroundColor','none','ContentType',ctype)
    exportgraphics(f2,[savedir '\' savename '_LFP-overlay' ftype],'BackgroundColor','none','ContentType',ctype)
    exportgraphics(f3,[savedir '\' savename '_LFP-overlay-snip' ftype],'BackgroundColor','none','ContentType',ctype)
    exportgraphics(f4,[savedir '\' savename '_ch-spectra' ftype],'BackgroundColor','none','ContentType',ctype)
    exportgraphics(f5,[savedir '\' savename '_avg-spectrogram' ftype],'BackgroundColor','none','ContentType',ctype)


else
    fprintf('To export figures, set local variable export equal to "true"')
end

close all;clc