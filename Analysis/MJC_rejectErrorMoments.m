function [EEG_out] = MJC_rejectErrorMoments(EEG_in, sub)
% For each subject, check if there is the need to remove any particular
% moment of the recording and remove it if so.

event_samp  = [EEG_in.event.latency];

% Sub-02.
if sub == '02'
    
    % Identify when to remove moment at the end of the automaticity test up
    % until the beggining of the next task - in this case auto single.
    % Get the moment to start cutting.
    endTask_autodual_cued = event_samp(find(strcmp({EEG_in.event.type}, 's1714')==1));
    endTask_autodual_uncued = event_samp(find(strcmp({EEG_in.event.type}, 's1715')==1));
    start_cut1 = max(max(endTask_autodual_cued, endTask_autodual_uncued));
    % Get the moment to end cutting.
    startTask_autosingle_cued = event_samp(find(strcmp({EEG_in.event.type}, 's1702')==1));
    startTask_autosingle_uncued = event_samp(find(strcmp({EEG_in.event.type}, 's1703')==1));
    end_cut1 = min(min(startTask_autosingle_cued, startTask_autosingle_uncued));
    
    % Identify when to remove moment at the start of the non-auto dual
    % task - eliminate first two trials out of 22.
    % Get the moment to start cutting.
    endTask_nonautosingle_cued = event_samp(find(strcmp({EEG_in.event.type}, 's1712')==1));
    endTask_nonautosingle_uncued = event_samp(find(strcmp({EEG_in.event.type}, 's1713')==1));
    start_cut2 = max(max(endTask_nonautosingle_cued, endTask_nonautosingle_uncued));
    % Get the moment to stop cutting.
    startTask_nonautodual_cued = event_samp(find(strcmp({EEG_in.event.type}, 's1708')==1));
    startTask_nonautodual_uncued = event_samp(find(strcmp({EEG_in.event.type}, 's1709')==1));
    startTask_nonautodual = sort([startTask_nonautodual_cued, startTask_nonautodual_uncued]);
    end_cut2 = startTask_nonautodual(3);
    
    % Eliminate the moments from the signal.
    [EEG_out] = eeg_eegrej(EEG_in, [start_cut1+23*EEG_in.srate end_cut1-23*EEG_in.srate; start_cut2+23*EEG_in.srate end_cut2-23*EEG_in.srate]);  

end

StartBlock_AutomaticSequence_Cued = length(find(strcmp({EEG_out.event.type}, 's1702')==1))
StartBlock_AutomaticSequence_Uncued = length(find(strcmp({EEG_out.event.type}, 's1703')==1))
StartBlock_NonAutomaticSequence_Cued = length(find(strcmp({EEG_out.event.type}, 's1704')==1))
StartBlock_NonAutomaticSequence_Uncued = length(find(strcmp({EEG_out.event.type}, 's1705')==1))

StartBlock_AutomaticSequence_Dual_Cued = length(find(strcmp({EEG_out.event.type}, 's1706')==1))
StartBlock_AutomaticSequence_Dual_Uncued = length(find(strcmp({EEG_out.event.type}, 's1707')==1))
StartBlock_NonAutomaticSequence_Dual_Cued = length(find(strcmp({EEG_out.event.type}, 's1708')==1))
StartBlock_NonAutomaticSequence_Dual_Uncued = length(find(strcmp({EEG_out.event.type}, 's1709')==1))

EndBlock_AutomaticSequence_Cued = length(find(strcmp({EEG_out.event.type}, 's1710')==1))
EndBlock_AutomaticSequence_Uncued = length(find(strcmp({EEG_out.event.type}, 's1711')==1))
EndBlock_NonAutomaticSequence_Cued = length(find(strcmp({EEG_out.event.type}, 's1712')==1))
EndBlock_NonAutomaticSequence_Uncued = length(find(strcmp({EEG_out.event.type}, 's1713')==1))

EndBlock_AutomaticSequence_Dual_Cued = length(find(strcmp({EEG_out.event.type}, 's1714')==1))
EndBlock_AutomaticSequence_Dual_Uncued = length(find(strcmp({EEG_out.event.type}, 's1715')==1))
EndBlock_NonAutomaticSequence_Dual_Cued = length(find(strcmp({EEG_out.event.type}, 's1716')==1))
EndBlock_NonAutomaticSequence_Dual_Uncued = length(find(strcmp({EEG_out.event.type}, 's1717')==1))

end