clc; clearvars; % Cleaning workspace and command window

hwInfo = imaqhwinfo('kinect'); % Obtaining info for kinect hardware 
% Use imaqtool to open the GUI

% Creating the VIDEOINPUT objects for the two streams
colorVid = videoinput('kinect',1);
depthVid = videoinput('kinect',2);




%%
% Best depth data at 20.5 in - 28 in
    % Currently at ~24 in away
    
% Top left point of 'region of interest' box
x_roi = 155;
y_roi = 48;
width_roi = 309;
height_roi = 239;
