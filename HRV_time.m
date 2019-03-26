function Time = HRV_time(interval)
% author : Bo-Yu Huang 
% date   : 2018/11/27
% This is a function used to calculate SDNN and R-MSSD 
% interval : raw interval data series from five consecutive videos

samplingRate = 120;
L = length(interval);
% convert frame interval to ms unit
interval = interval./samplingRate.*1000;
% SDNN
Time(1) = std(interval);

% R-MSSD
s = 0;
for k = 2:L
    s = s + (interval(k)-interval(k-1))^2;
end
Time(2) = sqrt(s/(L-1));

end