function Diff = compareRGB(waveform1,waveform2)
%% This is a function used to find the difference between RGB channel at the same spot / same region
% Author: Bo Yu Huang 
% Title:  RGB difference finding and BPM calculation
% Date:   2017.12.5

% Date : 2018.7.30
% Add function => peak to peak constraint with samplingRate/2 which means ??? bpm
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
        
    eval(['Diff(1,',num2str(i),') = samplingRate/mean(interval_',num2str(i),')*60;']);
    
%     eval(['interval_sec',num2str(i),' = interval_',num2str(i),'/samplingRate;']); 
%     eval(['N = length(interval_sec',num2str(i),');']);
%     eval(['sum',num2str(i),' = sum(','interval_sec',num2str(i),');']);
%     eval(['avg_interval_sec',num2str(i),'=sum',num2str(i),'/N;']);
%     eval(['bpm',num2str(i),'= 60/avg_interval_sec',num2str(i),';']);
%     eval(['Diff(1,',num2str(i),') = bpm',num2str(i),';']);

end

% Showing the interval to display the peak to peak frame
interval_1
interval_2
end