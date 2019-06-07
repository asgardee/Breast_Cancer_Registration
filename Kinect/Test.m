close all; clc;

% Getting the averaged depth data from sample 1
test_full = sample(1).depthFrameData(:,:,1,:);
test_full = mean(test_full,4);

% Saving the data in vector format
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
end

%%
% Points on surface that represent a flat area
cursor_points = sortrows(cursor_points,1);
x_flat = cursor_points(2,1):cursor_points(3,1);
cursor_points = sortrows(cursor_points,2);
y_flat = cursor_points(2,2):cursor_points(3,2);
[X_flat,Y_flat] = meshgrid(x_flat,y_flat);

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

%% Straightening and centering data according to MLR values

Y_data_flattened = Y_data - (b(1) + b(2)*X_data(:,1) + b(3)*X_data(:,2));

fig = figure;
scatter3(X_data(:,1),X_data(:,2),Y_data_flattened,marker_size,'filled','k')
axis square

%% Work from here!

x_min_roi = 175;
x_max_roi = 285;
y_min_roi = 230;
y_max_roi = 350;

test = test_full(x_min_roi:x_max_roi,y_min_roi:y_max_roi);

if 1
    figure;
    surf(test)
    figure;
    surf(test_full)
end

min_thresh = 870;
max_thresh = 1100;


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