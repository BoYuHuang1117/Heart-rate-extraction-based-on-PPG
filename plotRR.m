function [] = plotRR(outdir,interval,new_interval)
%% This is a function used to find the difference between RGB channel at the same spot / same region
% Author: Bo Yu Huang 
% Title:  RR comparison ploting
% Date:   2019.3.6
%%
figure
x = 1:length(interval);
plot(x,interval/120*1000,'x');
hold on 
plot(length(interval)/2,median(interval)/120*1000,'^r', 'MarkerFaceColor','r');
xx = 1: length(new_interval);
plot(xx,new_interval/120*1000,'--+','MarkerEdgeColor','g');
xlabel('Series of intervals')
ylabel('Milliseconds')
legend('Raw RR interval','Median value','RR interval after processing')
saveas(gca,[outdir '/' 'RR_comparison.png']);

figure
xx = 1: length(new_interval);
plot(xx,new_interval/120*1000,'--+','MarkerEdgeColor','g');
xlabel('Series of intervals')
ylabel('Milliseconds')
legend('RR interval after processing')
saveas(gca,[outdir '/' 'new_RR.png']);

end
