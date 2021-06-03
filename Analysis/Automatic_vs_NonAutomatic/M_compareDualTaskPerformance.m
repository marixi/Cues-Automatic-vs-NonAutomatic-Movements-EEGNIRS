%% Comparison of the performance under the dual-tasking condition.

clear; clc; close all;
addpath('C:\Users\maria\OneDrive\Documentos\GitHub\Combined-EEG-fNIRS-system\Analysis');

laptop = 'laptopMariana';
[mainpath_in, mainpath_out, eeglab_path] = addFolders(laptop);

subrec = ["02" "02"; "03" "02"];

autodual_finalAverageMistakes_cued = 0;
autodual_finalAverageMistakes_uncued = 0;
nonautodual_finalAverageMistakes_cued = 0;
nonautodual_finalAverageMistakes_uncued = 0;

% Go through every subject.
for subject = 1:size(subrec, 1)
    sub = subrec(subject, 1);
    rec = subrec(subject, 2);
    
    subvar = genvarname(sub);

    % Load the subject's results.
    load([mainpath_in, '\source\sub-', char(sub), '\stim\results_sub-',...
        char(sub), '_rec-', char(rec), '.mat']);
    
    %% Automatic sequence.
    % Check if counting answers from automatic sequence were correct.
    autodual_correct = checkCorrectCountingPerTrial(events_autodual);

    % Check average number of mistakes per condition (cued and uncued).
    [autodual_averageMistakes_cued, autodual_averageMistakes_uncued] = ...
        averageMistakesPerCondition(events_autodual, autodual_correct);
    
    % Add values to final average (all subjects).
    autodual_finalAverageMistakes_cued =...
        autodual_finalAverageMistakes_cued + autodual_averageMistakes_cued;
    autodual_finalAverageMistakes_uncued =...
        autodual_finalAverageMistakes_uncued + autodual_averageMistakes_uncued;
    
    %% Non-automatic sequence.
    % Check if counting answers from non-automatic sequence were correct.
    nonautodual_correct = checkCorrectCountingPerTrial(events_nonautodual);

    % Check average number of mistakes per condition (cued and uncued).
    [nonautodual_averageMistakes_cued, nonautodual_averageMistakes_uncued] = ...
        averageMistakesPerCondition(events_nonautodual, nonautodual_correct);
    
    % Add values to final average (all subjects).
    nonautodual_finalAverageMistakes_cued =...
        nonautodual_finalAverageMistakes_cued + nonautodual_averageMistakes_cued;
    nonautodual_finalAverageMistakes_uncued =...
        nonautodual_finalAverageMistakes_uncued + nonautodual_averageMistakes_uncued;
    
    %% Put values of error into final struct.
    % Values for the current subject.
    s.autodual_avgMistakes_cued = autodual_averageMistakes_cued;
    s.autodual_avgMistakes_uncued = autodual_averageMistakes_uncued;
    s.nonautodual_avgMistakes_cued = nonautodual_averageMistakes_cued;
    s.nonautodual_avgMistakes_uncued = nonautodual_averageMistakes_uncued;
    
    % Add struct of current subject to all subjects struct.
    allsubs.(genvarname(strcat('sub', char(sub)))) = s;
    
    % Add average values of all subjects to final struct.
    average.autodual_avgMistakes_cued = autodual_finalAverageMistakes_cued/size(subrec, 1);
    average.autodual_avgMistakes_uncued = autodual_finalAverageMistakes_uncued/size(subrec, 1);
    average.nonautodual_avgMistakes_cued = nonautodual_finalAverageMistakes_cued/size(subrec, 1);
    average.nonautodual_avgMistakes_uncued = nonautodual_finalAverageMistakes_uncued/size(subrec, 1);
    allsubs.avg = average;
   
end

%% Functions necessary

function dual_correct = checkCorrectCountingPerTrial(events_dual)
% For each trial see if the counting response was equal to the actual
% number of G's.

dual = events_dual.trial;
dual_correct = zeros(1, length(dual));

for trial = 1:length(dual)
    stimuli = dual(trial).stimuli;
    if count(cell2mat(stimuli.value),'G') == str2num(cell2mat(stimuli.response))
        dual_correct(trial) = 1;
    end
end

end

function [dual_averageMistakes_cued, dual_averageMistakes_uncued] = ...
    averageMistakesPerCondition(events_dual, dual_correct)
% Check average number of mistakes per condition (cued and uncued).

dual = events_dual.trial;
dual_mistakes_cued = 0;
dual_mistakes_uncued = 0;

for trial = 1:length(dual)
    if dual_correct(trial) == 0 && dual(trial).cue == 1
        dual_mistakes_cued = dual_mistakes_cued + 1;
    elseif dual_correct(trial) == 0 && dual(trial).cue == 0
        dual_mistakes_uncued = dual_mistakes_uncued + 1;
    end
end
dual_averageMistakes_cued = dual_mistakes_cued/(length(dual)/2);
dual_averageMistakes_uncued = dual_mistakes_uncued/(length(dual)/2);

end