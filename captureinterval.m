function interval = captureinterval(waveform)
%% This is a function used to find the interval of local peak value
% Author: Bo Yu Huang 
% Title:  RR finding 
% Date:   2017.12.4

% Date : 2018.7.
% Add minumum threshold constraint according to maximum RGB signal value
%% Potential threshold

%% Get the frame number
numberofserialframes = zeros(1,100);
N = length(waveform);
frame = 1;
for i = 2 : N-1 
    if waveform(1,i-1) < waveform(1,i) && waveform(1,i) > waveform(1,i+1)
        numberofserialframes(1,frame) = i;
        frame = frame + 1;
    end
end
%% Get the interval frame numbers
for i = 2 : N
    if (numberofserialframes(1,i)-numberofserialframes(1,i-1)) < 0
        break;
    end
    interval(1,i-1) = numberofserialframes(1,i)-numberofserialframes(1,i-1);
end
end