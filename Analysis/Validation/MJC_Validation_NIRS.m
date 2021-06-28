clear, close all
%% Settings

addpath (fullfile(pwd,'..')) %add the path with analysis scripts
% add path to correct folders and open eeglab
laptop = 'laptopJoao';
[mainpath_in, ~, eeglab_path] = addFolders(laptop);
mainpath_in=fullfile(mainpath_in,'processed');
mainpath_out = 'C:\Users\joaop\OneDrive - Universidade do Porto\Erasmus\Internship\Experiment\Combined-EEG-fNIRS-system\Analysis\Validation';

mainpath_in_nirsonly='C:\Users\joaop\OneDrive - Universidade do Porto\Erasmus\Internship\Experiment\Data\Validation Data\NIRS';

fig_dir=fullfile(mainpath_out,'Fig_Validation_NIRS');
if ~isfolder(fig_dir)
    mkdir(fig_dir);
end

val_dir=fullfile(mainpath_out,'NIRS');
if ~isfolder(val_dir)
    mkdir(val_dir);
end
%% select ID number and cap
subjects_comb=[{'28','64'}];
subject_nirs_only=[{'19','21'}];%,'43','69','84'



%% LOAD COMBINED CAP DATA
% CONDITION 1 - NIRS ONLY
% CONDITION 2 - COMBINED CAP
for iSub = 1:size(subjects_comb,2)
    %% 1. Info
    sub = char(subjects_comb(iSub));
    
    load(fullfile(mainpath_in,'..','pre-processed',['sub-',sub],'3d','layout.mat'));
    cfg=[];
    cfg.layout=layout;
    ft_layoutplot(cfg); 
    sub_dir=fullfile(mainpath_out,['sub-',sub]);
    if ~isfolder(sub_dir)
        mkdir(sub_dir);
    end
    
    
    switch sub
        case '28'
            rec='02';
        case '64'
            rec='01';
        case '02'
            rec='02';
    end
    
    
    task_label={'AutoDualCue','AutoSingleCue','NonAutoDualCue',...
        'NonAutoSingleCue','AutoDualNoCue','AutoSingleNoCue',...
        'NonAutoDualNoCue','NonAutoSingleNoCue'};
    %% 2. Load pre-processed data
    cap=2;
    load(fullfile(mainpath_in,['sub-',sub],'nirs',['data_TL_blc.mat']));
    % Use only finger non auto single no cue - task 8
    data_all{cap}{iSub}=data_TL_blc{8};
end
% %% 2. Run time-lock and baseline if it hasn't beend one
% % these steps are necessary for the multisubject_averaging script!
% % a) timelock
% for s = 1:length(subject_nirs_only)
%     load(fullfile(mainpath_in_nirsonly, ['sub-',subject_nirs_only{s}], 'data_conc'));
%     for task=1:4 %There are 4 tasks (handauto, handnonauto, footauto, footnonauto)
%         cfg               = [];
%         cfg.trials        = find(data_conc.trialinfo(:,1)==task); % Average the data for given task
%         data_TL{task} = ft_timelockanalysis(cfg, data_conc);
%     end
%     save(fullfile(mainpath_in_nirsonly, ['sub-',subject_nirs_only{s}], 'data_TL.mat'), 'data_TL');
% 
%     % b) apply a baseline correction
%     for task=1:4
%         cfg                 = [];
%         cfg.baseline        = [-10 0]; % define the amount of seconds you want to use for the baseline
%         data_TL_blc{task}     = ft_timelockbaseline(cfg, data_TL{task});
%     end
%     save(fullfile(mainpath_in_nirsonly, ['sub-',subject_nirs_only{s}], 'data_TL_blc.mat'), 'data_TL_blc');
% end
%% 3. Store baseline and timelockanalysis data of all subjects into one cell array

for s = 1:length(subject_nirs_only)
    cap=1;
    load(fullfile(mainpath_in_nirsonly, ['sub-',subject_nirs_only{s}], 'data_TL_blc'));
    data_all{cap}{s}=data_TL_blc{cap};
end
 
%% 4. Average over all subjects -> for each condition seperately!
% condition 1: nirs only cap, condition 2: combined cap
for cap=1:2
cfg=[];
grandavg{cap}= ft_timelockgrandaverage(cfg, data_all{cap}{:});
end
save(fullfile(val_dir,'grandavg.mat'),'grandavg');

%% 5. Plot the data

% d) Separate O2Hb and HHb channels (only for cap 1, cap 2 as been done)
for cap=1:2
    cfg=[];
    cfg.channel='* [O2Hb]';
    data_TL_O2Hb{cap}=ft_selectdata(cfg, grandavg{cap});
    % and rename labels such that they have the same name as HHb channels
    for i=1:length(data_TL_O2Hb{cap}.label)
        tmp = strsplit(data_TL_O2Hb{cap}.label{i});
        data_TL_O2Hb{cap}.label{i}=tmp{1};
    end
    save(fullfile(val_dir,'data_TL_O2Hb.mat'),'data_TL_O2Hb');
    
    % The same for HHb channels
    cfg=[];
    cfg.channel='* [HHb]';
    data_TL_HHb{cap}=ft_preprocessing(cfg, grandavg{cap});
    for i=1:length(data_TL_HHb{cap}.label)
        tmp = strsplit(data_TL_HHb{cap}.label{i});
        data_TL_HHb{cap}.label{i}=tmp{1};
    end
    save(fullfile(val_dir,'data_TL_HHb.mat'),'data_TL_HHb');
end

% f) Plot both on the lay-out
cfg                   = [];
cfg.showlabels        = 'yes';
cfg.layout            = layout;
cfg.interactive       = 'yes'; % this allows to select a subplot and interact with it
cfg.linecolor        = 'rbrbmcmc'; % O2Hb is showed in red (finger) and magenta (foot), HHb in blue (finger) and cyan (foot)
cfg.linestyle = {'--', '--', '-', '-'}; % fingerauto is dashed line, fingernonauto is solid line, footauto is dotted line and footnonauto is a dotted stars line
cfg.comment = 'NIRS is dashed line, COMBINED is solid line';
%cfg.ylim = [-0.440 0.540];
figure;
ft_multiplotER(cfg, data_TL_O2Hb{1}, data_TL_HHb{1}, data_TL_O2Hb{2}, data_TL_HHb{2});

% g) Plot for each task seperately
capname={'NIRS', 'COMBINED'};
%taskshort={'complex', 'stroop'};
for cap=1:2
    cfg                   = [];
    cfg.showlabels        = 'yes';
    cfg.layout            = layout;
    cfg.showoutline       = 'yes';
    cfg.interactive       = 'yes'; % this allows to select a subplot and interact with it
    cfg.linecolor         = 'rb';% O2Hb is showed in red, HHb in blue
   % cfg.ylim = [-0.440 0.540];
%     cfg.colorgroups=contains(data_TL_blc{task}.label, '[O2Hb]')+2*contains(data_TL_blc{task}.label, '[HHb]');
    figure; 
    title(capname{cap}); 
    ft_multiplotER(cfg, data_TL_O2Hb{cap}, data_TL_HHb{cap})
%     saveas(gcf, [char(taskshort(task)) '_timelock.jpg']);
end


%% 5. Statistical testing
con_names={'finger auto',  'finger nonauto', 'foot auto', 'foot nonauto'};
for i=1:4 % loop over the 4 conditions
  [stat_O2Hb, stat_HHb] = statistics_withinsubjects(grandavg{i}, 'grandavg', layout, i, con_names{i});
end
%% 6. Statistical analysis (not finished yet! still trying things out) 


% T-TEST
% define the parameters for the statistical comparison
cfg = [];
cfg.channel     = 'Rx1-Tx2 [HHb]', 'Rx1-Tx2 [O2Hb]';
cfg.latency     = 'all';
cfg.avgovertime = 'yes';
cfg.parameter   = 'avg';
cfg.method      = 'analytic';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.alpha       = 0.05;
cfg.correctm    = 'no';

Nsub = 17;
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number

stat = ft_timelockstatistics(cfg, grandavg{1}(:), grandavg{2}(:));   % don't forget the {:}!

% t-test with matlab function
chan = 7;
time = [-10 20];

% find the time points for the effect of interest in the grand average data
timesel_fingerauto = find(grandavg{1}.time >= time(1) & grandavg{1}.time <= time(2));
timesel_fingernonauto  = find(grandavg{2}.time >= time(1) & grandavg{2}.time <= time(2));
timesel_footauto = find(grandavg{3}.time >= time(1) & grandavg{3}.time <= time(2));
timesel_footnonauto  = find(grandavg{4}.time >= time(1) & grandavg{4}.time <= time(2));

% select the individual subject data from the time points and calculate the mean
for isub = 1:17
    valuesFA(isub) = mean(data_all{1}{isub}.avg(chan,timesel_fingerauto));
    valuesFNA(isub)  = mean(data_all{2}{isub}.avg(chan,timesel_fingernonauto));
    valuesFOA(isub) = mean(data_all{3}{isub}.avg(chan,timesel_fingerauto));
    valuesFONA(isub)  = mean(data_all{4}{isub}.avg(chan,timesel_fingernonauto)); 
end

% plot to see the effect in each subject
M = [valuesFA(:) valuesFNA(:)];
figure; plot(M', 'o-'); xlim([0.5 2.5])
%legend({'subj1', 'subj2', 'subj3', 'subj4', 'subj5', 'subj6', ...
        %'subj7', 'subj8', 'subj9', 'subj10'}, 'location', 'EastOutside');

FAminFNA = valuesFA - valuesFNA;
FOAminFONA = valuesFOA - valuesFONA;
FAminFOA = valuesFA - valuesFOA;
[h,p,ci,stats] = ttest(FAminFNA, 0, 0.05) % H0: mean = 0, alpha 0.05
[h,p,ci,stats] = ttest(FOAminFONA, 0, 0.05)
[h,p,ci,stats] = ttest(FAminFOA, 0, 0.05)


%loop over channels
time = [-10 20];
timesel_fingerauto = find(grandavg{1}.time >= time(1) & grandavg{1}.time <= time(2));
timesel_fingernonauto  = find(grandavg{2}.time >= time(1) & grandavg{2}.time <= time(2));
timesel_footauto = find(grandavg{3}.time >= time(1) & grandavg{3}.time <= time(2));
timesel_footnonauto = find(grandavg{4}.time >= time(1) & grandavg{4}.time <= time(2));
clear h p

%FAminFNA = zeros(1,17);
FAminFOA = zeros(1,17);

for iChan = 1:8
    for isub = 1:17
        FAminFOA(isub) = ...
            mean(data_all{1}{isub}.avg(iChan,timesel_fingerauto)) - ...
            mean(data_all{3}{isub}.avg(iChan,timesel_footauto));
    end

    [h(iChan), p(iChan)] = ttest(FAminFOA, 0, 0.05 ) % test each channel separately
end







