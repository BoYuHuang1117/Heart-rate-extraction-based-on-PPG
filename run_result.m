%% ROI
dataDir = './2.22¦¿«Ø¿«';
inFile = fullfile(dataDir,'1.mp4');

fprintf('Processing %s\n', inFile);
Transform_face('2.22¦¿«Ø¿«',inFile,30);

inFile = fullfile(dataDir,'2.mp4');

fprintf('Processing %s\n', inFile);
Transform_face('2.22¦¿«Ø¿«',inFile,30);

inFile = fullfile(dataDir,'3.mp4');

fprintf('Processing %s\n', inFile);
Transform_face('2.22¦¿«Ø¿«',inFile,30);

inFile = fullfile(dataDir,'4.mp4');

fprintf('Processing %s\n', inFile);
Transform_face('2.22¦¿«Ø¿«',inFile,30);

inFile = fullfile(dataDir,'5.mp4');

fprintf('Processing %s\n', inFile);
Transform_face('2.22¦¿«Ø¿«',inFile,30);
%% run
dataDir = '2.22¦¿«Ø¿«';

inFile = fullfile(dataDir,'1_Trim_1.avi');
fprintf('Processing %s\n', inFile);

[sub_1,int1] = Produce1('2.22¦¿«Ø¿«/1','sub6',inFile,5/6,2,30);

inFile = fullfile(dataDir,'1_Trim_2.avi');
fprintf('Processing %s\n', inFile);

[sub_2,int2] = Produce1('2.22¦¿«Ø¿«/2','sub6',inFile,5/6,2,30);

inFile = fullfile(dataDir,'2.avi');
fprintf('Processing %s\n', inFile);

[sub_3,int3] = Produce1('2.22¦¿«Ø¿«/3','sub6',inFile,5/6,2,30);

inFile = fullfile(dataDir,'3.avi');
fprintf('Processing %s\n', inFile);

[sub_4,int4] = Produce1('2.22¦¿«Ø¿«/4','sub6',inFile,5/6,2,30);

inFile = fullfile(dataDir,'4.avi');
fprintf('Processing %s\n', inFile);

[sub_5,int5] = Produce1('2.22¦¿«Ø¿«/5','sub6',inFile,5/6,2,30);

inFile = fullfile(dataDir,'5.avi');
fprintf('Processing %s\n', inFile);

[sub_6,int6] = Produce1('2.22¦¿«Ø¿«/6','sub6',inFile,5/6,2,30);

interval = [int1 int2 int3 int4 int5 int6];
new_interval = del_outlier(interval);

ratio = pwelch_interval(new_interval,'2.22¦¿«Ø¿«','sub6');
time_Bef = HRV_time(interval);
time_Aft = HRV_time(new_interval);
%% ploting
plotRR('2.22¦¿«Ø¿«',interval,new_interval)