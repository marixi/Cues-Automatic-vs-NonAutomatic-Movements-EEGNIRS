%% Analysis of the EEG signals - separate channels.

clear; clc; close all;
addpath('C:\Users\maria\OneDrive\Documentos\GitHub\Combined-EEG-fNIRS-system\Analysis');

laptop = 'laptopMariana';
[mainpath_in, mainpath_out, eeglab_path] = addFolders(laptop);
eeglab;
ft_defaults;
results_path = 'C:\Users\maria\OneDrive\Ambiente de Trabalho\Automaticity Results\Separate Channels';

subrec = ["28" "04"; "02" "02"];

% List of the 30 channels present in the cap.
list_channels = ["Fp1"; "Fpz"; "Fp2"; "F7"; "F3"; "AFFz"; "F4"; "F8";...
    "FC5"; "FC1"; "FC2"; "FC6"; "T7"; "C3"; "Cz"; "C4"; "T8"; "CP5";...
    "CP1"; "CP2"; "CP6"; "P7"; "P3"; "Pz"; "P4"; "P8"; "POz"; "O1";...
    "Oz"; "O2"];

% Loop through every subject.
for subject = 1:size(subrec, 1)
    sub = subrec(subject, 1);
    rec = subrec(subject, 2);
  
    % Load the subject's EEG signals.
    load([mainpath_in, '\pre-processed\sub-', char(sub), '\eeg\sub-',...
        char(sub), '_rec-', char(rec), '_eeg_divided.mat']);
    
    % Separate into the four different tasks.
    EEG_AutoUncued = EEG_divided.EEG_AutoNoCue;
    EEG_NonAutoUncued = EEG_divided.EEG_NonAutoNoCue;
    EEG_AutoCued = EEG_divided.EEG_AutoCue;
    EEG_NonAutoCued = EEG_divided.EEG_NonAutoCue;
    
    %% Auto Uncued.

    event_samp  = [EEG_AutoUncued.event.latency];
    startTask = find(strcmp({EEG_AutoUncued.event.type}, 's1703')==1);
    endTask = find(strcmp({EEG_AutoUncued.event.type}, 's1711')==1);

    % Get the power spectrum density (PSD) averaged over all trials.
    [power, freq] = calculateAveragePowerAllTrials(EEG_AutoUncued,...
        event_samp, startTask, endTask);
    
    % Compensate for removed channels.
    power = compensateRemovedChannels(power, EEG_AutoUncued, list_channels);
    
    % Save the values onto a allSubjects variable.
    autouncued_power_allSubjects(:, :, subject) = power;
    
    %% Non-Auto Uncued.

    event_samp  = [EEG_NonAutoUncued.event.latency];
    startTask = find(strcmp({EEG_NonAutoUncued.event.type}, 's1705')==1);
    endTask = find(strcmp({EEG_NonAutoUncued.event.type}, 's1713')==1);
    
    % Get the power spectrum density (PSD) averaged over all trials.
    [power, freq] = calculateAveragePowerAllTrials(EEG_NonAutoUncued,...
        event_samp, startTask, endTask);
    
    % Compensate for removed channels.
    power = compensateRemovedChannels(power, EEG_NonAutoUncued, list_channels);
    
    % Save the values onto a allSubjects variable.
    nonautouncued_power_allSubjects(:, :, subject) = power;
    
    %% Auto Cued.

    event_samp  = [EEG_AutoCued.event.latency];
    startTask = find(strcmp({EEG_AutoCued.event.type}, 's1702')==1);
    endTask = find(strcmp({EEG_AutoCued.event.type}, 's1710')==1);

    % Get the power spectrum density (PSD) averaged over all trials.
    [power, freq] = calculateAveragePowerAllTrials(EEG_AutoCued,...
        event_samp, startTask, endTask);
    
    % Compensate for removed channels.
    power = compensateRemovedChannels(power, EEG_AutoCued, list_channels);
    
    % Save the values onto a allSubjects variable.
    autocued_power_allSubjects(:, :, subject) = power;
    
    %% Non-Auto Cued.

    event_samp  = [EEG_NonAutoCued.event.latency];
    startTask = find(strcmp({EEG_NonAutoCued.event.type}, 's1704')==1);
    endTask = find(strcmp({EEG_NonAutoCued.event.type}, 's1712')==1);

    % Get the power spectrum density (PSD) averaged over all trials.   
    [power, freq] = calculateAveragePowerAllTrials(EEG_NonAutoCued,...
        event_samp, startTask, endTask);
    
    % Compensate for removed channels.
    power = compensateRemovedChannels(power, EEG_NonAutoCued, list_channels);
    
    % Save the values onto a allSubjects variable.
    nonautocued_power_allSubjects(:, :, subject) = power;

    %% Get the locations of the channels of interest.
    
    locs = {EEG_AutoCued.chanlocs.labels};
    F7_loc = find(contains(locs, 'F7'));
    F8_loc = find(contains(locs, 'F8'));
    FC1_loc = find(contains(locs, 'FC1'));
    FC2_loc = find(contains(locs, 'FC2'));
    Cz_loc = find(contains(locs, 'Cz'));
    C3_loc = find(contains(locs, 'C3'));
    
    %% Get the values of power for the specific channels and plot them.
    
    % F7.
    autouncued_power_F7 = autouncued_power_allSubjects(:, F7_loc, subject);
    autocued_power_F7 = autocued_power_allSubjects(:, F7_loc, subject);
    nonautouncued_power_F7 = nonautouncued_power_allSubjects(:, F7_loc, subject);
    nonautocued_power_F7 = nonautocued_power_allSubjects(:, F7_loc, subject);
    
    figure; title('F7');
    plot(freq, autouncued_power_F7); hold on;
    plot(freq, autocued_power_F7); hold on;
    plot(freq, nonautouncued_power_F7); hold on;
    plot(freq, nonautocued_power_F7); hold on;
    xline(4); hold on;
    xline(8); hold on;
    xline(13); hold on;
    xline(32); hold off;
    legend('Auto Uncued','Auto Cued', 'Non-Auto Uncued', 'Non-Auto Cued');
    
    % F8.
    autouncued_power_F8 = autouncued_power_allSubjects(:, F8_loc, subject);
    autocued_power_F8 = autocued_power_allSubjects(:, F8_loc, subject);
    nonautouncued_power_F8 = nonautouncued_power_allSubjects(:, F8_loc, subject);
    nonautocued_power_F8 = nonautocued_power_allSubjects(:, F8_loc, subject);
    
    figure; title('F8');
    plot(freq, autouncued_power_F8); hold on;
    plot(freq, autocued_power_F8); hold on;
    plot(freq, nonautouncued_power_F8); hold on;
    plot(freq, nonautocued_power_F8); hold on;
    xline(4); hold on;
    xline(8); hold on;
    xline(13); hold on;
    xline(32); hold off;
    legend('Auto Uncued','Auto Cued', 'Non-Auto Uncued', 'Non-Auto Cued');
    
    % FC1.
    autouncued_power_FC1 = autouncued_power_allSubjects(:, FC1_loc, subject);
    autocued_power_FC1 = autocued_power_allSubjects(:, FC1_loc, subject);
    nonautouncued_power_FC1 = nonautouncued_power_allSubjects(:, FC1_loc, subject);
    nonautocued_power_FC1 = nonautocued_power_allSubjects(:, FC1_loc, subject);
    
    figure; title('FC1');
    plot(freq, autouncued_power_FC1); hold on;
    plot(freq, autocued_power_FC1); hold on;
    plot(freq, nonautouncued_power_FC1); hold on;
    plot(freq, nonautocued_power_FC1); hold on;
    xline(4); hold on;
    xline(8); hold on;
    xline(13); hold on;
    xline(32); hold off;
    legend('Auto Uncued','Auto Cued', 'Non-Auto Uncued', 'Non-Auto Cued');
    
    % FC2.
    autouncued_power_FC2 = autouncued_power_allSubjects(:, FC2_loc, subject);
    autocued_power_FC2 = autocued_power_allSubjects(:, FC2_loc, subject);
    nonautouncued_power_FC2 = nonautouncued_power_allSubjects(:, FC2_loc, subject);
    nonautocued_power_FC2 = nonautocued_power_allSubjects(:, FC2_loc, subject);
    
    figure; title('FC2');
    plot(freq, autouncued_power_FC2); hold on;
    plot(freq, autocued_power_FC2); hold on;
    plot(freq, nonautouncued_power_FC2); hold on;
    plot(freq, nonautocued_power_FC2); hold on;
    xline(4); hold on;
    xline(8); hold on;
    xline(13); hold on;
    xline(32); hold off;
    legend('Auto Uncued','Auto Cued', 'Non-Auto Uncued', 'Non-Auto Cued');
    
    % Cz.
    autouncued_power_Cz = autouncued_power_allSubjects(:, Cz_loc, subject);
    autocued_power_Cz = autocued_power_allSubjects(:, Cz_loc, subject);
    nonautouncued_power_Cz = nonautouncued_power_allSubjects(:, Cz_loc, subject);
    nonautocued_power_Cz = nonautocued_power_allSubjects(:, Cz_loc, subject);
    
    figure; title('Cz');
    plot(freq, autouncued_power_Cz); hold on;
    plot(freq, autocued_power_Cz); hold on;
    plot(freq, nonautouncued_power_Cz); hold on;
    plot(freq, nonautocued_power_Cz); hold on;
    xline(4); hold on;
    xline(8); hold on;
    xline(13); hold on;
    xline(32); hold off;
    legend('Auto Uncued','Auto Cued', 'Non-Auto Uncued', 'Non-Auto Cued');
    
    % C3.
    autouncued_power_C3 = autouncued_power_allSubjects(:, C3_loc, subject);
    autocued_power_C3 = autocued_power_allSubjects(:, C3_loc, subject);
    nonautouncued_power_C3 = nonautouncued_power_allSubjects(:, C3_loc, subject);
    nonautocued_power_C3 = nonautocued_power_allSubjects(:, C3_loc, subject);
    
    figure; title('C3');
    plot(freq, autouncued_power_C3); hold on;
    plot(freq, autocued_power_C3); hold on;
    plot(freq, nonautouncued_power_C3); hold on;
    plot(freq, nonautocued_power_C3); hold on;
    xline(4); hold on;
    xline(8); hold on;
    xline(13); hold on;
    xline(32); hold off;
    legend('Auto Uncued','Auto Cued', 'Non-Auto Uncued', 'Non-Auto Cued');
    
    disp(['These are the results for subject ', char(sub), '.']);
    disp('Press any key to move onto the next subject.');
    pause;
    close all;
    
end

% Get the power spectrum density (PSD) averaged over all subjects.
% Auto Uncued.
autouncued_power = mean(autouncued_power_allSubjects, 3, 'omitnan');
% Non-Auto Uncued.
nonautouncued_power = mean(nonautouncued_power_allSubjects, 3, 'omitnan');
% Auto Cued.
autocued_power = mean(autocued_power_allSubjects, 3, 'omitnan');
% Non-Auto Cued.
nonautocued_power = mean(nonautocued_power_allSubjects, 3, 'omitnan');

%% Plot the PSD for specific channels.

% F7.
autouncued_power_F7 = autouncued_power(:, F7_loc);
autocued_power_F7 = autocued_power(:, F7_loc);
nonautouncued_power_F7 = nonautouncued_power(:, F7_loc);
nonautocued_power_F7 = nonautocued_power(:, F7_loc);

figure; title('F7');
plot(freq, autouncued_power_F7); hold on;
plot(freq, autocued_power_F7); hold on;
plot(freq, nonautouncued_power_F7); hold on;
plot(freq, nonautocued_power_F7); hold on;
xline(4); hold on;
xline(8); hold on;
xline(13); hold on;
xline(32); hold off;
legend('Auto Uncued','Auto Cued', 'Non-Auto Uncued', 'Non-Auto Cued');

set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf, fullfile(results_path, 'F7_PowervsFreq'),'png');

% F8.
autouncued_power_F8 = autouncued_power(:, F8_loc);
autocued_power_F8 = autocued_power(:, F8_loc);
nonautouncued_power_F8 = nonautouncued_power(:, F8_loc);
nonautocued_power_F8 = nonautocued_power(:, F8_loc);

figure; title('F8');
plot(freq, autouncued_power_F8); hold on;
plot(freq, autocued_power_F8); hold on;
plot(freq, nonautouncued_power_F8); hold on;
plot(freq, nonautocued_power_F8); hold on;
xline(4); hold on;
xline(8); hold on;
xline(13); hold on;
xline(32); hold off;
legend('Auto Uncued','Auto Cued', 'Non-Auto Uncued', 'Non-Auto Cued');

set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf, fullfile(results_path, 'F8_PowervsFreq'),'png');

% FC1.
autouncued_power_FC1 = autouncued_power(:, FC1_loc);
autocued_power_FC1 = autocued_power(:, FC1_loc);
nonautouncued_power_FC1 = nonautouncued_power(:, FC1_loc);
nonautocued_power_FC1 = nonautocued_power(:, FC1_loc);

figure; title('FC1');
plot(freq, autouncued_power_FC1); hold on;
plot(freq, autocued_power_FC1); hold on;
plot(freq, nonautouncued_power_FC1); hold on;
plot(freq, nonautocued_power_FC1); hold on;
xline(4); hold on;
xline(8); hold on;
xline(13); hold on;
xline(32); hold off;
legend('Auto Uncued','Auto Cued', 'Non-Auto Uncued', 'Non-Auto Cued');

set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf, fullfile(results_path, 'FC1_PowervsFreq'),'png');

% FC2.
autouncued_power_FC2 = autouncued_power(:, FC2_loc);
autocued_power_FC2 = autocued_power(:, FC2_loc);
nonautouncued_power_FC2 = nonautouncued_power(:, FC2_loc);
nonautocued_power_FC2 = nonautocued_power(:, FC2_loc);

figure; title('FC2');
plot(freq, autouncued_power_FC2); hold on;
plot(freq, autocued_power_FC2); hold on;
plot(freq, nonautouncued_power_FC2); hold on;
plot(freq, nonautocued_power_FC2); hold on;
xline(4); hold on;
xline(8); hold on;
xline(13); hold on;
xline(32); hold off;
legend('Auto Uncued','Auto Cued', 'Non-Auto Uncued', 'Non-Auto Cued');

set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf, fullfile(results_path, 'FC2_PowervsFreq'),'png');

% Cz.
autouncued_power_Cz = autouncued_power(:, Cz_loc);
autocued_power_Cz = autocued_power(:, Cz_loc);
nonautouncued_power_Cz = nonautouncued_power(:, Cz_loc);
nonautocued_power_Cz = nonautocued_power(:, Cz_loc);

figure; title('Cz');
plot(freq, autouncued_power_Cz); hold on;
plot(freq, autocued_power_Cz); hold on;
plot(freq, nonautouncued_power_Cz); hold on;
plot(freq, nonautocued_power_Cz); hold on;
xline(4); hold on;
xline(8); hold on;
xline(13); hold on;
xline(32); hold off;
legend('Auto Uncued','Auto Cued', 'Non-Auto Uncued', 'Non-Auto Cued');

set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf, fullfile(results_path, 'Cz_PowervsFreq'),'png');
    
% C3.
autouncued_power_C3 = autouncued_power(:, C3_loc);
autocued_power_C3 = autocued_power(:, C3_loc);
nonautouncued_power_C3 = nonautouncued_power(:, C3_loc);
nonautocued_power_C3 = nonautocued_power(:, C3_loc);

figure; title('C3');
plot(freq, autouncued_power_C3); hold on;
plot(freq, autocued_power_C3); hold on;
plot(freq, nonautouncued_power_C3); hold on;
plot(freq, nonautocued_power_C3); hold on;
xline(4); hold on;
xline(8); hold on;
xline(13); hold on;
xline(32); hold off;
legend('Auto Uncued','Auto Cued', 'Non-Auto Uncued', 'Non-Auto Cued');

set(gcf, 'Position', get(0, 'Screensize'));
saveas(gcf, fullfile(results_path, 'C3_PowervsFreq'),'png');

disp('This was the end of individual subjects.');
disp('These are the results for the average of all subjects.');
disp('Press any key to move on to the statistical analysis.');
pause;
close all;

%% Statistical analysis.

%% F7.

% Auto Uncued vs Cued.
auto_F7 = [autouncued_power_F7 autocued_power_F7];
groups = {'Auto Uncued'; 'Auto Cued'};
% Test the hypothesis that the data is normaly distributed.
h_autouncued_F7 = adtest(autouncued_power_F7);
h_autocued_F7 = adtest(autocued_power_F7);
% If normally distributed - ANOVA test.
if h_autouncued_F7==0 && h_autocued_F7==0
    [p, tbl, stats] = anova1(auto_F7, groups, 'on');
    figure;
    multcompare(stats);
% If not normally distributed - Friedman's test. 
else
    [p, tbl, stats] = friedman(auto_F7, 2, 'on');
    figure;
    multcompare(stats);
end

% Non-Auto Uncued vs Non-Cued.
nonauto_F7 = [nonautouncued_power_F7 nonautocued_power_F7];
groups = {'Auto Uncued'; 'Auto Cued'};
% Test the hypothesis that the data is normaly distributed.
h_autouncued_F7 = adtest(nonautouncued_power_F7);
h_nonautocued_F7 = adtest(nonautocued_power_F7);
% If normally distributed - ANOVA test.
if h_nonautouncued_F7==0 && h_nonautocued_F7==0
    [p, tbl, stats] = anova1(nonauto_F7, groups, 'on');
    figure;
    multcompare(stats);
% If not normally distributed - Friedman's test. 
else
    [p, tbl, stats] = friedman(nonauto_F7, 2, 'on');
    figure;
    multcompare(stats);
end

disp('F7');
pause;

%%

% a = mean(autouncued_power_allSubjects, 1, 'omitnan');
% b = mean(autocued_power_allSubjects, 1, 'omitnan');
% 
% a_F7 = a(1, F8_loc, :);
% b_F7 = b(1, F8_loc, :);
% 
% a_F7_final = [a_F7(1, 1, 1); a_F7(1, 1, 2)];
% b_F7_final = [b_F7(1, 1, 1); b_F7(1, 1, 2)];
% 
% % Auto Uncued vs Cued for F7.
% auto_F7 = [a_F7_final b_F7_final];
% groups = {'Auto Uncued'; 'Auto Cued'};
% [p, tbl, stats] = anova1(auto_F7, groups, 'on');

%% Functions

function th = getThresholdOfTrial(power)

    th = mean(power, 1) + 3*std(power);

end

% Loop through the power from the individual trials and average them.
function [power, freq] = calculateAveragePowerAllTrials(EEG, event_samp,...
    startTask, endTask)

    for trial=1:length(startTask)
    
        title = char(strcat('Trial_', string(trial)));
        startTask_times = event_samp(startTask(trial));
        endTask_times = event_samp(endTask(trial));

        EEG_trial = pop_select(EEG, 'point', [startTask_times endTask_times]);
        trial_data = EEG_trial.data;

        [power_oneTrial, freq] = calculatePowerPerTrial(EEG_trial, trial_data);
            
        power_allTrials(:, :, trial) = power_oneTrial;
    
    end
    
    power = mean(power_allTrials, 3);

end

% From the trial data, calculate the power over the frequencies of the signal
% for all electrodes.
function [power, freq] =...
    calculatePowerPerTrial(EEG_trial, trial_data)
    
    % Using a sliding Hann window.
    window_id = 1;
    window = 1:1*EEG_trial.srate;
    while window(end) <= size(trial_data, 2)
        % Select the data of this specific window [channel x time].
        data_window = trial_data(:, window);
        
        % Channel loop.
        for channel = 1:size(data_window, 1)
            % If window is NOT removed because of badchannel (=NaN)
            if isempty(find(isnan(data_window(channel, :))))
                % Calculate PSD
                [P, f] = periodogram(data_window(channel, :),...
                    hann(size(data_window, 2)),...
                    2^(2 + nextpow2(size(data_window, 2))), EEG_trial.srate);
                % Save the power for the frequencies of  the signal
                pow(:, channel, window_id) = P((f(:,1)>=1 & f(:,1)<=48),1);
            else
                pow(:, channel, window_id) = NaN;
            end
        end
        % Increase indices and window (increase sliding window with
        % 0.5*fs).
        window_id = window_id + 1;
        window = window+0.5*EEG_trial.srate;
    end
    
    % Change frequency variable for frequencies of the signal.
    freq = f(f(:,1)>=1 & f(:,1)<=48);
    % Average power per channel over windows.
    power = mean(pow, 3, 'omitnan');

end

% Add NaN in the lines where channels were removed during pre-processing.
function power_array_out = compensateRemovedChannels(power_array_in, EEG, list_channels)

% Array to see which channels are missing.
list_present = zeros(30, 1);

% If there are less than 30 channels.
if size(power_array_in, 1)~=30
    
    % Initialize new power array.
    power_array_out = zeros(size(power_array_in));
    power_array_out(:, 1:size(power_array_in, 2)) = power_array_in;
    % Get the channels present in the signal.
    channels_present = EEG.chanlocs;
    % Go through the lists of channels supposed to be present and channels
    % actually present and mark them as 1 if present and as 0 if not
    % present.
    for i=1:size(list_channels, 1)
        for j=1:size(channels_present, 2)
            if convertCharsToStrings(channels_present(j).labels) == list_channels(i)
                list_present(i) = 1;
                break;
            end
        end
    end
    
    numMissing=0;
    % For the non-present channels, put NaN value in them and update the
    % rest of the values.
    for k=1:size(list_present, 1)
        if list_present(k)==0
            numMissing = numMissing+1;
            power_array_out(:, k) = NaN;
            for x=k+1:size(power_array_in, 2)       
                power_array_out(:, x)=power_array_in(:, x-numMissing);
            end
        end
    end
    power_array_out(:, 30:-1:30-numMissing+1) =...
        power_array_in(:, size(power_array_in,2):-1:size(power_array_in, 2)-numMissing+1);
else
    power_array_out = power_array_in;
end

end