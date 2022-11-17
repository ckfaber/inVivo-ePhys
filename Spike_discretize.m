%% TO DO: 

% repeat below for baseline (stim-free) period, stimulus period.

spike_raster = zeros(size(timebase));

spike_raster(spikeidx) = 1;

save('spikedata4salt.mat','filename','spike_raster','timebase','sr','spikes')