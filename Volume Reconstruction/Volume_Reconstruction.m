% Clearing current variables, command window, and closing all plots
clearvars; close all; clc;

%% Script definitions
depth_frame_inspect = 0; % Change to 1 to inspect depth frame
save_data = 0; % Save data to US_Data
test = 0; % Set to one to trigger testing

Volume_dim_buffer = 5; % Buffer for the shell of the phantom in mm
% Shrinks the size of the shell. Value of 1 means no lose of information.
% 0 < pixel_space_rat <= 1
pixel_space_rat = 1;

%%
% Loading the US_data from the current folder
filename = dir('*.mat');
for i = 1:length(filename)
    if contains(filename(i).name,'_Force')
        tic;
        load(filename(i).name);
        telapsed = round(toc);
        fprintf('It took %d seconds to open US_Data_oneForce.\n\n',telapsed)
    end
end

%% Fixing incorrect index values and cropping images
x_roi = [106,890];
y_roi = [366,761];
for i = 1:length(US_Data_oneForce)
    US_Data_oneForce(i).Index = i; %#ok<*SAGROW>
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
    imtool(US_Depth_Frame)  %#ok<*UNRCH>
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
% Image_char = imref2d(size(US_Depth_Frame),pixel_spacing_x,pixel_spacing_y);
% imshow(US_Depth_Frame,Image_char)

%%
% Defining the X, Y, Z position vectors for the image
X_image_vals = -20:pixel_spacing_x:20;
Y_image_vals = 0 : -pixel_spacing_y : ...
    -size(US_Depth_Frame,1)*pixel_spacing_y+pixel_spacing_y;
[X_image,Y_image,Z_image] = ...
    deal(zeros(length(X_image_vals)*length(Y_image_vals),1));
count = 0;
for i = 1:length(X_image_vals)
    for j = 1:length(Y_image_vals)
        count = count + 1;
        X_image(count) = X_image_vals(i);
        Y_image(count) = Y_image_vals(j);
    end
end

% Finding location of minimum point in image
min_x = min(abs(X_image_vals));
Volume_vector = [X_image,Y_image,Z_image];
min_index = find(Volume_vector(:,1) == min_x & Volume_vector(:,2) == 0);

%%
% Cycling through all images
for i = 1:length(US_Data)
    % Rotation matrix using Euler angles
    alph = US_Data(i).Roll;
    bet = US_Data(i).Pitch;
    gam = US_Data(i).Yaw;
    rot_mat = RotMatrix(alph,bet,gam);
    % Position vector representing translational offset
    pos_mat = [US_Data(i).X_pos;US_Data(i).Y_pos;US_Data(i).Z_pos];
    
    % Applying the rotation to the pixel points
    % The Y dimension in the image frame is the Z direction in robot frame
    Volume_vector = [Z_image,X_image,Y_image]*rot_mat;
    % Applying the translation to the pixel points
    Volume_vector(:,1) = Volume_vector(:,1) + pos_mat(1);
    Volume_vector(:,2) = Volume_vector(:,2) + pos_mat(2);
    Volume_vector(:,3) = Volume_vector(:,3) + pos_mat(3);
    % Adding in the intensity values for the given x,y,z position
    image_slice = US_Data(i).US_Image.';
    Volume_vector(:,4) = image_slice(:);
    
    % Saving data to US_Data structure
    US_Data(i).US_Volume = Volume_vector;
end

% Saving the output file
if save_data
    clearvars -except US_Data test
    filename = strcat(pwd,'\2019-07-10T11-20-44_TransForce_12.mat');
    tic;
    save(filename,'US_Data','-v7.3')
    telapsed = round(toc);
    fprintf('Took %d seconds to save transformed points.\n\n',telapsed)
end

%% Initializing and filling variable to translated points
Im_rows = size(US_Data(1).US_Volume,1);
Im_cols = size(US_Data(1).US_Volume,2);
US_Images_Trans = zeros(Im_rows*length(US_Data),Im_cols);
for i = 1:length(US_Data)
    US_Images_Trans(Im_rows*i-Im_rows+1:Im_rows*i,:) = US_Data(i).US_Volume;
end

%% Saving the output file
if save_data
    filename = strcat(pwd,'\2019-07-10T11-20-44_OnlyTransForce_12.mat');
    tic;
    save(filename,'US_Images_Trans','-v7.3')
    telapsed = round(toc);
    fprintf('Took %d seconds to save transformed points.\n\n',telapsed)
end


%% Creating the shell for the 3D volume reconstruction
% % Defining mold size and volume of 3D shell
% mold_diameter = 146;
% Volume_dim_mm = [mold_diameter + Volume_dim_buffer,...
%     mold_diameter + Volume_dim_buffer,...
%     size(US_Depth_Frame,1)*pixel_spacing_y + Volume_dim_buffer];
% 
% % Converting mm values to pixel values
% pixel_spacing_x_big = pixel_spacing_x/pixel_space_rat;
% pixel_spacing_y_big = pixel_spacing_y/pixel_space_rat;
% Volume_dim_pixel = [round(Volume_dim_mm(1)/pixel_spacing_x_big),...
%     round(Volume_dim_mm(2)/pixel_spacing_x_big),...
%     round(Volume_dim_mm(3)/pixel_spacing_y_big)];
% 
% % Creating the shell to store the pixel values
% US_Volume = -1*ones(Volume_dim_pixel,'int16');

%%
% % Turns the 3D Volume into its vector components
% [X,Y,Z,Val] = Volume2Vector(US_Volume);

