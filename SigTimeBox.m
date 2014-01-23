 
function SigTimeBox(hl, sigon, sigoff, ylims)
axes(hl);
patch([sigon sigon sigoff sigoff],[min(ylims) max(ylims) max(ylims) min(ylims)],[-.1 -.1 -.1 -.1], [0.9 0.9 0.9],'EdgeColor','none');
