 
function SigTimeBox(hl, sigon, sigoff, ylims,color)
%sigon and sigoff are indices not real time
axes(hl);
% if regexp(color,'gray')
%     colorind = [0.9 0.9 0.9];
% elseif regexp(color, 'red')
%     colorind = [1, 0.5, 0.5];
% elseif regexp(color, 'black')
%     colorind = [0.5 0.5 0.5];
% elseif regexp(color, 'blue')
%     colorind = [0.5, 0.5, 1];
% end
patch([sigon sigon sigoff sigoff],...
    [min(ylims) max(ylims) max(ylims) min(ylims)],...
    [-.1 -.1 -.1 -.1], color,....
    'EdgeColor','none','FaceAlpha',0.5);
