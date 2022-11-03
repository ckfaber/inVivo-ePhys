%% LED_detect
%
%   LED_DETECT (Eventual) function for the detection of LED stimulation times
%   from analog input to Plexon chassis. 

%   Prepared by: Chelsea Faber
%   Mirzadeh Lab, Barrow Neurological Institute
%
%   kasper.chelsea@gmail.com

%% File input

filename            = '2021-09-17_test5';

meta                = split(filename,{'_','.'});
date                = char(meta(1));
subject             = char(meta(2));

if size(meta,1) == 3
    session         = char(meta(3))
end

%% Load data

loaddir             = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\');
filepath            = [loaddir filename '.pl2'];
savedir             = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Extracted\');

[LEDsr, n,...
    ts, fn, LED]    = plx_ad_v(filepath, 'AI01');

LED                 = (LED / max(LED));             % normalize
L                   = size(LED,1);                  % length of signal
timebase            = 0 : 1/LEDsr : (L-1)/LEDsr;     % time base

%% Detect peaks

% Find time-indices of rising edge of optical stimulations: 
threshold           = 0.99;                         % unitless (LED normalized)
[peaks,times]       = findpeaks(diff(LED),LEDsr,'MinPeakHeight',threshold);

n_stims             = size(times,1);                % number of optical stimulations
int                 = round(min(diff(times)),2);    % time duration between pulses
stim_hz             = round(1/int);                 % calculate stimulation frequency (in Hz) from duration between pulses

% Export
save([savedir filename '_LED.mat'],'LED','LEDsr','L','timebase','peaks','times','stim_hz'); 
