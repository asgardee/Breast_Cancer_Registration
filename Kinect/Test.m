close all; clc;

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
%%
marker_size = 3;
scatter3(X_data(:,1),X_data(:,2),-Y_data,marker_size,'filled','k')
%%
% Finding the coordinates of a flat surface on the image
x_flat = 190:230;
y_flat = 190:230;

z1 = find(X_data(:,1) == x_flat);
z2 = find(X_data(:,2) == y_flat);

X_data_flat = bsxfun(@eq,z1,z2.');

%%

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