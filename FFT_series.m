function ratio = FFT_series(waveform,outDir,filename,part)
% author : Bo-Yu Huang 
% date   : 2018/8/16
% This is a function used to perform fast fourier transform 
% To acquire possible heart beat and LF/HF ratio
% waveform : raw data series

% https://nl.mathworks.com/help/matlab/ref/fft.html
% Date : 2018.8.17
% Add function to extract LF¡BHF component
% LF : 0.04~0.15 Hz
% HF : 0.15~0.4  Hz

% Date : 2018.11.20
% Delete the LF/HF calculation
%% FFT
global samplingRate    % fps samplingRate 
             
L = length(waveform);    % Length of raw data

Y = fft(waveform);

p2 = abs(Y/L);
p1 = p2(1:L/2+1);
p1(2:end-1) = 2*p1(2:end-1);

f = samplingRate*(0:(L/2))/L;
[max_amp,loc] = max(p1);
max_freq = f(loc);

%% ploting
figure
plot(f,p1);
axis([0 5 min(p1) max(p1)])  % axis([0 15 min(p1) max(p1)])
title('Single-Sided Amplitude Spectrum');
xlabel('f (Hz)');
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

saveas(gca,[outDir '/' filename '-' part '.png']);

%% double-sided
% figure 
% f = samplingRate/2*linspace(-1,1,length(Y)); % confined within -15 to 15
% plot(f,p2) 
% title('Double-Sided Amplitude Spectrum of rcheek_r')
% xlabel('f (Hz)')
% ylabel('|P2(f)|')
end