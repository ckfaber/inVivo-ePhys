% Quick_spectra_figs_BATCH.m
%
% Script for batch processing of LFP files to produce LFP plots, discrete
% power spectra, and power spectrograms
% 
% Intended for quick inspection of data before more detailed analysis
%% Get file paths from browser

% From file browser, select all .pl2 files to be loaded. For Dropbox data,
% be sure to first "Make Available Offline"
[file,path] = uigetfile('*LFP.mat','MultiSelect','on');

%% Run Quick_spectra_figs.m function for all files

export = true;
ftype = '.pdf';
ctype = 'vector'; % choose 'vector' for vectorized pdfs, otherwise, use 'auto' for raster graphics

cellfun(@(w,x,y,z) Quick_spectra_figs(w,path,export,ftype,ctype),file)