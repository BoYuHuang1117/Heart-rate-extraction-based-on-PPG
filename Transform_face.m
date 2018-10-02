function [] = Transform_face(fileDirname,vidFile,fps)
% Author : Bo Yu Huang
% Date : 2018.3.24
% Detect the face region in input video and output only face region video
% https://nl.mathworks.com/help/vision/examples/face-detection-and-tracking-using-the-klt-algorithm.html

% Date : 2018.7.9
% Set the bounding box size lower limit (400x400) in case detect the wrong faces
resultsDir = fileDirname;
mkdir(resultsDir);

global samplingRate
outDir = resultsDir;
samplingRate = fps;    % Depend on video fps 

[~,vidName] = fileparts(vidFile);

% Build the full file name frome parts 
outName = fullfile(outDir,[vidName '.avi']);

% Read video
vid = VideoReader(vidFile);

% Extract video info
vidHeight = vid.Height;  % set the range to reduce time
vidWidth = vid.Width;    % set the range to reduce time
nChannels = 3;
fr = vid.FrameRate;
len = vid.NumberOfFrames;
startIndex = 1;
endIndex = len-10;

vidOut = VideoWriter(outName);
vidOut.FrameRate = fr;

open(vidOut)   % open the video to write 

% Create a cascade detector object.
faceDetector = vision.CascadeObjectDetector();

% Read a video frame and run the face detector.
videoFileReader = vision.VideoFileReader(vidFile);
videoFrame      = step(videoFileReader);
bbox            = step(faceDetector, videoFrame);  % bounding box [x,y,width,height]

% Draw the returned bounding box around the detected face.
videoFrame = insertShape(videoFrame, 'Rectangle', bbox);
figure; imshow(videoFrame); title('Detected face');

% create a 3d array with elements all zero(unsigned int 8 bit) 
temp = struct('cdata', zeros(vidHeight, vidWidth, nChannels, 'uint8'), 'colormap', []);
% create a 3d array with elements all zero to store face region
temp1 = struct('cdata', zeros(bbox(4), bbox(3), nChannels, 'uint8'), 'colormap', []);

for i = 1:length(bbox(:,1))
    if (bbox(i,3) > 350) && (bbox(i,4) > 350)
        box(1,:) = bbox(i,:)
    end
end
for i = startIndex:endIndex
    temp.cdata = read(vid, i);
    %temp1.cdata = temp.cdata(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3),:);
    %temp1.cdata = temp.cdata(bbox(2,2):bbox(2,2)+bbox(2,4),bbox(2,1):bbox(2,1)+bbox(2,3),:);
    temp1.cdata = temp.cdata(box(2):box(2) + box(4),box(1):box(1) + box(3),:);
    [rgbframe,~] = frame2im(temp1);
    rgbframe = im2double(rgbframe);
    frame = rgb2ntsc(rgbframe);
    frame = ntsc2rgb(frame);

    frame(frame > 1) = 1;
    frame(frame < 0) = 0;
    writeVideo(vidOut,im2uint8(frame));
end

disp('Finished')
close(vidOut);  % close the video to finish writing

end