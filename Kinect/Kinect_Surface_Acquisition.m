clc; clearvars; % Cleaning workspace and command window

hwInfo = imaqhwinfo('kinect'); % Obtaining info for kinect hardware
% Use imaqtool to open the GUI

% Creating the VIDEOINPUT objects for the two streams
colorVid = videoinput('kinect',1);
depthVid = videoinput('kinect',2);

% Setting the triggering mode to 'manual'
triggerconfig([colorVid depthVid],'manual');
counter = 0; % Counts how many manual triggers were initiated

% Setting the frames per trigger
colorVid.FramesPerTrigger = 25;
depthVid.FramesPerTrigger = 25;

sample = struct('colorFrameData',[],'colorTimeData',[],'colorMetaData',...
    [],'depthFrameData',[],'depthTimeData',[],'depthMetaData',[]);

while 1
    % Prompts user for signal acquisition
    answer = questdlg('Acquire sample?','Signal Acquisition GUI','Yes','No','Yes');
    
    % Checks exit condition
    if isempty(answer) || strcmp(answer,'No')
        break
    else
        counter = counter + 1; % Increment counter
        
        % Start the color and depth device. This begins acquisition, but does not
        % start logging of acquired data.
        start([colorVid depthVid]);
        trigger([colorVid depthVid]); % Trigger the devices to start logging of data.
        
        % Retrieve the acquired data
        [sample(counter).colorFrameData, sample(counter).colorTimeData,...
            sample(counter).colorMetaData] = getdata(colorVid);
        [sample(counter).depthFrameData, sample(counter).depthTimeData,...
            sample(counter).depthMetaData] = getdata(depthVid);
    end
end
clear answer counter;

% Stop the devices
stop([colorVid depthVid]);

%%
% Best depth data at 20.5 in - 28 in
% Currently at ~24 in away

% % Top left point of 'region of interest' box
% x_roi = 155;
% y_roi = 48;
% width_roi = 309;
% height_roi = 239;
