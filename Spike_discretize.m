% Discretize all spikes in channel
spike_raster            = zeros(size(timebase));
spike_raster(spikeidx)  = 1;

% Extract baseline period & create trials x spikes matrix
baseline                = spike_raster(1:stimidx(1));                       % everything up until first LED pulse
ntrials                 = size(stimidx,2);                                  % set number of trials to equal number of LED pulses

l                       = numel(baseline);                                  % total length of baseline period
win                     = floor(l / ntrials);                               % calculate baseline trial length to be total baseline length / ntrials

baseline                = baseline(1:end - (rem(l,win)));                   % trim so evenly divisible by window size
spt_baseline            = reshape(baseline,win,[])';                        % reshape long vector into trials (ntrials) x spikes (win) matrix. Transpose necessary because of how reshape fills the new matrix
spt_baseline            = spt_baseline(randperm(size(spt_baseline,1)),:);   % randomly rearrange the trials

% Extract test period & create trials x spikes matrix
wn                      = 0.01 * sr;                                        % 10-ms window converted in samples
dt                      = 1/sr;                                             % time-resolution of sampling, in seconds

trialwin                = 1 : wn;                                          
[tmat stimmat]          = meshgrid(trialwin, stimidx);                      
test_idx_mat            = tmat + stimmat; 
spt_test                = spike_raster(test_idx_mat);

% Save
save('spikedata4salt.mat','filename','spike_raster','timebase','spt_baseline','spt_test','dt');