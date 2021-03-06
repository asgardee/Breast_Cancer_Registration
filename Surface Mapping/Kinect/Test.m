close all; clc;
% C:\ProgramData\MATLAB\SupportPackages\R2019a\toolbox\imaq\supportpackages\kinectruntime\+imaq\+internal
%%
% Getting the averaged depth data from sample 1
test_full = sample(1).depthFrameData(:,:,1,:);
test_full = mean(test_full,4);

X_data = zeros(size(test_full,1)*size(test_full,2),2);
Y_data = zeros(size(test_full,1)*size(test_full,2),1);
x_val = 0; % Initialize x value
y_val = 0; % Initialize y value
for i = 1:size(X_data,1)
    if mod(i-1,size(test_full,2)) == 0
        x_val = x_val + 1;
        y_val = mod(i,size(test_full,2));
    else
        y_val = mod(i-1,size(test_full,2))+1;
    end
    X_data(i,:) = [x_val y_val];
    Y_data(i) = test_full(x_val,y_val);
end

%% Getting flat surface on figure
% Plotting figure
fig = figure;
marker_size = 3;
scatter3(X_data(:,1),X_data(:,2),-Y_data,marker_size,'filled','k')
axis square
dcm_obj = datacursormode(fig);

% Prompting user to select flat surface on image
Dialog = 'Click 4 points on the plot that encapture a flat surface.';
disp(Dialog)
pause(17)
answer = questdlg(Dialog,'Flat Surface GUI','Done','Not Done','Done');

% Getting the info from the points clicked on the figure
info_struct = getCursorInfo(dcm_obj);

% Checks to ensure button presses are valid (exactly 4 points)
while 1
    if ~isempty(info_struct)
        cursor_points_cell = {info_struct.Position};
        cursor_points = zeros(length(cursor_points_cell),3);
        for i = 1:length(cursor_points_cell)
            if cursor_points_cell{i}(3) ~= 0
                cursor_points(i,1) = cursor_points_cell{i}(1);
                cursor_points(i,2) = cursor_points_cell{i}(2);
                cursor_points(i,3) = cursor_points_cell{i}(3);
            else
                cursor_points(i,:) = [NaN NaN NaN];
            end
        end
        cursor_points(any(isnan(cursor_points),2),:) = [];
        
        % Checks exit condition
        if length(cursor_points_cell) == 4 && strcmp(answer,'Done')
            break
        else
            pause(10)
            Dialog2 = {'4 Points have not been clicked',...
                'Click 4 points on the plot that encapture a flat surface.'};
            answer = questdlg(Dialog2,'Flat Surface GUI','Done','Not Done'...
                ,'Done');
            info_struct = getCursorInfo(dcm_obj);
        end
    else
        pause(10)
        info_struct = getCursorInfo(dcm_obj);
    end
end

% Points on surface that represent a flat area
cursor_points = sortrows(cursor_points,1);
x_flat = cursor_points(2,1):cursor_points(3,1);
cursor_points = sortrows(cursor_points,2);
y_flat = cursor_points(2,2):cursor_points(3,2);
[X_flat,Y_flat] = meshgrid(x_flat,y_flat);

% Finding data in the main data set that matches selected area
temp1 = ismember(X_data(:,1),x_flat);
temp2 = ismember(X_data(:,2),y_flat);
X_data_flat = zeros(length(temp1),2);
Y_data_flat = zeros(length(temp1),1);
counter = 0;

for i = 1:length(temp1)
    if temp1(i) == 1 && temp2(i) == 1
        counter = counter + 1;
        X_data_flat(i,:) = X_data(i,:);
        Y_data_flat(i) = Y_data(i);
    else
        X_data_flat(i,:) = NaN;
        Y_data_flat(i) = NaN;
    end
end
clear temp1 temp2;

% Removes NaN rows
X_data_flat(any(isnan(X_data_flat),2),:) = [];
Y_data_flat(any(isnan(Y_data_flat),2),:) = [];

%% Multiple Linear Regression for determining slope of plane
if ~all(X_data_flat(:,1) == 1)
    X_data_flat = [ones(size(X_data_flat,1),1) X_data_flat];
end

b = regress(Y_data_flat,X_data_flat);

Z_flat = b(1) + b(2)*X_flat + b(3)*Y_flat;

figure;
scatter3(X_data_flat(:,2),X_data_flat(:,3),Y_data_flat)
hold on
mesh(X_flat,Y_flat,Z_flat)
hold off

%% Getting ROI (breast phantom) from main dataset
% Straightening and centering data according to MLR values
Y_data_flattened = Y_data - (b(1) + b(2)*X_data(:,1) + b(3)*X_data(:,2));

fig = figure;
scatter3(X_data(:,1),X_data(:,2),Y_data_flattened,marker_size,'filled','k')
axis square
dcm_obj = datacursormode(fig);

% Prompting user to select flat surface on image
Dialog = 'Click 4 points on the plot that encapture the breast phantom.';
disp(Dialog)
pause(17)
answer = questdlg(Dialog,'Breast Phantom ROI GUI','Done','Not Done','Done');

% Getting the info from the points clicked on the figure
info_struct = getCursorInfo(dcm_obj);

% Checks to ensure button presses are valid (exactly 4 points)
while 1
    if ~isempty(info_struct)
        cursor_points_cell = {info_struct.Position};
        cursor_points = zeros(length(cursor_points_cell),3);
        for i = 1:length(cursor_points_cell)
            if cursor_points_cell{i}(3) ~= 0
                cursor_points(i,1) = cursor_points_cell{i}(1);
                cursor_points(i,2) = cursor_points_cell{i}(2);
                cursor_points(i,3) = cursor_points_cell{i}(3);
            else
                cursor_points(i,:) = [NaN NaN NaN];
            end
        end
        cursor_points(any(isnan(cursor_points),2),:) = [];
        
        % Checks exit condition
        if length(cursor_points_cell) == 4 && strcmp(answer,'Done')
            break
        else
            pause(10)
            Dialog2 = {'4 Points have not been clicked',...
                'Click 4 points on the plot that encapture the breast phantom.'};
            answer = questdlg(Dialog2,'Breast Phantom ROI GUI','Done',...
                'Not Done','Done');
            info_struct = getCursorInfo(dcm_obj);
        end
    else
        pause(10)
        info_struct = getCursorInfo(dcm_obj);
    end
end

% Points on surface that represent a flat area
x_phantom = min(cursor_points(:,1)):max(cursor_points(:,1));
y_phantom = min(cursor_points(:,2)):max(cursor_points(:,2));
[X_phantom,Y_phantom] = meshgrid(x_phantom,y_phantom);

% Finding data in the main data set that matches selected area
temp1 = ismember(X_data(:,1),x_phantom);
temp2 = ismember(X_data(:,2),y_phantom);
X_data_phantom = zeros(length(temp1),2);
Y_data_phantom = zeros(length(temp1),1);

for i = 1:length(temp1)
    if temp1(i) == 1 && temp2(i) == 1
        counter = counter + 1;
        X_data_phantom(i,:) = X_data(i,:);
        Y_data_phantom(i) = Y_data_flattened(i);
    else
        X_data_phantom(i,:) = NaN;
        Y_data_phantom(i) = NaN;
    end
end
clear temp1 temp2;

% Removes NaN rows
X_data_phantom(any(isnan(X_data_phantom),2),:) = [];
Y_data_phantom(any(isnan(Y_data_phantom),2),:) = [];

% Distance from backboard to front of tube [cm]
dist_z = 9.5;
%%
% marker_size = 3;
fig = figure;
scatter3(X_data_phantom(:,2),Y_data_phantom,-X_data_phantom(:,1),...
    marker_size,'filled','k')
view([45 30]);
axis square
xlabel('Y')
ylabel('Z')
zlabel('X')

%% Work from here! xxx

% Getting all images slices from the first acquisition
image_slices = sample(1).depthFrameData(:,:,1,:);

% Prompting the user to pick the ROI that contains a flat surface
answer = questdlg('The first region of interest contains the phantom and a flat surface.'...
    ,'ROI_prompt','Ok','Ok');
image_slice = image_slices(:,:,:,1);
[X,Y,Z] = depth2xyz(image_slice);
[~,~,~,ROI_Broad] = ROI(X,Y,Z);
%%
% Initializing column vectors with zeros
[X,Y,Z,Z_interp] = deal(zeros(length(ROI_Broad),1));
% Defining the indicies of the outliers and the maximum amount of outliers
% allowed in a sample
outlier_thresh = 50;
outliers = zeros(size(image_slices,4),outlier_thresh);

% Saving all column vectors for the depth data for each image slice
for i = 1:size(image_slices,4)
    disp(i)
    tstart = tic;
    
    % Getting the column vector X,Y,Z for slice i
    image_slice = image_slices(:,:,:,i);
    [X_temp,Y_temp,Z_temp] = depth2xyz(image_slice);
    X(:,i) = X_temp(ROI_Broad);
    Y(:,i) = Y_temp(ROI_Broad);
    Z(:,i) = Z_temp(ROI_Broad);
    
    verticies = [X(:,i),Y(:,i),Z(:,i)];
    
    % Using density based clustering to identify outliers
    epsl = 10; % Epsilon neigbourhood: Radius from an object
    minpts = 5; % Minimum amount of points within radius
    
    % Using dbscan with X,Y,Z data
    time_xyz_start = tic;
    [idx, corepts] = dbscan(Z(:,i),eps,minpts);
    time_xyz = toc(time_xyz_start);
    
    % Finding outliers and replacing values with NaN
    temp = find(idx == -1);
    if length(temp) > outlier_thresh % Checks if outliers exceed threshold
        disp('To many outliers, please look at sample data')
        return
    elseif i == 4 % Checks to see if all outliers are at the same index
        for j = 1:length(temp)
            outliers(i,j) = temp(j);
        end
        
        % Removing the zero terms from the outliers
        temp = nonzeros(outliers);
        
        % Checking if outliers for the data happen at the same index(s)
        if mod(length(temp),4) == 0
            temp = reshape(temp,4,length(temp)/4);
            equality = zeros(1,size(temp,2)); % Checks if column elements are equal
            for j = 1:size(temp,2)
                if range(temp(:,j)) == 0
                    equality(j) = 1;
                end
            end
            
            % If all outliers are at the same point it will be assumed that the
            % remaining outliers will only be at those index positions!
            if all(equality)
                pop = 1
            end
        end
        
    else
        for j = 1:length(temp)
            outliers(i,j) = temp(j);
        end
    end
    % Cubic interpolation for all missing values
    if ~isempty(nonzeros(outliers(i,:)))
        verticies(nonzeros(outliers(i,:)),:) = NaN;
        verticies_interp = fillmissing(verticies,'spline');
        Z_interp(:,i) = verticies_interp(:,3);
    else
        Z_interp(:,i) = verticies(:,3);
    end
    
    telapsed = toc(tstart)
    
%     % Plotting the nonprocessed data
%     figure;
%     scatter3(Y(:,i),Z(:,i),-X(:,i),marker_size,'filled','k')
%     view([45 30]);
%     axis square
%     xlabel('Y')
%     ylabel('Z')
%     zlabel('X')
%     title(sprintf('Raw Depth Data for slice %d',i))
    
    
%     % Use to increase number of data points!
%     temp = scatteredInterpolant(verticies(:,1),verticies(:,2),...
%         verticies(:,3));
%     Z_interp(:,i) = temp.Values;
    
%     % Plotting the processed data
%     figure;
%     scatter3(Y(:,i),Z_interp(:,i),-X(:,i),marker_size,'filled','k')
%     view([45 30]);
%     axis square
%     xlabel('Y')
%     ylabel('Z')
%     zlabel('X')
%     title(sprintf('Interpolated Depth Data for slice %d',i))
    
    
end

% Getting the average value for each slice
X_mean = mean(X,2);
Y_mean = mean(Y,2);
Z_mean = mean(Z,2);


%%
% Initializing column vectors with zeros
[x_len, y_len] = size(image_slices(:,:,:,1));
[X,Y,Z,Z_interp] = deal(zeros(x_len*y_len,1));

% Saving all column vectors for the depth data for each image slice
for i = 1:size(image_slices,4)
    % Getting the column vector X,Y,Z for slice i
    image_slice = image_slices(:,:,:,i);
    [X(:,i),Y(:,i),Z(:,i)] = depth2xyz(image_slice);
    
    % Plotting the nonprocessed data
    figure;
    scatter3(Y(:,i),Z(:,i),-X(:,i),marker_size,'filled','k')
    view([45 30]);
    axis square
    xlabel('Y')
    ylabel('Z')
    zlabel('X')
    title(sprintf('Raw Depth Data for slice %d',i))
    
    % image_slice(303,208) was 0!
    % Z(154832,1)
    
    temp = scatteredInterpolant(X(:,i),Y(:,i),Z(:,i));
    Z_interp(:,i) = temp.Values;
    
    % Plotting the processed data
    figure;
    scatter3(Y(:,i),Z_interp(:,i),-X(:,i),marker_size,'filled','k')
    view([45 30]);
    axis square
    xlabel('Y')
    ylabel('Z')
    zlabel('X')
    title(sprintf('Interpolated Depth Data for slice %d',i))
    
    
end

% Getting the average value for each slice
X_mean = mean(X,2);
Y_mean = mean(Y,2);
Z_mean = mean(Z,2);


%%
F = scatteredInterpolant(x,y,v);


%%
[outlier_x,outlier_y] = find(test < min_thresh) ;
[o_x,o_y] = find(test > max_thresh);
outlier_x = [outlier_x];

for i = 1:length(outlier_x)
    
    if outlier_x(i) == 1
        x_min = 1;
        x_max = outlier_x(i)+1;
    elseif outlier_x(i) == size(test,1)
        x_min = outlier_x(i)-1;
        x_max = size(test,1);
    else
        x_min = outlier_x(i)-1;
        x_max = outlier_x(i)+1;
    end
    
    if outlier_y(i) == 1
        y_min = 1;
        y_max = outlier_y(i)+1;
    elseif outlier_y(i) == size(test,1)
        y_min = outlier_y(i)-1;
        y_max = size(test,1);
    else
        y_min = outlier_y(i)-1;
        y_max = outlier_y(i)+1;
    end
    
    mask = test(x_min:x_max,y_min:y_max);
    mask_outliers = find(mask < min_thresh);
    mask(mask_outliers) = 0;
    denom = (x_max-x_min+1)*(y_max-y_min+1)-length(mask_outliers);
    
    interp_point = sum(sum(test(x_min:x_max, y_min:y_max)))/denom;
    
    if interp_point > max_thresh
        fprintf('%d\n',i)
    end
    
    test(outlier_x(i),outlier_y(i)) = interp_point;
end

%figure;
%%
test = -1*test;
surf(test)
xlabel('x');
ylabel('y');
zlabel('z');

% figure;
% surf(test_smooth)
% xlabel('x');
% ylabel('y');
% zlabel('z');

% Edges = 500:2540;
% H = histogram(test,Edges);
%
% test2 = test;

% x = 1:size(test,1);
% y = 1:size(test,2);
% [X,Y] = meshgrid(x,y);