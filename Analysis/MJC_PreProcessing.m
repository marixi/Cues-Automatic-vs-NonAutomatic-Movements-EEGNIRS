clear;
close all;

%% Initialize FieldTrip and EEGLAB
laptop='laptopCatarina';
% laptop='laptopMariana';
% laptop='laptopJoao';
[mainpath_in, mainpath_out, eeglab_path] = addFolders(laptop);

eeglab;
ft_defaults;

sub='03';
rec='02';

file = getFileNames(mainpath_out, sub, rec);

%% Select data folder 
sub_path = fullfile(mainpath_in,'incoming',['sub-',sub]);
eeg_path = fullfile(sub_path,'eeg');
nirs_path = fullfile(sub_path,'nirs');
sub_vhdr = fullfile(['sub-',sub,'_rec-',rec,'_eeg.vhdr']);

% Before changing directory to the subpath, add current directory to access
% the function files
addpath(pwd)
cd(sub_path);

oxyfile = fullfile(sub_path,'nirs',['sub-',sub,'_rec-',rec,'_nirs.oxy3']);

%% Upload files
% fprintf('\n \n Select the Oxysoft file \n \n')
% [baseName, folder] = uigetfile({'*.oxy4;*.oxy3;*.edf', 'All Oxysoft file(*.oxy4, *.oxy3, *.edf)';},'Select the Oxysoft file');
% oxyfile = fullfile(folder, baseName);
% oxyfile = 'C:\Users\maria\Universidade do Porto\João Pedro Barbosa Fonseca - Internship\Experiment\Data\Pilots\incoming\sub-02\nirseeg\sub-02_rec-02_nirseeg.edf';
% oxyfile = 'C:\Users\maria\Universidade do Porto\João Pedro Barbosa Fonseca - Internship\After Experiment\pilots\pilot 1\sub-01_rec-01_nirseeg.edf';
% oxyfile = 'C:\Users\catar\OneDrive - Universidade do Porto\Internship\After Experiment\pilots\pilot 1\sub-01_rec-01_nirseeg.edf'

% fprintf('\n \n Select the EEGo file \n \n')
% [baseName, folder, idx] = uigetfile({'*.eeg;*.vhdr;*.vmrk', 'All EEGo file(*.eeg, *.vhdr, *.vmrk)';},'Select the EEGo file');
% eegfile = fullfile(folder, baseName);
% eegfile = 'C:\Users\joaop\OneDrive - Universidade do Porto\Erasmus\Internship\After Experiment\pilots\pilot 1\pilotfnirs_01.vhdr';
% eegfile = 'C:\Users\maria\Universidade do Porto\João Pedro Barbosa Fonseca - Internship\After Experiment\pilots\pilot 1\pilotfnirs_01.vhdr';
% eegfile = 'C:\Users\catar\OneDrive - Universidade do Porto\Internship\After Experiment\pilots\pilot 1\pilotfnirs_01.vhdr'

correct = input('Load data (Y/N)? If not, its assumed the .set files have been generated \n', 's');
if strcmpi(correct, 'y')
    done = 1;
    data_loaded = 0;
elseif strcmpi(correct, 'n')
    data_loaded = 1;
end

%% Read data 
if data_loaded == 0
    % FIELDTRIP - load the eeg&nirs data
    cfg = [];
    cfg.dataset = oxyfile;
    nirs_raw = ft_preprocessing(cfg);
    nirs_events = ft_read_event(cfg.dataset);
    if strcmp(sub,'03') && strcmp(rec,'02')
        nirs_events=ft_filter_event(nirs_events,'minsample',72787);
    end
    
    if strcmp(sub,'02') && strcmp(rec,'02')
        save(['sub-',sub,'_rec-',rec,'_nirseeg.mat'], 'nirs_raw');
        save(['sub-',sub,'_rec-',rec,'_nirseeg_events.mat'], 'nirs_events');
    else
        save(['sub-',sub,'_rec-',rec,'_nirs.mat'], 'nirs_raw');
        save(['sub-',sub,'_rec-',rec,'_nirs_events.mat'], 'nirs_events');
    end
    
    % EEGLAB load eeg only data
    [EEG,~]         = pop_loadbv(fullfile(sub_path,'eeg'), sub_vhdr);
    [ALLEEG,EEG,~]  = pop_newset(ALLEEG, EEG, 1,'setname','eeg_raw','gui','off');

else %if data has been loaded and the datasets created, load the structs
    if strcmp(sub,'02') && strcmp(rec,'02')
        load(['sub-',sub,'_rec-',rec,'_nirseeg.mat']);    %Avoids call to ft_preprocessing
        load(['sub-',sub,'_rec-',rec,'_nirseeg_events.mat']);%Avoids call to ft_readevents
    else
        load(fullfile('nirs',['sub-',sub,'_rec-',rec,'_nirs.mat']));    %Avoids call to ft_preprocessing
        load(fullfile('nirs',['sub-',sub,'_rec-',rec,'_nirs_events.mat']));%Avoids call to ft_readevents
    end
    [EEG]  = pop_loadset(['sub-',sub,'_rec-',rec,'_eeg.set'],fullfile(sub_path,'eeg'));
end

%% NIRS: Show layout of optode template
cfg = [];
cfg.layout = fullfile(mainpath_out,['sub-',sub],'3d','layout.mat');
ft_layoutplot(cfg);

%% Read stimuli results
results = load(fullfile(sub_path, 'stim', ['results_sub-',sub,'_rec-',rec]));
marker_table = checkMarkers(EEG, nirs_raw, nirs_events);

%% EEG: Load MNI coordinates
% Load channel coordinates/positions of the standard MNI model of eeglab: 
% MNI dipfit channel positions
[EEG] = pop_chanedit(EEG, 'lookup', join([eeglab_path,...
        '\\plugins\\dipfit\\standard_BESA\\standard-10-5-cap385.elp']),...
        'lookup', join([eeglab_path,...
        '\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc']));

%% EEG: Filter - 50 Hz noise and harmonics
% Determine the power spectrum of the raw data
% eeg_raw = EEG.data;
% [P_raw, f_raw] = periodogram(eeg_raw', [], [] , EEG.srate);

% Filter the signal
if ~isfile(file.filtered) 
    eeg_filtered = filterNoise(double(eeg_raw), EEG, 4);
    EEG.data = eeg_filtered;
    [ALLEEG, EEG, ~] = pop_newset(ALLEEG, EEG, 1, 'setname', 'filtData',...
        'gui', 'off');
    save(file.filtered, 'EEG');
else
    load(file.filtered, 'EEG');
    eeg_filtered = EEG.data;
    [ALLEEG, EEG, ~] = pop_newset(ALLEEG, EEG, 1, 'setname', 'filtData',...
        'gui', 'off');
end

% Determine the power spectrum of the filtered data
% [P_filt, f_filt] = periodogram(eeg_filtered', [], [] , EEG.srate);

% Plot the power spectrums
% figure;
% subplot(1, 3, 1); plot(f_raw, P_raw); 
% xlim([0 200]); ylim([0 7e5]); title('EEG raw data');
% subplot(1, 3, 2); plot(f_filt, P_filt); 
% xlim([0 200]); ylim([0 7e5]); title('EEG filtered data - same scale');
% subplot(1, 3, 3); plot(f_filt, P_filt); 
% xlim([0 50]); title('EEG filtered data - different scale');

%% EEG: Remove bad channels 
% Visually inspect the signals and choose if a signals is too bad that it
% needs to be removed.
% First see the power spectrum and then check if the signal is actually bad
% on the plot.

if ~isfile(file.removedBadChannels) 
    figure; 
    pop_spectopo(EEG, 1, [0 EEG.pnts], 'EEG', 'percent', 50, 'freqrange',...
        [2 75], 'electrodes', 'off');
    pop_eegplot(EEG);
    RC = input('Remove channel [nr/no]: ','s');
    while ~strcmp(RC, 'no')
        [EEG] = pop_select(EEG, 'nochannel', eval(RC));
        figure;
        pop_spectopo(EEG, 1, [0 EEG.pnts], 'EEG', 'percent', 50,...
            'freqrange', [2 75], 'electrodes', 'off');
        pop_eegplot(EEG);
        RC = input('Remove channel [nr/no]: ','s');
    end
    [ALLEEG, EEG, ~] = pop_newset(ALLEEG, EEG, 1, 'setname',...
        'removedBadChannels', 'gui', 'off');
    save(file.removedBadChannels, 'EEG');
else
    load(file.removedBadChannels, 'EEG');
    [ALLEEG, EEG, ~] = pop_newset(ALLEEG, EEG, 1, 'setname',...
        'removedBadChannels', 'gui', 'off');
end

%% EEG: Removal of eye blinks - preICA
if ~isfile(file.preICA)  
    [EEG] = pop_runica(EEG,'icatype', 'runica', 'extended', 1,...
        'interrupt', 'on');
    [ALLEEG, EEG, ~] = pop_newset(ALLEEG, EEG, 1, 'setname', 'preICA',...
        'gui', 'off');
    save(file.preICA, 'EEG');
else
    load(file.preICA, 'EEG');
    [ALLEEG, EEG, ~] = pop_newset(ALLEEG, EEG, 1, 'setname', 'preICA',...
        'gui', 'off');
end

%% EEG: Removal of eye blinks - pstICA
if ~isfile(file.pstICA)
    [EEG] = run_postICA(EEG);
    [ALLEEG, EEG, ~] = pop_newset(ALLEEG, EEG, 1, 'setname', 'pstICA',...
        'gui', 'off');
    save(file.pstICA, 'EEG');
else                          
    load(file.pstICA, 'EEG');
    [ALLEEG, EEG, ~] = pop_newset(ALLEEG, EEG, 1, 'setname', 'pstICA',...
        'gui', 'off');
end

%% EEG: Set reference
% Re-reference the system to M1

if ~isfile(file.preprocessed)
    [EEG] = pop_reref(EEG, 'M1');
    [ALLEEG, EEG, ~] = pop_newset(ALLEEG, EEG, 1, 'setname',...
        'preprocessed', 'gui', 'off');
    save(file.preprocessed, 'EEG');
else                          
    load(file.preprocessed, 'EEG');
    [ALLEEG, EEG, ~] = pop_newset(ALLEEG, EEG, 1, 'setname',...
        'preprocessed', 'gui', 'off');
end

%% Extract task data
[EEG_divided, file] = extractTaskData_EEG(EEG,marker_table, results, file, mainpath_out);
save(file.EEG_divided,'EEG_divided');
% [ALLEEG,EEG,~]  = pop_newset(ALLEEG, EEG_task, 1,'setname','taskData','gui','off');

