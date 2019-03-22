function ratio = FFT_interval(interval,outDir,filename)
% author : Bo-Yu Huang 
% date   : 2018/11/20
% This is a function used to perform fast fourier transform on interval combining five videos 
% To acquire possible heart beat and LF/HF ratio
% interval : raw data series from five consecutive videos

% date : 2018/11/28
% Add LF, HF area calculation and drawing
% source: https://www.mathworks.com/matlabcentral/answers/314470-how-can-i-calculate-the-area-under-a-graph-shaded-area

% https://nl.mathworks.com/help/matlab/ref/fft.html
% LF : 0.04~0.15 Hz
% HF : 0.15~0.4  Hz
global samplingRate    % fps samplingRate

%% LF/HF extraction

% samplingRate/mean(interval) = sampling frequency

L = length(interval);    % Length of raw data
%F = 1*(0:(L/2))/L;
F = samplingRate/mean(interval)*(0:(L/2))/L;
%F = samplingRate/mean(interval).*(0:1/L:1-1/L);

% convert frame interval to ms unit
interval = interval./samplingRate.*1000;

%% fft on RR interval 
Y = fft(interval);

P2 = abs(Y);
%P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

[max_amp,loc] = max(P1);
max_freq = F(loc);

%% ploting
figure('units','normalized','outerposition',[0 0 1 1]);
F(1) = [];P1(1) = [];
plot(F,P1);
axis([0 0.6 min(P1) max(P1)])  % axis([0 1 min(p1) max(p1)])
title('Single-Sided Amplitude Spectrum');
xlabel('f (Hz)');
ylabel('Amplitude');
%ylabel('|P1(f)|');
hold on

plot(max_freq,max_amp,'--gs',...
    'LineWidth',1,...
    'MarkerSize',5,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor',[0.5,0.5,0.5]);

sent1_1 = 'X:';
sent1_2 = num2str(max_freq);
sent1 = strcat(sent1_1,sent1_2);

sent2_1 = 'Y:';
sent2_2 = num2str(max_amp);
sent2 = strcat(sent2_1,sent2_2);

text(max_freq + 0.1,max_amp - 0.03,{sent1,sent2})

area_1 = trapz(F(F<=0.04), P1(F<=0.04));
area_2 = trapz(F(F<=0.15), P1(F<=0.15));
area_3 = trapz(F(F<=0.4), P1(F<=0.4));

for i = 1:length(F)
    if F(i) < 0.04 && 0.04 < F(i+1)
        L1 = i;
    end
    if F(i) < 0.15 && 0.15 < F(i+1)
        L2 = i;
    end
    if F(i) < 0.4 && 0.4 < F(i+1)
        L3 = i;
    end
end

nLF = L2-L1;
nHF = L3-L2;
for i=1:nLF
    eval(['ha1 = area([F(L1+',num2str(i),'-1',') F(L1+',num2str(i),')], [P1(F == F(L1+',num2str(i),'-1',')) P1(F == F(L1+',num2str(i),'))], "FaceColor","g")']);
end
for i=1:nHF
    eval(['ha2 = area([F(L2+',num2str(i),'-1',') F(L2+',num2str(i),')], [P1(F == F(L2+',num2str(i),'-1',')) P1(F == F(L2+',num2str(i),'))], "FaceColor","r")']);
end
legend([ha1 ha2], 'LF area', 'HF area') 
saveas(gca,[outDir '/' filename '-PSD.png']);

LF = sum(P1(L1 + 1:L2));
HF = sum(P1(L2 + 1:L3));
ratio(1) = LF/HF;
LF_area = area_2 - area_1;
HF_area = area_3 - area_2;
ratio(2) = LF_area/HF_area;
end