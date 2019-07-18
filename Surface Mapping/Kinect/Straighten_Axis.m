function [X_ROI,Y_ROI,Z_ROI,indicies] = ROI(X,Y,Z)
% ROI Takes in column vectors X,Y,Z and returns the X,Y,Z values within the
% square region of interest. This function uses 3D scatter plots and user
% inputs to define the ROI

fig = figure;
marker_size = 1; % Defines the point size for the scatter plot
scatter3(Y,Z,-X,marker_size,'filled','k')
%axis square % Ensures the figure is not distorted in the X,Y,Z directions
xlabel('Y')
ylabel('Z')
zlabel('X')
title('Raw Depth Data')

dcm_obj = datacursormode(fig);

% Prompting user to select flat surface on image
Dialog = 'Click 4 points on the plot that encapture the region of interest.';
disp(Dialog)
pause(17) % Waits 17 seconds before posting the pop-up window
answer = questdlg(Dialog,'ROI GUI','Done','Not Done','Done');

% Getting the info from the points clicked on the figure
info_struct = getCursorInfo(dcm_obj);

% Checks to ensure button presses are valid (exactly 4 points)
while 1
    % Checks if any points have been clicked on the image
    if ~isempty(info_struct)
        % Getting cursor data and accepting only valid clicks
        cursor_points_cell = {info_struct.Position};
        cursor_points = zeros(length(cursor_points_cell),3);
        for i = 1:length(cursor_points_cell)
            % Invalid clicks have a value of 0 in the z value
            if cursor_points_cell{i}(3) ~= 0
                cursor_points(i,1) = -cursor_points_cell{i}(3);
                cursor_points(i,2) = cursor_points_cell{i}(1);
                cursor_points(i,3) = cursor_points_cell{i}(2);
            else
                cursor_points(i,:) = [NaN NaN NaN];
            end
        end
        
        % Removes NaN values from cursor points
        cursor_points(any(isnan(cursor_points),2),:) = [];
        
        % Checks exit condition
        if length(cursor_points_cell) == 4 && strcmp(answer,'Done')
            break
        else
            pause(10)
            Dialog2 = {'4 Points have not been clicked',Dialog};
            answer = questdlg(Dialog2,'Breast Phantom ROI GUI','Done',...
                'Not Done','Done');
            info_struct = getCursorInfo(dcm_obj);
        end
    else
        pause(10)
        info_struct = getCursorInfo(dcm_obj);
    end
end
close(fig) % Closes figure after done

% Vectors containing X,Y coordinates of ROI
X_ROI_Vector = min(cursor_points(:,1)):max(cursor_points(:,1));
Y_ROI_Vector = min(cursor_points(:,2)):max(cursor_points(:,2));

% Finding data in the main data set that matches selected area
temp1 = ismember(X,X_ROI_Vector);
temp2 = ismember(Y,Y_ROI_Vector);

% Initializing vectors for region of interest vectors and index
[X_ROI, Y_ROI, Z_ROI, indicies] = deal(zeros(length(temp1),1));


for i = 1:length(temp1)
    if temp1(i) == 1 && temp2(i) == 1
        X_ROI(i) = X(i);
        Y_ROI(i) = Y(i);
        Z_ROI(i) = Z(i);
        indicies(i) = i;
    else
        X_ROI(i) = NaN;
        Y_ROI(i) = NaN;
        Z_ROI(i) = NaN;
        indicies(i) = NaN;
    end
end
clear temp1 temp2;

% Removes NaN rows
X_ROI = X_ROI(~isnan(X_ROI));
Y_ROI = Y_ROI(~isnan(Y_ROI));
Z_ROI = Z_ROI(~isnan(Z_ROI));
% X_ROI(any(isnan(X_ROI),1),:) = [];
% Y_ROI(any(isnan(Y_ROI),1),:) = [];
% Z_ROI(any(isnan(Z_ROI),1),:) = [];
indicies(any(isnan(indicies),2),:) = [];

end

