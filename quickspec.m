function [B,f,t] = quickspec(y,fs) %,savevars,spectname)

[B,f,t]=specgram(y,1024,fs,256,192);
% figure
 bmin=max(max(abs(B)))/300;
 imagesc(t,f,20*log10(max(abs(B),bmin)/bmin));
% imagesc(t,f,(abs(B)));
axis xy;
axis tight
xlabel('Time (s)');
ylabel('Frequency (Hz)');
lgrays=zeros(100,3);
for i=1:100
lgrays(i,:) = 1-i/100;
end
% colormap(lgrays);
 colormap(hot);
% if savevars==1
% save(spectname,'B','f','tS')
% end