function lowpass_down(fname, path)
%   LOWPASS_DOWN Lowpass filter Plexon in vivo electrophysiology recordings
%   
%   Builds and executes low-pass filter (Butterworth, 250-Hz), then
%   downsamples to 1000-Hz via decimation, performs common median
%   referencing and mean-centering.
%   
%   LFP data saved to new .mat file within same 'Extracted' data folder.

%   Prepared by: Chelsea Faber, Bradley Greger
%   Mirzadeh Lab, Barrow Neurological Institute
%
%   kasper.chelsea@gmail.com

%% Set data loading/saving directories

% Files
filename    = fname;
filepath    = [path filename];

savename    = strsplit(filename,'.');
savename    = [char(savename(1)) '_LFP'];

load(filepath)

%% Low-pass filter

order = 3;
Fc = 250; % cutoff frequency - 250 Hz will remove most low frequency LFP %this doesn't make sense? Will remove high frequency?
Fs = sr; % sampling frequency of data (the specific Fs should be in the data file)
[z,p,k] = butter(order,Fc/(Fs/2),'low'); % butterworth filter
[SOS,G] = zp2sos(z,p,k);% convert to SOS structure to use filter analysis tool
% tool to look at filter
% fvtool(SOS);
LFP = filtfilt(SOS,G,data')'; %running filter
%% CMR and Mean-Centering

% Common median referencing
med = median(LFP,1);
for chi = 1:size(LFP,1)
    LFP(chi,:) = LFP(chi,:) - med;
end

% Mean-center
LFP = LFP - mean(LFP,2);

%% Downsample 

[nChan,nPts] = size(LFP);
downsr = 1000;
r = sr/downsr; 

downlfp = zeros(size(LFP,1),ceil(size(LFP,2) / r));
for chi = 1:nChan
    tmp = LFP(chi,:);
    downlfp(chi,:) = decimate(tmp,r);
end
 
nBeg = mod(nPts-1,r)+1;
time = 0 : 1/sr : (nPts - 1)/sr;
downtime = time(nBeg : r : end); 

% quick plot to confirm
% figure
% plot(downtime,downlfp(4,:),'m--o')
% hold on
% plot(time,LFP(4,:),'k.')

LFP = downlfp;

%% Export data

save([path savename '.mat'],'LFP','downsr','downtime','-v7.3');
fprintf([fname ' complete\n'])
clear;