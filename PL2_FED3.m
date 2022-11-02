% PL2_FED3 Load analog input data from .pl2 files and save to .mat.
%
%   Input must be string or character vector of .pl2 file name, which must
%   be saved in Data\FED3 repository of Mirzadeh Lab Dropbox.
%
%   Prepared by: Chelsea Faber
%   Mirzadeh Lab, Barrow Neurological Institute
%
%   kasper.chelsea@gmail.com
%
%   Requirements: 
%   For full documentation, please see the README and Getting
%   Started guides at https://github.com/ckfaber/inVivo-ePhys

%% To do: 

% - fix issues with double-counting or missing peak detection
% - get/export timestamps for start, pellet drop, pellet retrieval, stop,
% etc.
% - convert to function
% - add call to retrieve metadata from google sheet, including version of
% Arduino code used for Fed3 program

%% 

filename            = '2022-10-25_dmu005_001.pl2';
AI                  = 'AI01';

% Raw data repo - assumes working directory is 'C:\Users\username\MATLAB\'
loaddir             = fullfile(userpath,'..',['\Dropbox (Barrow Neurological Institute)' ...
                                    '\Mirzadeh Lab Dropbox MAIN\Data\FED3\']);
%% Filenaming - don't change

loadpath            = [loaddir filename];
savedir             = [loaddir 'Extracted'];

savename            = strsplit(filename,'.');
savename            = char(savename(1));
cd(savedir)

%% Load analog FED3 data

[sr, n, ts, fn, fed3] = plx_ad_v(loadpath, AI);
time                = 0 : 1/sr : (n-1)/sr;

%% Detect & decode pulses

% NOTE - this isn't working properly. Duplicate indices for some peaks,
% others not detected well. Need to go into Arduino code for FED3 and make
% sure the pulse-width is adjusted, and maybe also increase sampling rate
% of AIs. 

[pks,locs,widths,proms]= findpeaks(fed3, sr, ...
                                    'MinPeakHeight',3295, ...
                                    'MinPeakWidth', 0.005, ...
                                    'Annotate','extents');

% quick QC plot
figure,clf
subplot(211)
plot(time,fed3,'k-')
xlim([-100 time(end)])
ylim([-100 3500])
title('Raw FED3 data')
xlabel('Time (s)')
ylabel('mV')
hold on
plot(locs,pks,'o')

subplot(234)
plot(time(17000:19000),fed3(17000:19000),'k-')
xlabel('Time (s)')
title('Start (5 x 500-ms)')
ylabel('mV')

subplot(235)
plot(time(33750:34250),fed3(33750:34250),'k-')
xlabel('Time (s)')
title('Pellet Drop (1 x 5-ms)')
ylabel('mV')

subplot(236)
plot(time(2525000:2526000),fed3(2525000:2526000),'k-')
xlabel('Time (s)')
title('Pellet Retrieval (1 x 10-ms)')
ylabel('mV')

% Export figure
% cd(savedir)
% set(gcf,'color','none')
% exportgraphics(gcf,[savename '_fed3.emf'],'BackgroundColor','none','ContentType','vector')

%% 

threshold = 3200;

fed3_edges             = conv(fed3,[1 0],'same'); % simple convolution-based edge detection
locs                   = find(fed3_edges > threshold);