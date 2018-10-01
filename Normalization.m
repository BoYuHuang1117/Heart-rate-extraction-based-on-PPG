function output = Normalization(input)
%% 
% This function is to normal the data
% Author : Bo Yu Huang
% Date : 2018.7.31
% title : Normalization

%% [I-mean(I)] / sigma(I)
output = (input - mean(input)) / std(input);
end