function PL2_to_Mat(fname, path)
%   PL2_TO_MAT Extract raw broadband and auxiliarly analog input data from
%   .pl2 files and save to .mat.
%
%   Input must be string or character vector of .pl2 file name, which must
%   be saved in raw data repository of Mirzadeh Lab Dropbox.
%
%   Prepared by: Chelsea Faber, Bradley Greger
%   Mirzadeh Lab, Barrow Neurological Institute
%
%   kasper.chelsea@gmail.com
%
%   Requirements: 
%   For full documentation, please see the README and Getting
%   Started guides at https://github.com/ckfaber/inVivo-ePhys

%% BUGS:

%   - breaks b/c current Omniplex configuration only saves AI channel being
%   used, this script tries to load all of them. Workaround is to store in
%   cell array instead, but results in lots of Plexon's internal
%   function-genearted warnings.

%% To-do: 

% - list of non-neural data channels desired (varargin)

%% Set data loading/saving directories

% Files
filename    = fname;
filepath    = [path filename];
savedir     = [path 'Extracted'];

savename    = strsplit(filename,'.');
savename    = char(savename(1));
cd(savedir)

%% Load data

% Check for file
if exist(filepath,'file') ~= 2
    error 'file does not exist, please confirm correct file path specified';
    cd(path)
    filebrowser
end

% Load Omniplex metadata
pl2idx      = PL2GetFileIndex(filepath);

% Load neural data into matrix
if exist([filename '.mat'],'file') ==2

    fprintf('Data have already been extracted.');

elseif exist([filename '.mat'],'file') ==0

    % Initialize neural data matrix
    [nChan,sampCounts]          = plx_adchan_samplecounts(filepath);
    L                           = sampCounts(1);
    number_of_channels          = 16;
    data                        = zeros(number_of_channels,L);              

    broadband_ch_names          = {'WB01';'WB02';'WB03';'WB04';'WB05';'WB06';'WB07';'WB08';'WB09';'WB10';'WB11';'WB12';'WB13';'WB14';'WB15';'WB16'};

    % Loop through neural data channels
    for k = 1:number_of_channels

        [sr, n, ts, fn, ad]     = plx_ad_v(filepath, broadband_ch_names{k});
        data(k,:)               = ad;
    
    end
end

% Load analog input (AI) data
analog_ch_names             = {'AI01';'AI02';'AI03';'AI04';'AI05';'AI06';'AI07';'AI08';
                                 'AI09';'AI10';'AI11';'AI12';'AI13';'AI14';'AI15';'AI16';
                                 'AI17';'AI18';'AI19';'AI20';'AI21';'AI22';'AI23';'AI24';
                                 'AI25';'AI26';'AI27';'AI28';'AI29';'AI30';'AI31';'AI32'};

if nChan == length(find(sampCounts))

% Initialize non-neural aux analog input channels
    L                           = sampCounts(end);                          % MAY BREAK IF OMNIPLEX CONFIG CHANGED
    number_of_channels          = 32;                                       % MAY BREAK IF OMNIPLEX CONFIG CHANGED
    AI_data                     = zeros(number_of_channels,L);              % initialize data matrix
    

    % Loop through aux analog input channels
    for k = 1:number_of_channels

        [AI_sr, n, ts, fn, AI_ad]     = plx_ad_v(filepath, analog_ch_names{k});
        AI_data(k,:)                  = AI_ad;
    
    end

elseif nChan ~= length(find(sampCounts))
    warning('Recording contains empty channels.')
    idx = find(sampCounts);
    L = sampCounts(idx(end));
    number_of_channels          = 32;                            % MAY BREAK IF OMNIPLEX CONFIG CHANGED
    AI_data                     = cell(number_of_channels,1);    % initialize cell array - empty channels will result in Plexon's warnings but it will still work

    for k = 1:number_of_channels

        [AI_sr, n, ts, fn, AI_ad]     = plx_ad_v(filepath, analog_ch_names{k});
        AI_data{k}                    = AI_ad;
    
    end

end

% Export as .mat 
save([savename '.mat'],'pl2idx','data','sr','AI_data','AI_sr','-v7.3');
fprintf('Data extracted successfully.\n')
cd(userpath)
