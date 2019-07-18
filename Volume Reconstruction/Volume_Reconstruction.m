% Clearing current variables, command window, and closing all plots
clearvars; close all; clc;

%% Script definitions
depth_frame_inspect = 0; % Change to 1 to inspect depth frame
Volume_dim_buffer = 5; % Buffer for the shell of the phantom in mm
% Shrinks the size of the shell. Value of 1 means no lose of information.
% 0 < pixel_space_rat <= 1
pixel_space_rat = 1;

%%
% Loading the US_data from the current folder
filename = dir('*.mat');
for i = 1:length(filename)
    if contains(filename(i).name,'Force')
        load(filename(i).name);
    end
end

%% Fixing incorrect index values and cropping images
x_roi = [106,890];
y_roi = [366,761];
for i = 1:length(US_Data_oneForce)
    US_Data_oneForce(i).Index = i;
    US_Data_oneForce(i).US_Image = US_Data_oneForce(i).US_Image(...
        x_roi(1):x_roi(2),y_roi(1):y_roi(2));
    % Converting from meters to mm
    US_Data_oneForce(i).X_pos = US_Data_oneForce(i).X_pos*1000;
    US_Data_oneForce(i).Y_pos = US_Data_oneForce(i).Y_pos*1000;
    US_Data_oneForce(i).Z_pos = US_Data_oneForce(i).Z_pos*1000;
end
US_Data = US_Data_oneForce;
clear US_Data_oneForce

%% Defining width and height of image in real space
% Defining real life measurments
probe_w = 40; % Measured in mm
phantom_h = 61; % Measured in mm

% Loading the depth frame data
for i = 1:length(filename)
    if contains(filename(i).name,'Depth')
        load(filename(i).name);
    end
end
% Cropping depth frame
US_Depth_Frame = US_Depth_Frame(x_roi(1):x_roi(2),y_roi(1):y_roi(2));

% Manual inspection for pixels in image
if depth_frame_inspect 
    imtool(US_Depth_Frame)
end
clear depth_frame_inspect i

% Defining image width and height
image_w = y_roi(2) - y_roi(1); % Measured in pixels
image_h = abs(41 - 759); % Height from traducer probe to base in pixels

% Image characteristics
pixel_spacing_x = probe_w/image_w; % Width of each pixel in mm
pixel_spacing_y = phantom_h/image_h; % length of each pixel in mm
% image_h_mm = pixel_spacing_y*size(US_Depth_Frame,1);
% image_w_mm = probe_w;
Image_char = imref2d(size(US_Depth_Frame),pixel_spacing_x,pixel_spacing_y);
imshow(US_Depth_Frame,Image_char)

%% Creating the shell for the 3D volume reconstruction
% Defining mold size and volume of 3D shell
mold_diameter = 146;
Volume_dim_mm = [mold_diameter + Volume_dim_buffer,...
    mold_diameter + Volume_dim_buffer,...
    size(US_Depth_Frame,1)*pixel_spacing_y + Volume_dim_buffer];

% Converting mm values to pixel values
pixel_spacing_x_big = pixel_spacing_x/pixel_space_rat;
pixel_spacing_y_big = pixel_spacing_y/pixel_space_rat;
Volume_dim_pixel = [round(Volume_dim_mm(1)/pixel_spacing_x_big),...
    round(Volume_dim_mm(2)/pixel_spacing_x_big),...
    round(Volume_dim_mm(3)/pixel_spacing_y_big)];

% Creating the shell to store the pixel values
US_Volume = -1*ones(Volume_dim_pixel,'int16');

%%

