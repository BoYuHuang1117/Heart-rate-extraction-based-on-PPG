function [] = MLwriter(v1,v2,v3,v4,v5,v6,v7,v8,v9,filename)
% author : Bo-Yu Huang 
% date   : 2018/9/28
% This is a function used to write down the red channel information of
% cardio-activity in the xlsx file. Further use will be reading the data from xlsx file in ML model.
% v1-v9 : matrix containing cardio-features of each video
% filename : name of subject (include subject name and date)
% sheet : filming features

for i = 1:9
    eval(['bpm','(',num2str(i),',:) = v',num2str(i),'(1,:);']);
end
bpm = num2cell(bpm);
header = {'Heart rate','SDNN','R-MSSD','LF/HF'};
%header = {'Heart rate','SDNN','R-MSSD','LF/HF','Spo2','working time','EKG-SDNN','EKG R-MSSD','EKG LF/HF','Label'};
file = [filename,'.xlsx'];
xlswrite(file,[header;bpm]);
