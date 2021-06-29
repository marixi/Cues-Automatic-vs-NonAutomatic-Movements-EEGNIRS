clear, close all
%% Settings

addpath (fullfile(pwd,'..')) %add the path with analysis scripts
% add path to correct folders and open eeglab
laptop = 'laptopJoao';
[mainpath_in, ~, eeglab_path] = addFolders(laptop);
mainpath_in=fullfile(mainpath_in,'pre-processed');
mainpath_out = 'C:\Users\joaop\OneDrive - Universidade do Porto\Erasmus\Internship\Experiment\Data\Exp\processed';

% select ID number and cap
subject=[{'02','64','28'}];
subject_nirs_only=[{'03','04','10'}];%,'11','12',}];


for iSub = 1:size(subject,2)
    %% 1. Info
    sub = char(subject(iSub));
    
    load(fullfile(mainpath_in,['sub-',sub],'3d','layout.mat'));
    sub_dir=fullfile(mainpath_out,['sub-',sub]);
    if ~isfolder(sub_dir)
        mkdir(sub_dir);
    end
    
    fig_dir=fullfile(sub_dir,'Fig_Topoplot');
    if ~isfolder(fig_dir)
        mkdir(fig_dir);
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
    
    load(fullfile(mainpath_in,['sub-',sub],'nirs',['sub-',sub,'_rec-',rec,'_nirs_preprocessed.mat']));

    
    
    %% 3. Visualize data 
    h=multiplot_condition(nirs_preprocessed, layout, [1:8], task_label, ....
        'baseline', [-10 0], 'trials', true, 'topoplot', 'yes');

    %% 4. Timelock analysis + baselinecorrection
    % these steps are necessary for the multisubject_averaging script!
    % a) timelock
    
    for task=1:8 %There are 8 tasks
        cfg               = [];
        cfg.trials        = find(nirs_preprocessed.trialinfo(:,1)==task); % Average the data for given task
        data_TL{task}     = ft_timelockanalysis(cfg, nirs_preprocessed);
    end
    save(fullfile(sub_dir,'nirs','data_TL.mat'), 'data_TL');

    % b) apply a baseline correction
    for task=1:8
        cfg                 = [];
        cfg.baseline        = [-10 0]; % define the amount of seconds you want to use for the baseline
        data_TL_blc{task}     = ft_timelockbaseline(cfg, data_TL{task});
    end
    save(fullfile(sub_dir,'nirs','data_TL_blc.mat'),'data_TL_blc');
    
    %% 5. Take the HbO activity only
    data_labels=nirs_preprocessed.label;
    for task=1:8
        cfg=[];
        cfg.channel='*[O2Hb]';
        data_O2Hb{task}=ft_selectdata(cfg, data_TL_blc{task});
        data_O2Hb{task}.label=data_labels(contains(data_TL_blc{task}.label, '[O2Hb]'));
        for ii=1:length(data_O2Hb{task}.label)
            label=data_O2Hb{task}.label{ii};
            label=label(1:end-7);
            data_O2Hb{task}.label{ii}=label;
        end
    end
    

    %% 6. Topoplot
    cfg          = [];
    cfg.layout   = layout;
    cfg.marker   = 'labels';
     % Choose the time window over which you want to average
    for task=1:8
        cfg.xlim     = [5 10];
        cfg.zlim     = [ ];
        figure;
        title(task_label{task})
        ft_topoplotER(cfg, data_O2Hb{task});
        saveas(gcf,fullfile(fig_dir,['sub-',sub,'_topoplot_',task_label{task},'.jpg']))
    end
    
    
end