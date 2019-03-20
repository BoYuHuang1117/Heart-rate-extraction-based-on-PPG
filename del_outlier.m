function new_interval = del_outlier(interval)
% author : Bo-Yu Huang 
% date   : 2018/11/27
% This is a function used to delete outlier that 12 frames (0.1 second) higher or lower 
% than average interval frame number 
% interval : raw interval data series from five consecutive videos

% Use median instead of average value
% date: 2018/12/3
% average deletion 20%~50%

middle = median(interval);
%avg = mean(interval);
j = 0;
for i = 1:length(interval)
    if interval(i) < middle + 18 && interval(i) > middle - 18
        j = j + 1;
        new_interval(j) = interval(i);
    end
end

end