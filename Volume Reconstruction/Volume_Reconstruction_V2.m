% Clearing current variables, command window, and closing all plots
clearvars; close all; clc;

%% Script definitions
depth_frame_inspect = 0; % Change to 1 to inspect depth frame
save_data = 0; % Save data to US_Data
Visual = 0; % Set to one to see visualization of slices
full_range = 1; % Set to one to assign pixel intensity values from 0-255
    % Set to one to differentiate between 0 intensity voxels and 
    % outer points
max_overlap_val = 20; % Assumption that the maximum overlapping intensities
    % in one voxel will be max_overlap_val
only_image_data = 0;

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
    US_Data_oneForce(i).US_Image = uint8(round(255*US_Data_oneForce(i)...
        .US_Image(x_roi(1):x_roi(2),y_roi(1):y_roi(2))));
    
    % Finding minimum and maximum pixel intensity values
    if i == 1
        min_intensity = min(min(US_Data_oneForce(i).US_Image));
        max_intensity = max(max(US_Data_oneForce(i).US_Image));
    else
        if min(min(US_Data_oneForce(i).US_Image)) < min_intensity
            min_intensity = min(min(US_Data_oneForce(i).US_Image));
        end
        if max(max(US_Data_oneForce(i).US_Image)) > max_intensity
            max_intensity = max(max(US_Data_oneForce(i).US_Image));
        end
    end
    
    % Converting from meters to mm
    US_Data_oneForce(i).X_pos = US_Data_oneForce(i).X_pos*1000;
    US_Data_oneForce(i).Y_pos = US_Data_oneForce(i).Y_pos*1000;
    US_Data_oneForce(i).Z_pos = US_Data_oneForce(i).Z_pos*1000;
end

if full_range
    if min_intensity == 0
        for i = 1:length(US_Data_oneForce)
            US_Data_oneForce(i).US_Image = round((255/max_intensity)*...
                US_Data_oneForce(i).US_Image);
        end
    else
        disp('Expected minimum intensity to be 0. Program ended early.')
        return
    end
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
    clear filename image_slice US_Depth_Frame Volume_vector X_image...
        X_image_vals Y_image Y_image_vals Z_image
    filename = strcat(pwd,'\2019-07-10T11-20-44_TransForce_12.mat');
    tic;
    save(filename,'US_Data','-v7.3')
    telapsed = round(toc);
    fprintf('Took %d seconds to save transformed points.\n\n',telapsed)
end

%% Initializing and filling variable to translated points
Im_rows = size(US_Data(1).US_Volume,1);
Im_cols = size(US_Data(1).US_Volume,2);
US_Images_Trans = zeros(Im_rows*length(US_Data),Im_cols,'single');
for i = 1:length(US_Data)
    US_Images_Trans(Im_rows*i-Im_rows+1:Im_rows*i,:) = US_Data(i).US_Volume;
end

%% Visualization of slices
if Visual
    Visualization
end

%% Saving the output file
if save_data
    filename = strcat(pwd,'\2019-07-10T11-20-44_OnlyTransForce_12.mat');
    tic;
    save(filename,'US_Images_Trans','-v7.3')
    telapsed = round(toc);
    fprintf('Took %d seconds to save transformed points.\n\n',telapsed)
end
clear filename image_slice US_Data US_Depth_Frame Volume_vector X_image...
    X_image_vals Y_image Y_image_vals Z_image

%% Creating the shell for the 3D volume reconstruction
% Edge length [mm] of voxel cube
pixel_spacing_decimals = 3;
pixel_spacing = round(min([pixel_spacing_x,pixel_spacing_y,1]),...
    pixel_spacing_decimals);

Unique_intensities = length(unique(US_Images_Trans(:,4)));
fprintf('%d unique original pixel intensity values.\n\n',...
    Unique_intensities)
US_Images_Trans = round(US_Images_Trans,...
    pixel_spacing_decimals);
% US_Images_Trans = sortrows(US_Images_Trans,1:3);

x_min_mm = min(US_Images_Trans(:,1));
y_min_mm = min(US_Images_Trans(:,2));
z_min_mm = min(US_Images_Trans(:,3));

% Breadth of pixels in [mm]
x_width = max(US_Images_Trans(:,1)) - x_min_mm;
% Mapping (x = 1:961): min(US_Images_Trans(:,1)) + pixel_spacing*(x - 1)
y_width = max(US_Images_Trans(:,2)) - y_min_mm;
% Mapping (y = 1:1553): min(US_Images_Trans(:,2)) + pixel_spacing*(y - 1)
z_width = max(US_Images_Trans(:,3)) - z_min_mm;
% Mapping (z = 1:986): min(US_Images_Trans(:,3)) + pixel_spacing*(z - 1)

% Translating x,y,z positions to cell positions
US_Images_Trans(:,1) = round((US_Images_Trans(:,1)...
    - x_min_mm)/pixel_spacing + 1);
US_Images_Trans(:,2) = round((US_Images_Trans(:,2)...
    - y_min_mm)/pixel_spacing + 1);
US_Images_Trans(:,3) = round((US_Images_Trans(:,3)...
    - z_min_mm)/pixel_spacing + 1);
US_Images_Trans = sortrows(US_Images_Trans,1:3);

%% Finding all duplicate cell positions in matrix
[~,Unique_Index,~] =...
    unique(US_Images_Trans(:,1:3), 'rows', 'first');
% Casting to smaller sizes to help with memory
Duplicate_Rows = int32(setdiff(1:size(US_Images_Trans,1),Unique_Index));
Duplicate_Row_Vals = unique(US_Images_Trans(Duplicate_Rows,1:3),'rows');
unique_duplicates = size(Duplicate_Row_Vals,1);
US_Images_Trans = int32(US_Images_Trans);
% First 3 columns of matrix represent x,y,z cells, the 4th column
% represents the number of repeated values and the other cells are the
% values in the cells
overlap_matrix_1 = -1*ones(floor(unique_duplicates/2),13,'int16');
clear Unique_Index Duplicate_Row_Vals

% Filling in all unique values using averaging
old_row = 1;
overlap_mat_size = size(overlap_matrix_1,1);
count = 0;
for i = 1:length(Duplicate_Rows)
    % Checks to see if new duplicate equals old duplicate value
    if ~all(US_Images_Trans(old_row,1:3) == ...
            US_Images_Trans(Duplicate_Rows(i),1:3))
        count = count + 1;
        repeat = find(US_Images_Trans(Duplicate_Rows(i)-1,1) == ...
            US_Images_Trans(Duplicate_Rows(i)-1:Duplicate_Rows(i)-2+max_overlap_val,1) &...
            US_Images_Trans(Duplicate_Rows(i)-1,2) ==...
            US_Images_Trans(Duplicate_Rows(i)-1:Duplicate_Rows(i)-2+max_overlap_val,2) &...
            US_Images_Trans(Duplicate_Rows(i)-1,3) ==...
            US_Images_Trans(Duplicate_Rows(i)-1:Duplicate_Rows(i)-2+max_overlap_val,3));
        
        overlap_matrix_1(count,1) = US_Images_Trans(Duplicate_Rows(i)-1,1);
        overlap_matrix_1(count,2) = US_Images_Trans(Duplicate_Rows(i)-1,2);
        overlap_matrix_1(count,3) = US_Images_Trans(Duplicate_Rows(i)-1,3);
        overlap_matrix_1(count,4) = length(repeat);
        overlap_matrix_1(count,5) = US_Images_Trans(Duplicate_Rows(i)-1,4);
        
        for j = 2:overlap_matrix_1(count,4)
            overlap_matrix_1(count,4+j) = US_Images_Trans(Duplicate_Rows(i)+int32(j)-2,4);
        end
        if count > overlap_mat_size
            old_row = Duplicate_Rows(i);
            break
        end
    end
    old_row = Duplicate_Rows(i);
end

if save_data
    filename = strcat(pwd,'\2019-07-10T11-20-44_Overlap1VoxelForce_12.mat');
    tic;
    save(filename,'overlap_matrix_1','-v7.3')
    telapsed = round(toc);
    fprintf('Took %d seconds to save transformed points.\n\n',telapsed)
end

overlap_matrix_2 = -1*ones(ceil(unique_duplicates/2),13,'int16');
count = 0;
for i = i:length(Duplicate_Rows)
    % Checks to see if new duplicate equals old duplicate value
    if ~all(US_Images_Trans(old_row,1:3) == ...
            US_Images_Trans(Duplicate_Rows(i),1:3))
        count = count + 1;
        repeat = find(US_Images_Trans(Duplicate_Rows(i)-1,1) == ...
            US_Images_Trans(Duplicate_Rows(i)-1:Duplicate_Rows(i)-2+max_overlap_val,1) &...
            US_Images_Trans(Duplicate_Rows(i)-1,2) ==...
            US_Images_Trans(Duplicate_Rows(i)-1:Duplicate_Rows(i)-2+max_overlap_val,2) &...
            US_Images_Trans(Duplicate_Rows(i)-1,3) ==...
            US_Images_Trans(Duplicate_Rows(i)-1:Duplicate_Rows(i)-2+max_overlap_val,3));
        
        overlap_matrix_2(count,1) = US_Images_Trans(Duplicate_Rows(i)-1,1);
        overlap_matrix_2(count,2) = US_Images_Trans(Duplicate_Rows(i)-1,2);
        overlap_matrix_2(count,3) = US_Images_Trans(Duplicate_Rows(i)-1,3);
        overlap_matrix_2(count,4) = length(repeat);
        overlap_matrix_2(count,5) = US_Images_Trans(Duplicate_Rows(i)-1,4);
        
        for j = 2:overlap_matrix_2(count,4)
            overlap_matrix_2(count,4+j) = US_Images_Trans(Duplicate_Rows(i)+int32(j)-2,4);
        end
    end
    old_row = Duplicate_Rows(i);
end
clear Duplicate_Rows

if save_data
    filename = strcat(pwd,'\2019-07-10T11-20-44_Overlap2VoxelForce_12.mat');
    tic;
    save(filename,'overlap_matrix_2','-v7.3')
    telapsed = round(toc);
    fprintf('Took %d seconds to save transformed points.\n\n',telapsed)
end

%% Creating new structure with only unique data
[Unique_US_Images_Trans(:,1:3),Unique_Index,~] =...
    unique(US_Images_Trans(:,1:3), 'rows', 'first');
Unique_US_Images_Trans = int16(Unique_US_Images_Trans);
Unique_US_Images_vals = uint8(US_Images_Trans(Unique_Index,4));
clear Unique_Index US_Images_Trans

overlap_matrix_1_end = find(Unique_US_Images_Trans(:,1) ==...
    overlap_matrix_1(end,1) & Unique_US_Images_Trans(:,2) ==...
    overlap_matrix_1(end,2) & Unique_US_Images_Trans(:,3) ==...
    overlap_matrix_1(end,3));

%% Using averaging to fill in voxel values
count = 1;
for i = 1:overlap_matrix_1_end
    overlap_voxel = all(Unique_US_Images_Trans(i,1) ==...
            overlap_matrix_1(count,1) & Unique_US_Images_Trans(i,2) ==...
            overlap_matrix_1(count,2) & Unique_US_Images_Trans(i,3) ==...
            overlap_matrix_1(count,3));
    if overlap_voxel
        repeat_num = overlap_matrix_1(count,4);
        Unique_US_Images_vals(i) = round(sum(...
            overlap_matrix_1(count,5:repeat_num+4))/repeat_num);
        count = count + 1;
    end
end
clear overlap_matrix_1

count = 1;
for i = overlap_matrix_1_end+1:size(Unique_US_Images_Trans,1)
    overlap_voxel = all(Unique_US_Images_Trans(i,1) ==...
            overlap_matrix_2(count,1) & Unique_US_Images_Trans(i,2) ==...
            overlap_matrix_2(count,2) & Unique_US_Images_Trans(i,3) ==...
            overlap_matrix_2(count,3));
    if overlap_voxel
        repeat_num = overlap_matrix_2(count,4);
        Unique_US_Images_vals(i) = round(sum(...
            overlap_matrix_2(count,5:repeat_num+4))/repeat_num);
        count = count + 1;
    end 
end
clear overlap_matrix_2

%%
% Dimensions of 3D volume
Volume_dim = [ceil(x_width/pixel_spacing)+1,...
    ceil(y_width/pixel_spacing)+1,...
    ceil(z_width/pixel_spacing)+1];

if only_image_data
    US_Volume = -1*ones(Volume_dim,'uint8');
else
    US_Volume = zeros(Volume_dim,'uint8');
end

%Filling in volume
for i = 1:length(Unique_US_Images_vals)
    US_Volume(Unique_US_Images_Trans(i,1),Unique_US_Images_Trans(i,2),...
        Unique_US_Images_Trans(i,3)) = Unique_US_Images_vals(i);
end
clearvars -except US_Volume

if save_data
    filename = strcat(pwd,'\2019-07-10T11-20-44_US_Volume_Averaged.mat');
    tic;
    save(filename,'US_Volume','-v7.3')
    telapsed = round(toc);
    fprintf('Took %d seconds to save US Volume.\n\n',telapsed)
end

%%
% % Turns the 3D Volume into its vector components
% [X,Y,Z,Val] = Volume2Vector(US_Volume);

