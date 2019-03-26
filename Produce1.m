function [bpm, RR_interval] = Produce1(Dir,filename,vidFile,fl,fh,fps)
% Author : BoYu Huang
% Date : 2018.5.15
% This is the produce.m version 2.0. Aftering using Transform_face.m 
% to transform video into a fewer pixel one in order to reduce the computation 
% time significantly. However, ROI still include many irrevelent background
% image part.

% Date : 2018.5.25
% Define the region of interest by proportionally selecting the forehead and cheek 
% after face detection 

% Date : 2018.5.27
% Add peak detection (FFT) 
% https://nl.mathworks.com/help/signal/ug/find-peaks-in-data.html

% Date : 2018.7.14
% Add normalization to the signal extracted from the RGB channels
% x'(t) = [x(t) - mean] / sigma 

% Date : 2018.12.3
% https://www.mathworks.com/help/matlab/ref/spline.html#bvjdpi3-xq
% Testing cubic interploation in PPG data after EVM processing 

% Date : 2019.1.22
% Fix face not found problem

% Date : 2018.
% Use HSV or LAB to detect the face region

resultsDir = Dir;
mkdir(resultsDir);

global samplingRate
%% face
outDir = resultsDir;
alpha = 50;
level = 4;
samplingRate = fps;    % Depend on video fps 
chromAttenuation = 1;

[~,vidName] = fileparts(vidFile);

% Build the full file name frome parts 
outName = fullfile(outDir,[vidName  '-ideal-from-' num2str(fl) ...
                       '-to-' num2str(fh) ...
                       '-alpha-' num2str(alpha) ...
                       '-level-' num2str(level) ...
                       '-chromAtn-' num2str(chromAttenuation) '.avi']);


% Read video
vid = VideoReader(vidFile);
% Extract video info
vidHeight = vid.Height;  % set the range to reduce time
vidWidth = vid.Width;    % set the range to reduce time
nChannels = 3;
fr = vid.FrameRate;
len = vid.NumberOfFrames;

% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();

% Read a video frame and run the face detector.
videoFileReader = vision.VideoFileReader(vidFile);
videoFrame      = step(videoFileReader);
bbox            = step(faceDetector, videoFrame);  % bounding box [x,y,width,height]

if (isempty(bbox) == 1 || (bbox(3) < 200 && bbox(4) < 200))
    forehead_box = [int64(0.3*vidWidth),int64(0.05*vidHeight),int64(0.4*vidWidth),int64(0.1*vidHeight)];
    rcheek_box = [int64(0.15*vidWidth),int64(0.55*vidHeight),int64(0.15*vidWidth),int64(0.1*vidHeight)];
    lcheek_box = [int64(0.7*vidWidth),int64(0.55*vidHeight),int64(0.15*vidWidth),int64(0.1*vidHeight)];
    bbox = [0 0 vidWidth vidHeight];
else 
    forehead_box = [int64(bbox(1)+0.3*bbox(3)),int64(bbox(2)+0.05*bbox(4)),int64(0.4*bbox(3)),int64(0.1*bbox(4))];
    rcheek_box = [int64(bbox(1)+0.15*bbox(3)),int64(bbox(2)+0.55*bbox(4)),int64(0.15*bbox(3)),int64(0.1*bbox(4))];
    lcheek_box = [int64(bbox(1)+0.7*bbox(3)),int64(bbox(2)+0.55*bbox(4)),int64(0.15*bbox(3)),int64(0.1*bbox(4))];
end
% Draw the returned bounding box around the detected face.
videoFrame = insertShape(videoFrame, 'Rectangle', bbox);
videoFrame = insertShape(videoFrame, 'Rectangle',forehead_box);
videoFrame = insertShape(videoFrame, 'Rectangle',rcheek_box);
videoFrame = insertShape(videoFrame, 'Rectangle',lcheek_box);
figure; imshow(videoFrame); title('Detected face');

% create a 3d array with elements all zero(unsigned int 8 bit) 
temp = struct('cdata', zeros(vidHeight, vidWidth, nChannels, 'uint8'), 'colormap', []);

startIndex = 1;
endIndex = len-10;

vidOut = VideoWriter(outName);
vidOut.FrameRate = fr;

open(vidOut)   % open the video to write 

% compute Gaussian blur stack
disp('Spatial filtering...')
Gdown_stack = build_GDown_stack(vidFile, startIndex, endIndex, level);
disp('Finished')
% Properties of Gdown_stack: 
% the first dimension is the time axis
% the second dimension is the y axis of the video
% the third dimension is the x axis of the video
% the forth dimension is the color channel

% Temporal filtering
disp('Temporal filtering...')
filtered_stack = ideal_bandpassing(Gdown_stack, 1, fl, fh, samplingRate);
disp('Finished')

%% amplify
filtered_stack(:,:,:,1) = filtered_stack(:,:,:,1) .* alpha;
filtered_stack(:,:,:,2) = filtered_stack(:,:,:,2) .* alpha .* chromAttenuation;
filtered_stack(:,:,:,3) = filtered_stack(:,:,:,3) .* alpha .* chromAttenuation;



%% Render on the input video
disp('Rendering...')
% output video
k = samplingRate;
%% create multiple array 
for i = startIndex + samplingRate : endIndex - samplingRate
    k = k+1
    temp.cdata = read(vid, i);
    [rgbframe,~] = frame2im(temp);
    rgbframe = im2double(rgbframe);
    frame = rgb2ntsc(rgbframe);

    filtered = squeeze(filtered_stack(k,:,:,:));

    filtered = imresize(filtered,[vidHeight vidWidth]);
    %% Capture the RGB data (y,x,[RGB])
    % Focusing on: 
    % 1. forehead : 
    % (bbox(2)+0.05*bbox(4):bbox(2)+0.15*bbox(4),bbox(1)+0.3*bbox(1):bbox(1)+0.7*bbox(3))
    % 2. right cheek : 
    % (bbox(2)+0.55*bbox(2):bbox(2)+0.65*bbox(4),bbox(1)+0.15*bbox(3):bbox(1)+0.3*bbox(3))
    % 3. left cheek : 
    % (bbox(2)+0.55*bbox(2):bbox(2)+0.65*bbox(4),bbox(1)+0.7*bbox(3):bbox(1)+0.85*bbox(3))
    
    forehead_r(1,k-samplingRate) = mean(mean(filtered(forehead_box(2):forehead_box(2)+forehead_box(4),...
        forehead_box(1):forehead_box(1)+forehead_box(3),1)));
    forehead_g(1,k-samplingRate) = mean(mean(filtered(forehead_box(2):forehead_box(2)+forehead_box(4),...
        forehead_box(1):forehead_box(1)+forehead_box(3),2)));
    %forehead_b(1,k-samplingRate) = mean(mean(filtered(forehead_box(2):forehead_box(2)+forehead_box(4),...
        %forehead_box(1):forehead_box(1)+forehead_box(3),3)));
    rcheek_r(1,k-samplingRate) = mean(mean(filtered(rcheek_box(2):rcheek_box(2)+rcheek_box(4),...
        rcheek_box(1):rcheek_box(1)+rcheek_box(3),1)));
    rcheek_g(1,k-samplingRate) = mean(mean(filtered(rcheek_box(2):rcheek_box(2)+rcheek_box(4),...
        rcheek_box(1):rcheek_box(1)+rcheek_box(3),2)));
    %rcheek_b(1,k-samplingRate) = mean(mean(filtered(rcheek_box(2):rcheek_box(2)+rcheek_box(4),...
        %rcheek_box(1):rcheek_box(1)+rcheek_box(3),3)));
    lcheek_r(1,k-samplingRate) = mean(mean(filtered(lcheek_box(2):lcheek_box(2)+lcheek_box(4),...
        lcheek_box(1):lcheek_box(1)+lcheek_box(3),1)));
    lcheek_g(1,k-samplingRate) = mean(mean(filtered(lcheek_box(2):lcheek_box(2)+lcheek_box(4),...
        lcheek_box(1):lcheek_box(1)+lcheek_box(3),2)));
    %lcheek_b(1,k-samplingRate) = mean(mean(filtered(lcheek_box(2):lcheek_box(2)+lcheek_box(4),...
        %lcheek_box(1):lcheek_box(1)+lcheek_box(3),3)));
    whole_r(1,k-samplingRate) = mean([forehead_r(1,k-samplingRate),rcheek_r(1,k-samplingRate),lcheek_r(1,k-samplingRate)]);
    whole_g(1,k-samplingRate) = mean([forehead_g(1,k-samplingRate),rcheek_g(1,k-samplingRate),lcheek_g(1,k-samplingRate)]);
    
    % convert to HSV channel
    % h = hsv(:, :, 1); % Hue image
    % green channel corresponding to 100~150 Hue (0.2778~0.4167)
    %hsv = rgb2hsv(filtered);
    %whole_h(1,k-samplingRate) = mean(mean(hsv(:,:,1)));
    %% fusing the image and vidoutput
    filtered = filtered+frame;

    frame = ntsc2rgb(filtered);
        
    frame(frame > 1) = 1;
    frame(frame < 0) = 0;


    writeVideo(vidOut,im2uint8(frame));
end

disp('Finished')
close(vidOut);  % close the video to finish writing
%% Normalization
forehead_r = Normalization(forehead_r);
forehead_g = Normalization(forehead_g);
%forehead_b = Normalization(forehead_b);

rcheek_r = Normalization(rcheek_r);
rcheek_g = Normalization(rcheek_g);
%rcheek_b = Normalization(rcheek_b);

lcheek_r = Normalization(lcheek_r);
lcheek_g = Normalization(lcheek_g);
%lcheek_b = Normalization(lcheek_b);

whole_r = Normalization(whole_r);
whole_g = Normalization(whole_g);
%%  plot the RGB signal 
figure 
plot(forehead_r,'r');hold on
plot(forehead_g,'g');
xlabel('Number of frame','FontWeight','bold','FontSize',16);
ylabel('channel value (Normalization)','FontWeight','bold','FontSize',16);title('Forehead');
h = legend('red channel','green channel');
set(h,'Fontsize',16);
saveas(gca,[outDir '/' filename ' ' num2str(fl) '-to-' num2str(fh) '_forehead_RG.png']);
hold off

figure 
plot(rcheek_r,'r');hold on
plot(rcheek_g,'g');
xlabel('Number of frame','FontWeight','bold','FontSize',16);
ylabel('channel value (Normalization)','FontWeight','bold','FontSize',16);title('Right cheek');
h = legend('red channel','green channel');
set(h,'Fontsize',16);
saveas(gca,[outDir '/' filename ' ' num2str(fl) '-to-' num2str(fh) '_rcheek_RG.png']);
hold off

figure 
plot(lcheek_r,'r');hold on
plot(lcheek_g,'g');
xlabel('Number of frame','FontWeight','bold','FontSize',16);
ylabel('channel value (Normalization)','FontWeight','bold','FontSize',16);title('Left cheek');
h = legend('red channel','green channel');
set(h,'Fontsize',16);
saveas(gca,[outDir '/' filename ' ' num2str(fl) '-to-' num2str(fh) '_lcheek_RG.png']);
hold off

figure 
plot(whole_r,'r');hold on
plot(whole_g,'g');
xlabel('Number of frame','FontWeight','bold','FontSize',16);
ylabel('channel value (Normalization)','FontWeight','bold','FontSize',16);title('Combined estimation');
h = legend('red channel','green channel');
set(h,'Fontsize',16);
saveas(gca,[outDir '/' filename ' ' num2str(fl) '-to-' num2str(fh) '_Combined_RG.png']);
hold off

% figure
% plot(whole_h,'r');
% xlabel('Number of frame','FontWeight','bold','FontSize',16);title('Whole image');
% legend('Hue');
% saveas(gca,[outDir '/' filename ' ' num2str(fl) '-to-' num2str(fh) '_HSV.jpg']);
%% FFT analysis
FFT_series(forehead_r,outDir,filename,'forehead_r');
FFT_series(forehead_g,outDir,filename,'forehead_g');

FFT_series(rcheek_r,outDir,filename,'rcheek_r');
FFT_series(rcheek_g,outDir,filename,'rcheek_g');

FFT_series(lcheek_r,outDir,filename,'lcheek_r');
FFT_series(lcheek_g,outDir,filename,'lcheek_g');

FFT_series(whole_r,outDir,filename,'whole_r');
FFT_series(whole_g,outDir,filename,'whole_g');
%% Do the peak detection examination
% [pks,locs] = findpeaks(rcheek_g,'MinPeakDistance',samplingRate/2);
% cycles = diff(locs);
% meanCycle = mean(cycles)
% 
% Fs = 1;
% Nf = 512;
% df = Fs/Nf;
% f = 0:df:Fs/2-df;
% 
% trSpots = fftshift(fft(rcheek_g-mean(rcheek_g),Nf));
% 
% dBspots = 20*log10(abs(trSpots(Nf/2+1:Nf)));
% 
% figure
% yaxis = [10 50];hold on
% plot(f,dBspots,1./[meanCycle meanCycle],yaxis)
% xlabel('Frequency (frame^{-1})')
% ylabel('| FFT | (dB)')
% axis([0 1/2 yaxis])
% text(1/meanCycle + .002,25,['<== 1/' num2str(meanCycle)])
% saveas(gca,[outDir '/' filename '_rcheek_g.jpg']);
% hold off
%% Finding the BPM
[RR_forehead_r, RR_forehead_g] = compareRGB(forehead_r,forehead_g);
[RR_rcheek_r, RR_rcheek_g] = compareRGB(rcheek_r,rcheek_g);
[RR_lcheek_r, RR_lcheek_g] = compareRGB(lcheek_r,lcheek_g);
[RR_whole_r, RR_whole_g] = compareRGB(whole_r,whole_g);

T_head = Time_domain(forehead_r,forehead_g);
T_rc = Time_domain(rcheek_r,rcheek_g);
T_lc = Time_domain(lcheek_r,lcheek_g);
T_wh = Time_domain(whole_r,whole_g);

bpm(1,1) = samplingRate/mean(RR_forehead_r)*60;bpm(1,2:3) = T_head(1,:); % red forehead 
bpm(2,1) = samplingRate/mean(RR_rcheek_r)*60;bpm(2,2:3) = T_rc(1,:); % red right cheek
bpm(3,1) = samplingRate/mean(RR_lcheek_r)*60;bpm(3,2:3) = T_lc(1,:); % red left cheek
bpm(4,1) = samplingRate/mean(RR_whole_r)*60;bpm(4,2:3) = T_wh(1,:); % red - combined region

bpm(5,1) = samplingRate/mean(RR_forehead_g)*60;bpm(5,2:3) = T_head(2,:); % green forehead
bpm(6,1) = samplingRate/mean(RR_rcheek_g)*60;bpm(6,2:3) = T_rc(2,:); % green right cheek
bpm(7,1) = samplingRate/mean(RR_lcheek_g)*60;bpm(7,2:3) = T_lc(2,:); % green left cheek
bpm(8,1) = samplingRate/mean(RR_whole_g)*60;bpm(8,2:3) = T_wh(2,:); % green - combined region

% return RR interval of red channel with lowest standard deviation in all region  
[value,index] = min([std(RR_forehead_r) std(RR_rcheek_r) std(RR_lcheek_r) std(RR_whole_r)]); 

if index == 1
    %RR_interval = RR_forehead_r;
    signal = forehead_r;
elseif index == 2
    %RR_interval = RR_rcheek_r;
    signal = rcheek_r;
elseif index == 3
    %RR_interval = RR_lcheek_r;
    signal = lcheek_r;
else
    %RR_interval = RR_whole_r;
    signal = whole_r;
end
%% Cubic spline interploation
x = 1:4:length(signal)*4;
xx = 1:length(signal)*4;
yy = spline(x,signal,xx);
figure
plot(x,signal,'o',xx,yy)
saveas(gca,[outDir '/' 'spline interpolation.png']);
samplingRate = 120;

RR_interval = captureinterval(yy);
RR_interval = IntervalConstraint(RR_interval);
RR_interval(RR_interval == 0) = [];
RR_interval(1) = [];
end