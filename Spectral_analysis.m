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

file_name   = '2022-08-16_dmu005_001.mat';

%% Load broadband data

load_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\Extracted\');
load([load_dir file_name],'data','sr','pl2idx')

%% Filter 



