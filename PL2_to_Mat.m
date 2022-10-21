function PL2_to_Mat(pl2_file)
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

%% To-do: 

%    - convert to function: 
%       - allow input array of file names.
%       - list of non-neural data channels desired (varargin)

%% Set data loading/saving directories

% Files
file_name   = pl2_file;

% Raw data repo - assumes working directory is 'C:\Users\username\MATLAB\'
load_dir    = fullfile(userpath,'..','\Dropbox (Barrow Neurological Institute)\Mirzadeh Lab Dropbox MAIN\Data\Plexon_Ephys\');

%% Dont' change

load_path   = [load_dir file_name];
save_dir    = [load_dir 'Extracted'];

save_name   = strsplit(file_name,'.');
save_name   = char(save_name(1));
cd(save_dir)

%% Load data

% Check for file
if exist(load_path,'file') ~= 2
    error 'file does not exist, please confirm correct file path specified';
    cd(load_dir)
    filebrowser
end

% Load Omniplex metadata
pl2idx      = PL2GetFileIndex(load_path);

% Load neural data into matrix
if exist([file_name '.mat'],'file') ==2

    fprintf('Data have already been extracted.');

elseif exist([file_name '.mat'],'file') ==0

    % Initialize neural data matrix
    [nChan,sampCounts]          = plx_adchan_samplecounts(load_path);
    L                           = sampCounts(1);
    number_of_channels          = 16;
    data                        = zeros(number_of_channels,L);              

    broadband_ch_names          = {'WB01';'WB02';'WB03';'WB04';'WB05';'WB06';'WB07';'WB08';'WB09';'WB10';'WB11';'WB12';'WB13';'WB14';'WB15';'WB16'};

    % Loop through neural data channels
    for k = 1:number_of_channels

        [sr, n, ts, fn, ad]     = plx_ad_v(load_path, broadband_ch_names{k});
        data(k,:)               = ad;
    
    end

    % Initialize non-neural aux analog input channels
    L                           = sampCounts(end);                          % MAY BREAK IF OMNIPLEX CONFIG CHANGED
    number_of_channels          = 32;                                       % MAY BREAK IF OMNIPLEX CONFIG CHANGED
    AI_data                     = zeros(number_of_channels,L);              % initialize data matrix

    analog_ch_names             = {'AI01';'AI02';'AI03';'AI04';'AI05';'AI06';'AI07';'AI08';
                                 'AI09';'AI10';'AI11';'AI12';'AI13';'AI14';'AI15';'AI16';
                                 'AI17';'AI18';'AI19';'AI20';'AI21';'AI22';'AI23';'AI24';
                                 'AI25';'AI26';'AI27';'AI28';'AI29';'AI30';'AI31';'AI32'};
    % Loop through aux analog input channels
    for k = 1:number_of_channels

        [AI_sr, n, ts, fn, AI_ad]     = plx_ad_v(load_path, analog_ch_names{k});
        AI_data(k,:)                  = AI_ad;
    
    end

    % Export as .mat 
    save([save_name '.mat'],'pl2idx','data','sr','AI_data','AI_sr','-v7.3');
    fprintf('Data extracted successfully.\n')

end
