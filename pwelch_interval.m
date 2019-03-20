function ratio = pwelch_interval(interval,outDir,filename)
% author : Bo-Yu Huang 
% date   : 2019/3/18
% This is a function used to perform welch spectrum analysis on interval combining five videos 
% To acquire possible heart beat and LF/HF ratio
% interval : raw data series from five consecutive videos

% date : 2019/3/X
% Add LF, HF area calculation and drawing
% source: https://www.mathworks.com/matlabcentral/answers/314470-how-can-i-calculate-the-area-under-a-graph-shaded-area

% LF : 0.04~0.15 Hz
% HF : 0.15~0.4  Hz
global samplingRate    % fps samplingRate

interval_sec = interval/samplingRate*1000;
interval_sec = transpose(interval_sec);
[pw,w] = pwelch(interval_sec,length(interval_sec)/3,[],2^14,1/mean(interval_sec)*1000);
for i = 1:length(w)
    if w(i) < 0.04 && 0.04 < w(i+1)
        L1 = i;
    end
    if w(i) < 0.15 && 0.15 < w(i+1)
        L2 = i;
    end
    if w(i) < 0.4 && 0.4 < w(i+1)
        L3 = i;
    end
end
pwelch(interval_sec,length(interval_sec)/3,[],2^14,1/mean(interval_sec)*1000);
hold on

area_1 = trapz(w(w<=0.04), pw(w<=0.04));
area_2 = trapz(w(w<=0.15), pw(w<=0.15));
area_3 = trapz(w(w<=0.4), pw(w<=0.4));

%% Drawing area 
% nLF = L2-L1;
% nHF = L3-L2;
% for i=1:nLF
%     eval(['ha1 = area([w(L1+',num2str(i),'-1',') w(L1+',num2str(i),')], [pw(w == w(L1+',num2str(i),'-1',')) pw(w == w(L1+',num2str(i),'))], "FaceColor","g")']);
% end
% for i=1:nHF
%     eval(['ha2 = area([w(L2+',num2str(i),'-1',') w(L2+',num2str(i),')], [pw(w == w(L2+',num2str(i),'-1',')) pw(w == w(L2+',num2str(i),'))], "FaceColor","r")']);
% end
% legend([ha1 ha2], 'LF area', 'HF area') 

%% draw line on 0.04 & 0.15 & 0.4
x=40;
y=0:0.1:10*log10(max(pw));
line([x x],[y(1) y(end)],'LineWidth',1,'Color','red');

x=150;
line([x x],[y(1) y(end)],'LineWidth',1,'Color','red');

x=400;
line([x x],[y(1) y(end)],'LineWidth',1,'Color','red');

saveas(gca,[outDir '/' filename '-PSD.png']);

%% 
LF = sum(pw(L1 + 1:L2));
HF = sum(pw(L2 + 1:L3));
ratio(1) = LF/HF;

LF_area = area_2 - area_1;
HF_area = area_3 - area_2;
ratio(2) = LF_area/HF_area;
end