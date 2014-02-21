%make movie from data
%KP_B136_131205_p2c2

%%%%%%%need to remake this without doing anything else on my computer while
%%%%%%%it is running.
%%%%%% also change the trial I am tracing to one that spikes more?
mov_name = 'B130_p1c2_silVstim_v2';
load([r.Dir.Expt 'KP_B130_131120_p1c2d'])
frame_rate = 60;
frame_time = 250;
frame_size = round((frame_time/1000)/expt.wc.dt);
frame_move = 5;
xtime = [1:frame_size]*expt.wc.dt;

load([r.Dir.Expt 'KP_B130_131120_p1c2d'])
sigexpt = filtesweeps(expt,0,'wavnames',expt.stimcond(1).wavnames);
vmexpt = filtesweeps(sigexpt,0,'Vm',0);
silence_data = vmexpt.wc.data(:,expt.analysis.params.baselinewin(1):end)*1000;


load([r.Dir.Expt 'KP_B130_131120_p1c2c'])
sigexpt = filtesweeps(expt,0,'wavnames',expt.stimcond(3).wavnames);
vmexpt = filtesweeps(sigexpt,0,'Vm',0);
[sigon,sigoff] = GetSigTimes(expt,expt.stimcond,3);
stimulus_data = vmexpt.wc.data(:,sigon:size(silence_data,2)+sigon)*1000;

[colvec colsize rowvec rowsize] = subplotinds(1,2);


% ylims = [min(min([silence_data,stimulus_data])),max(max([silence_data,stimulus_data]))];
foldername = '/Users/kperks/GitHub/Data_Mat/Data_Movie/';

writerObj = VideoWriter([foldername mov_name '.mp4'],'MPEG-4');
writerObj.FrameRate = frame_rate;
open(writerObj);
hfig = figure;
pos = [219    96   733   710];
set(hfig,'Position',pos);

ylims(1) = -80;
ylims(2) = 40;
frameind = 1;
for iframe = 1:frame_move:(size(stimulus_data,2)-frame_size)
    hold on
    hs1 = subplot('Position',[colvec(1),rowvec(1),colsize,rowsize]);
    hs2 = subplot('Position',[colvec(2),rowvec(2),colsize,rowsize]);
    this_sil_data = silence_data(: , iframe : round(iframe + frame_size)-1);
    this_stim_data = stimulus_data(: , iframe : round(iframe + frame_size)-1);
    sil_target = this_sil_data(2 , :);%iframe : round(iframe + frame_size)-1);
    sil_other = this_sil_data;%(: , iframe : round(iframe + frame_size)-1);
    stim_target = this_stim_data(6 , :);%iframe : round(iframe + frame_size)-1);
    stim_other = this_stim_data;%(: , iframe : round(iframe + frame_size)-1);
    
    %     line(xtime,this_other,'color','k','LineWidth',1)
    subplot(hs1)
    line(xtime,sil_other,'color','k','LineWidth',1)
    line(xtime,sil_target,'color','r','LineWidth',4)
    set(gca,'YLim',ylims)
    set(gca,'TickDir','out','XTick',[],'YTick',[])
    
    subplot(hs2)
    line(xtime,stim_other,'color','k','LineWidth',1)
    line(xtime,stim_target,'color','r','LineWidth',4)
    set(gca,'YLim',ylims)
    set(gca,'TickDir','out','XTick',[],'YTick',[])
    
    set(gcf,'Renderer','zbuffer');
    
    if iframe ==1
        subplot(hs2)
        ysep = 20;
        set(gca,'XTick',[0:0.05:xtime(end)],'XTickLabel',(1000*[0:0.05:xtime(end)])-frame_time,'YLim',ylims,'YTick',...
            [(floor(ylims(1))-mod(floor(ylims(1)),ysep)):ysep:(ceil(ylims(2))+mod(ceil(ylims(2)),ysep))],...
            'TickDir','out','FontSize',15)
        xlabel('milliseconds')
        ylabel('milliVolts')
        saveas(hfig,[foldername mov_name '_Axis_Frame.png'])
    end
    
    frame = getframe(hfig);
    writeVideo(writerObj,frame);
    clf
    frameind = frameind + 1
    %      close(hfig)
end

close(writerObj);
close(hfig);

%%
mov_expt = {'KP_B130_131120_p1c2d', 'KP_B130_131120_p1c2c'}

load([r.Dir.Expt mov_expt{2}])
[sigon,sigoff]=GetSigTimes(expt,expt.stimcond,1);
basetimes = expt.analysis.params.baselinewin;


cond(1).stimnum = 1;
cond(1).starttime = basetimes(1);
cond(1).stoptime = 74970;
cond(1).color = 'b';

cond(2).stimnum = 3;
cond(2).starttime = sigon;
cond(2).stoptime = sigoff;
cond(2).color = 'r';

hfig = figure;
hold on
for iexpt = 1:length(cond)
    load([r.Dir.Expt mov_expt{iexpt}])
    stimcond = expt.stimcond;
    sigexpt = filtesweeps(expt,0,'wavnames',stimcond(cond(iexpt).stimnum).wavnames);
     vmexpt = filtesweeps(sigexpt,0,'Vm',0);
      sigdata = medfilt1(vmexpt.wc.data,200,[],2);
    sigdata = sigdata(:,cond(iexpt).starttime:cond(iexpt).stoptime)*1000;
    sigdata = reshape(sigdata,1,size(sigdata,1)*size(sigdata,2));
    vm_edges = [-80:2:-30];
    rbins = histc(sigdata,vm_edges)/size(sigdata,2);
    stairs(vm_edges,rbins,'color',cond(iexpt).color,'LineWidth',3)
    
    skew(iexpt) = skewness(sigdata);
    text(-40,0.2,['skewness = ' num2str(skew(iexpt))],'BackgroundColor',...
        cond(iexpt).color,'Color','w')
    
end
ylabel('proportion Vm red = stimulus  blue = silence')
saveas(hfig,[foldername expt.name '_VmDistribution.png'])
saveas(hfig,[foldername expt.name '_VmDistribution.fig'])

hfig = figure;
hold on
for iexpt = 1:length(cond)
    load([r.Dir.Expt mov_expt{iexpt}])
    stimcond = expt.stimcond;
    sigexpt = filtesweeps(expt,0,'wavnames',stimcond(cond(iexpt).stimnum).wavnames);
    vmexpt = filtesweeps(sigexpt,0,'Vm',0);
    sigdata = medfilt1(vmexpt.wc.data,200,[],2);
    sigdata = sigdata(:,cond(iexpt).starttime:cond(iexpt).stoptime)*1000;
    
    sigdata = sigdata - repmat(mean(sigdata,1),size(sigdata,1),1);
    sigdata = reshape(sigdata',1,size(sigdata,1)*size(sigdata,2));
    vm_edges = [-20:2:20];
    rbins = histc(sigdata,vm_edges)/size(sigdata,2);
    stairs(vm_edges,rbins,'color',cond(iexpt).color,'LineWidth',3)
    
    skew(iexpt) = skewness(sigdata);
    text(15,0.3,['skewness = ' num2str(skew(iexpt))],'BackgroundColor',...
        cond(iexpt).color,'Color','w')
    
end
ylabel('proportion Vm red = stimulus  blue = silence')
saveas(hfig,[foldername expt.name '_VmResidualsDistribution.png'])
saveas(hfig,[foldername expt.name '_VmResidualsDistribution.fig'])

highpassdata=HighpassGeneral(sigdata,[],1/expt.wc.dt);
high_thresh = 10;
[spikesmat, gausstosmooth]=getspikesmat(highpassdata,high_thresh,expt);
spiketimes = [];
for itrial=1:size(spikesmat,1)
spiketimes{itrial}=find(spikesmat(itrial,:));
end

vm_edges = [-80:2:-30];
x_bins = vm_edges(1,1:end-1) + mean(diff(vm_edges))/2;

spkwin_size = round((0.05/expt.wc.dt)/2);
spk_ind = 1;
spk_vm{iex} = [];

for itrial=1:size(spikesmat,1)
    spks_trial = spiketimes{itrial};
    for ispike = 1:size(spks_trial,2)
        t1 = spks_trial(ispike);
       
            spk_win = [(t1 - spkwin_size),(t1 + spkwin_size)];
            spk_vm{iex}(spk_ind,:) = sigdata(itrial,spk_win(1):spk_win(2));
            %get peak in this window and re-center based on real spike
            %peak
            spk_peak = find(spk_vm{iex}(spk_ind,:) == max(spk_vm{iex}(spk_ind,:)))+spk_win(1);
            spk_win = [(spk_peak - spkwin_size),(spk_peak + spkwin_size)];
            spk_vm{iex}(spk_ind,:) = sigdata(itrial,spk_win(1):spk_win(2));
            spk_ind = spk_ind +1;
        
    end
end

% plot  spikes
if ~isempty(spk_vm{iex})
    shift_x = find(mean(spk_vm{iex})==max(mean(spk_vm{iex})));
    xtime = ([1:size(spk_vm{iex},2)]-shift_x)*expt.wc.dt;
    
    hfig = figure;
    hold on
    line(xtime,spk_vm{iex}')
    axis tight
    title([expt.name ' : stimulus ' stimcond(stimnum).wavnames ...
        '# baseline spikes = ' num2str(size(spk_vm{iex},1))],'Interpreter','none')
    saveas(hfig,[foldername expt.name '_allSpk.png'])
    saveas(hfig,[foldername expt.name '_allSpk.fig'])
    
    hfig = figure;
    hold on
    line(xtime,mean(spk_vm{iex})')
    axis tight
       spk_thresh(iex) = input('spike threshold?');
    title([expt.name ' : stimulus ' stimcond(stimnum).wavnames ...
        '# spikes = ' num2str(size(spk_vm{iex},1))],'Interpreter','none')
    ylabel(num2str(spk_thresh(iex)))
    saveas(hfig,[foldername expt.name '_meanSpk.png'])
    saveas(hfig,[foldername expt.name '_meanSpk.fig'])
   
    close(hfig)
end


%% plot variance for each of these traces

load([r.Dir.Expt 'KP_B130_131120_p1c2d'])
sigexpt = filtesweeps(expt,0,'wavnames',expt.stimcond(1).wavnames);
vmexpt = filtesweeps(sigexpt,0,'Vm',0);
silence_data = medfilt1(vmexpt.wc.data,200,[],2);
silence_data = silence_data(:,expt.analysis.params.baselinewin(1):end)*1000;

% silence_data = mean(silence_data);
silence_var = medfilt1(var(silence_data),200,[],2);

load([r.Dir.Expt 'KP_B130_131120_p1c2c'])
sigexpt = filtesweeps(expt,0,'wavnames',expt.stimcond(3).wavnames);
vmexpt = filtesweeps(sigexpt,0,'Vm',0);
[sigon,sigoff] = GetSigTimes(expt,expt.stimcond,3);
stimulus_data = medfilt1(vmexpt.wc.data,200,[],2);
stimulus_data = stimulus_data(:,sigon:size(silence_data,2)+sigon)*1000;

% stimulus_data = mean(stimulus_data);
stimulus_var =medfilt1(var(stimulus_data),200,[],2);

hfig = figure ;
set(hfig,'Position',[155         369        1080         429])
hold on
hs(1) = line([1:size(silence_var,2)]*expt.wc.dt, silence_var,'color','b','LineWidth',2)
hs(2) = line([1:size(stimulus_var,2)]*expt.wc.dt, stimulus_var,'color','r','LineWidth',2)
axis tight
legend(hs,{'silence','stimulus'},'FontSize',24)
set(gca,'YLim',[0,110],'YTick',[0:20:110],'FontSize',24)
ylabel('variance across 10 trials','FontSize',24)
xlabel('seconds','FontSize',24)
saveas(hfig,[foldername expt.name '_Variance.png'])
saveas(hfig,[foldername expt.name '_Variance.fig'])

hfig = figure
set(hfig,'Position',[155         369        1080         429])
hs1 = subplot('Position',[colvec(1),rowvec(1),colsize,rowsize]);
line([1:size(silence_data,2)]*expt.wc.dt, silence_data,'color','b','LineWidth',1)
line([1:size(silence_data,2)]*expt.wc.dt, mean(silence_data),'color','k','LineWidth',3)
axis tight
set(gca,'YLim',[-75,-30],'YTick',[],'XTick',[])
hs2 = subplot('Position',[colvec(2),rowvec(2),colsize,rowsize]);
line([1:size(stimulus_data,2)]*expt.wc.dt, stimulus_data,'color','r','LineWidth',1)
line([1:size(stimulus_data,2)]*expt.wc.dt, mean(stimulus_data),'color','k','LineWidth',3)
axis tight
set(gca,'YLim',[-75,-30],'TickDir','out','YTick',[-70:10:-30],'YTickLabel',[],'XTickLabel',[],'FontSize',24)
saveas(hfig,[foldername expt.name '_allTrials.png'])
saveas(hfig,[foldername expt.name '_allTrials.fig'])
%%


sig_xtime = zeros(1,size(tmpvmdata,2));
% tmpvmdata = tmpvmdata(1:15,:);
%  tmpvmdata = medfilt1(tmpvmdata,200,[],2);

%make sig time in case I want to draw SigTimeBox
%times where sig_xtime == 1 needs a time box
%check this for every frame and draw accordingly
sig_xtime = zeros(1,size(tmpvmdata,2));
[sigon,sigoff] = GetSigTimes(expt,expt.stimcond,1);
siginds = [sigon:sigoff];
sig_xtime(:,siginds) = 1;

trial_xtime = zeros(1,size(tmpvmdata,2));
trial_xtime(:,expt.analysis.params.baselinewin(1))=1;

%reshape all
tmpvmdata = tmpvmdata(:,expt.analysis.params.baselinewin(1):end);
sig_xtime = sig_xtime(:,expt.analysis.params.baselinewin(1):end);
trial_xtime = trial_xtime(:,expt.analysis.params.baselinewin(1):end);
vmdata = reshape(tmpvmdata',1,size(tmpvmdata,1)*size(tmpvmdata,2));
vmdata = tmpvmdata * 1000;
sig_xtime = reshape(sig_xtime',1,size(sig_xtime,1)*size(sig_xtime,2));
trial_xtime = reshape(trial_xtime',1,size(trial_xtime,1)*size(trial_xtime,2));

run_otherdata = [];
run_targetdata = [];
run_sigtime = [];
run_trialtime = [];
for itrial = 1:size(vmdata,1)
    run_targetdata = [run_targetdata,vmdata(itrial,:)];
    notinds = find([1:size(vmdata,1)] ~= itrial);
    run_otherdata = [run_otherdata,vmdata(notinds,:)];
    run_sigtime = [run_sigtime,sig_xtime];
    run_trialtime = [run_trialtime,trial_xtime];
end

frame_size = round(0.5/expt.wc.dt);
xtime = [1:frame_size]*expt.wc.dt;
ylims = [min(min(vmdata)),max(max(vmdata))];


writerObj = VideoWriter('/Users/kperks/GitHub/Data_Mat/Data_Movie/40dBTrial_B130p1c2a_FR50.mp4','MPEG-4');
writerObj.FrameRate = 50;
open(writerObj);
hfig = figure;
hold on
ylims(1) = -80;
ylims(2) = 40;
frameind = 1;
for iframe = 1:50:(size(run_targetdata,2)-frame_size)
    this_data = vmdata(1 , iframe : round(iframe + frame_size)-1);
    
    this_target = run_targetdata(1 , iframe : round(iframe + frame_size)-1);
    this_other = run_otherdata(: , iframe : round(iframe + frame_size)-1);
    this_sigtime = run_sigtime(1 , iframe : round(iframe + frame_size-1));
    this_trialtime = run_trialtime(1 , iframe : round(iframe + frame_size-1));
    
    %     line(xtime,this_other,'color','k','LineWidth',1)
    line(xtime,this_data,'color','k','LineWidth',2)
    
    siginds = find(this_sigtime);
    if ~isempty(siginds)
        sigon = min(siginds);
        sigoff = max(siginds);
        
        %         SigTimeBox(gca, sigon*expt.wc.dt,sigoff*expt.wc.dt, ylims,[0.5 0.5 0.5]);
        line([sigon*expt.wc.dt,sigoff*expt.wc.dt],[-75,-75],'color',...
            [0.5 0.5 0.5],'LineWidth',7)
    end
    
    trialind = find(this_trialtime);
    if ~isempty(trialind)
        %         scatter(trialind*expt.wc.dt,ylims(1),100,'k','fill')%'MarkerFaceColor','k','MarkerEdgeColor','k',)
        %         line([trialind*expt.wc.dt,trialind*expt.wc.dt],[ylims(1),ylims(2)],'color','k')
        SigTimeBox(gca, trialind*expt.wc.dt,trialind*expt.wc.dt, ylims,'k');
    end
    
    axis tight
    ysep = 10;
    set(gca,'XTick',[0:0.1:xtime(end)],'XTickLabel',(1000*[0:0.1:xtime(end)])-500,'YLim',ylims,'YTick',...
        [(floor(ylims(1))-mod(floor(ylims(1)),ysep)):ysep:(ceil(ylims(2))+mod(ceil(ylims(2)),ysep))],...
        'TickDir','out','FontSize',20)
    xlabel('milliseconds')
    ylabel('milliVolts')
    
    set(gcf,'Renderer','zbuffer');
    if iframe ==1
        saveas(hfig,['/Users/kperks/GitHub/Data_Mat/Data_Movie/Axis_Frame.png'])
    end
    
    frame = getframe;
    writeVideo(writerObj,frame);
    clf
    frameind = frameind + 1;
    %      close(hfig)
end

close(writerObj);
close(hfig);