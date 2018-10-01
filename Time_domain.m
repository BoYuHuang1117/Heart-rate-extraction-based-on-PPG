function Time = Time_domain(waveform1,waveform2)
%% This is a function used to find the difference between RGB channel at the same spot / same region
% Author: Bo Yu Huang 
% Title:  Time domain indicator calculation
% Date:   2017.8.9

% 正常值 :
% http://www.360doc.com/content/16/0217/14/7654794_535243532.shtml

% Time_domain(:,1) => SDNN   正常心跳間期的標準偏差
% Time_domain(:,2) => R-MSSD 正常心跳間期差值平方和的均方根
% https://www.biopac.com/application/ecg-cardiology/advanced-feature/rmssd-for-hrv-analysis/

% Time_domain(:,3) => NN50
% Time_domain(:,4) => PNN50
%% Find the interval 
global samplingRate    % From Produce1.m 
for i = 1:2   % 2 is according to the number of interested channels
    eval(['interval_',num2str(i),' = captureinterval(waveform',num2str(i),');']);
    
    eval(['interval_',num2str(i),' = IntervalConstraint(interval_',num2str(i),');']);
    eval(['interval_',num2str(i),'(interval_',num2str(i),'== 0 )', '= [];']);
    
    %eval(['L = length(interval_',num2str(i),');']);
    %eval(['interval_',num2str(i),'(L) = [];']);
    %eval(['interval_',num2str(i),'(L-1) = [];']);
    eval(['interval_',num2str(i),'(1) = [];']);
    eval(['L = length(interval_',num2str(i),');']);
    
    % convert frame interval to ms unit
    eval(['interval_',num2str(i),' = interval_',num2str(i),'./samplingRate.*1000;']);
    
    % SDNN
    eval(['Time(',num2str(i),',1) = std(interval_',num2str(i),');']);
    
    % R-MSSD
    eval(['s',num2str(i),'= 0;']);
    for k = 2:L
        eval(['s',num2str(i),'= s',num2str(i),'+ (interval_',num2str(i),...
            '(',num2str(k),')-interval_',num2str(i),'(',num2str(k-1),'))^2;']);
    end
    eval(['Time(',num2str(i),',2) = sqrt(s',num2str(i),'/(L-1));']);
    
    
end
end