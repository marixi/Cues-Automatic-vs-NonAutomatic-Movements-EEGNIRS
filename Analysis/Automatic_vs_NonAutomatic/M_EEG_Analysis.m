clear; clc; close all;
addpath('C:\Users\maria\OneDrive\Documentos\GitHub\Combined-EEG-fNIRS-system\Analysis');

laptop = 'laptopMariana';
[mainpath_in, mainpath_out, eeglab_path] = addFolders(laptop);
eeglab;
ft_defaults;

sub='04';
rec='01';

file = getFileNames(mainpath_out, sub, rec);

load(file.EEG_divided, 'EEG_divided');

EEG_AutoUncued = EEG_divided.EEG_AutoNoCue;
EEG_NonAutoUncued = EEG_divided.EEG_NonAutoNoCue;
%% Auto Uncued

event_samp  = [EEG_AutoUncued.event.latency];

startAutoUncued = find(strcmp({EEG_AutoUncued.event.type}, 's1703')==1);
endAutoUncued = find(strcmp({EEG_AutoUncued.event.type}, 's1711')==1);

for trial=1:1
    
    title = char(strcat('Trial_', string(trial)));
    startAutoUncued_times = event_samp(startAutoUncued(trial));
    endAutoUncued_times = event_samp(endAutoUncued(trial));

    EEG_trial = pop_select(EEG_AutoUncued, 'point',...
        [startAutoUncued_times endAutoUncued_times]);
    trial_data = EEG_trial.data;
    
    window_id = 1;
    window = 1:1*EEG_trial.srate;
    while window(end) <= size(trial_data, 2)
        % select the data of this specific window [channel x time]
        data_window = trial_data(:, window);
        
        for channel = 1:size(data_window, 1)  % channel loop
            if isempty(find(isnan(data_window(channel, :)))) % if window is NOT removed because of badchannel (=NaN)
                % calculate PSD
                % data_window = data of the window
                % hann window with length of the window
                % nfft = just copy this...
                % fs = sampling rate
                % P = power 
                % f = frequency steps ( you can plot(f,P) to see PSD)
                [P, f] = periodogram(data_window(channel,:), hann(size(data_window, 2)), 2^(2+nextpow2(size(data_window,2))),EEG_trial.srate);
                % save the power between 0 and 48 Hz (frequency of
                % interest) in a variable pow (all windows of all trials will be saved
                % here)
                pow(:, channel, window_id) = P((f(:,1)>=0 & f(:,1)<=48),1);
            else
                pow(:, channel, window_id) = NaN;
            end
        end
        % increase indices and window
        window_id = window_id + 1;
        window = window+0.5*EEG_trial.srate; % increase sliding window with 0.5*fs
    end
    
    % frequency variable
    freq = f(f(:,1)>=0 & f(:,1)<=48);   % change frequency variable for frequencies of interest
    % average power per channel over windows
    power = mean(pow,3,'omitnan');
    
    % figure;
    % topoplot(power, EEG_AutoUncued.chanlocs, 'electrodes', 'on');
    
    % figure; axes = metaplottopo(power', 'chanlocs', EEG_AutoUncued.chanlocs, 'title', title);
    
    figure; [Movie,Colormap] = eegmovie(power, EEG_AutoUncued.srate, EEG_AutoUncued.chanlocs, 'framenum', 'off', 'vert', 0, 'startsec', -0.1, 'topoplotopt', {'numcontour' 0});
    seemovie(Movie,-5,Colormap);
    
    
    
    
    % pop_topoplot(EEG_trial, 1, keypresses_times, title); 
    
    % EEG_trial_key = pop_select(EEG_trial, 'point',...
    %    [keypresses_times(1)-2 keypresses_times(1)+2]);
    % figure; pop_plottopo(EEG_trial_key, [1:30] , 'preprocessed', 0, 'ydir',1);
end

%%
% Start_AutoCue  = event_samp((strcmp({EEG_AutoCue.event.type}, sprintf('s%d',marker_table.StartAutoCue(1))))==1);
% Stop_AutoCue   = event_samp((strcmp({EEG.event.type}, sprintf('s%d',marker_table.StopAutoCue(1))))==1);

% AFFz - SMA
% figure;
% topoplot(EEG_AutoUncued.data(6, :), EEG_AutoUncued.chanlocs);
% figure;
% topoplot(EEG_NonAutoUncued.data(6, :), EEG_NonAutoUncued.chanlocs);

% F7 - DLPFC
% figure;
% topoplot(EEG_AutoUncued.data(4, :), EEG_AutoUncued.chanlocs);
% figure;
% topoplot(EEG_NonAutoUncued.data(4, :), EEG_NonAutoUncued.chanlocs);

% pop_spectopo(EEG_AutoUncued, 1);

%% Topoplots for Auto Uncued
event_samp  = [EEG_AutoUncued.event.latency];

startAutoUncued = find(strcmp({EEG_AutoUncued.event.type}, 's1703')==1);
endAutoUncued = find(strcmp({EEG_AutoUncued.event.type}, 's1711')==1);
keypresses = event_samp((strcmp({EEG_AutoUncued.event.type}, 's1777')==1));

for trial=1:10
    title = char(strcat('Trial_', string(trial)));
    startAutoUncued_times = event_samp(startAutoUncued(trial));
    endAutoUncued_times = event_samp(endAutoUncued(trial));
    keypresses_times = keypresses((keypresses>startAutoUncued_times & keypresses<endAutoUncued_times));
    keypresses_times = keypresses_times - startAutoUncued_times;
    EEG_trial = pop_select(EEG_AutoUncued, 'point',...
        [startAutoUncued_times endAutoUncued_times]);
    pop_topoplot(EEG_trial, 1, keypresses_times, title); 
    
    % EEG_trial_key = pop_select(EEG_trial, 'point',...
    %    [keypresses_times(1)-2 keypresses_times(1)+2]);
    % figure; pop_plottopo(EEG_trial_key, [1:30] , 'preprocessed', 0, 'ydir',1);
end

%% Topoplots for Non-Auto Uncued
event_samp  = [EEG_NonAutoUncued.event.latency];

startNonAutoUncued = find(strcmp({EEG_NonAutoUncued.event.type}, 's1705')==1);
endNonAutoUncued = find(strcmp({EEG_NonAutoUncued.event.type}, 's1713')==1);
keypresses = event_samp((strcmp({EEG_NonAutoUncued.event.type}, 's1777')==1));

for trial=1:1
    title = char(strcat('Trial_', string(trial)));
    startNonAutoUncued_times = event_samp(startNonAutoUncued(trial));
    endNonAutoUncued_times = event_samp(endNonAutoUncued(trial));
    keypresses_times = keypresses((keypresses>startNonAutoUncued_times & keypresses<endNonAutoUncued_times));
    keypresses_times = keypresses_times - startNonAutoUncued_times;
    EEG_trial = pop_select(EEG_NonAutoUncued, 'point',...
        [startNonAutoUncued_times endNonAutoUncued_times]);
    pop_topoplot(EEG_trial, 1, keypresses_times, title);    
end