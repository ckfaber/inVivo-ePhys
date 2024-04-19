% PL2_Opto-AI Load analog input data from .pl2 files and save to .mat.
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

[adfreq, n, ts, fn, data_stim] = plx_ad_v(load_path, 'AI01');

% scale stimulation data to volts
data_stim = (data_stim/max(data_stim)*0.050)';  % don't think this is correct, fix
Fs_stim = adfreq;                               % sampling frequency
L = size(data_stim,2);                          % length of signal
time_basis_stim = 0:1/Fs_stim:(L-1)/Fs_stim;    % time base

save([file_name 'opto_stims' '.mat'],'data_stim','Fs_stim','L','time_basis_stim'); 