function PLQCnew(Savepath,SavePlots,ReportFile)
% Plexon Quality Control (Sanity Check) Function
%Prepared by James Sypherd, Chelsea Faber, and Bradley Greger


%REQUIREMENTS
%Data has been extracted, and is in the extracted sub-folder as a .mat

%% TO DO: 
% A For loop at the end is required to produce Report.csv

ReportTable = csvread(ReportFile);


save_dir = Savepath; %Where is the function meant to be saved
Directory = dir; %Creates structure that includes data from the current directory
CurrentFolderContents = struc2cell(Directory); %Creates a cell array out of the previous structure
if nargin < 2; Savepath = []; end %If arguments are less than 2, set save path to empty

if strcomp('ReportTable', {CurrentFolderContents}) %Does the cell array generated at the end of this function and the Cell array of directory contents match? If not run
    PreviousFolderContents = readcell(ReportFile); %creates variable of the differing contents from previous boolean
end

NewFolderContents = setdiff(CurrentFolderContents, PreviousFolderContents); %creates a variable containing new contents

% Code cannibalized from BG
for l = 1 : size(NewFolderContents,1) % Start loop that goes as long as there are new data sets
    path = Directory(1).folder;
    file_name = NewFolderContents{l};

    load_path = [path file_name];
    NeuralData = load(load_path);
    figure;
    sgtitle('Graphs of Raw Neural Data')
    grid_size = 16;
    for m                           = 1:grid_size
        % plot results
        hsp(m)                      = subplot(sqrt(grid_size),sqrt(grid_size),m);
        plot(time_basis,NeuralData{m,:},'k','LineWidth',0.5,'Color',[0.0 0.45 0.75]); %use the input of table b as a parameter to search
        hold on;
        plot(time_basis_stim,data_stim,'r','LineWidth',0.5,'Color',[0.85 0.32 0.01]);
        xlim([0 time_basis(end)]);
        ylabel('Volts');
        xlabel('Seconds');
        t                           = title(['Channel = ' num2str(m)]);
        t.FontSize                  = 10;
        t.FontWeight                = 'normal';

        if m                        == 1
            legend('Neural','Stimulation');
        end

        drawnow;
        if SavePlots
            savefig([file_name '.fig'])
        end
    end
end

cd(save_dir)