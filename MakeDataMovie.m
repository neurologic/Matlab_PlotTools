%make movie from data
%KP_B136_131205_p2c2
load([r.Dir.Expt 'KP_B130_131120_p1c2d'])
sigexpt = filtesweeps(expt,0,'wavnames',expt.stimcond(1).wavnames);
vmexpt = filtesweeps(sigexpt,0,'Vm',0);

tmpvmdata = vmexpt.wc.data;
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