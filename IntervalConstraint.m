function interval = IntervalConstraint(waveform)
%% 
% This function is used to set the lower limit to each local peak interval (20 bpm) 
% and 120bpm is the highest bpm
% Author : Bo Yu Huang
% Date : 2018.7.14
% title : Frame interval constraint
global samplingRate

% Date : 2018.7.19
% Add lower limit and minus the reduntant part, then put it into the next peak

%% Testing lower than 120 bpm
% waveform = [13 18 22 24 29 23 26 13 22 29 19 14 18 18 18 24 18 16 19 24 17 17 19 8 19 10 19 13 16 17 16 18 27 19 12 18 14 16 16 14 20 27 16 19 20 31 ];
L = length(waveform);
count = 0;
for i = 1:L-2
    %i
    if waveform(i-count + 1) < samplingRate/2
        if waveform(i-count + 1) == 0
            break;
        end
        count = count + 1;
        waveform(i-count + 2) = waveform(i-count + 2) + waveform(i-count + 3);
        for k = i-count + 1:L-3
            waveform(k + 2) = waveform(k + 3);
            %k
        end
        waveform(L-count+1) = 0;
    end
end
waveform(waveform == 0) = [];
L = length(waveform);
if waveform(L) < samplingRate/2
    waveform(L) = 0;
end
interval = waveform;
%count
%% Testing change lower than 20 bpm
% waveform(waveform == 0) = [];
% L = length(waveform);
% count = 0;
% for i = 1:L-1
%     i
%     %low_bpm = samplingRate / waveform(i-count)*60 - 20;
%     high_bpm = samplingRate / waveform(i-count)*60 + 20;
%     %low_frame = samplingRate*60/low_bpm
%     high_frame = samplingRate * 60 / high_bpm
%     
%     if waveform(i-count + 1) < high_frame
%         if waveform(i) == 0
%             break;
%         end
%         count = count + 1;
%         waveform(i-count + 1) = waveform(i-count + 1) + waveform(i-count + 2)
%         for k = i-count + 1:L-2
%             waveform(k + 1) = waveform(k + 2)
%             k
%         end
%         waveform(L-count+1) = 0
%     end
% end
end