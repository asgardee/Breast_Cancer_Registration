%% Script definitions
save_data = 0; % Set as 1 to save US_Images_Trans
overlay = 1; % Set to 1 if you want the translational points overlayed

%% Plotting the slice locations in 3D space
close all;
num = 500; % Only plotting every num'th point

% Plotting slice data
figure('units','normalized','outerposition',[0 0 1 1]);
scatter3(US_Images_Trans(1:num:end,1),US_Images_Trans(1:num:end,2),...
    US_Images_Trans(1:num:end,3),1,'k','filled')

if overlay
    hold on
    % Plotting only translational point of each image
    min_index = 155431; % Found from Volume Reconstruction
    scatter3(US_Images_Trans(min_index:Im_rows:end,1),...
        US_Images_Trans(min_index:Im_rows:end,2),...
        US_Images_Trans(min_index:Im_rows:end,3),5,'r','filled')
    title('3D Plane Visualization')
    xlabel('X axis')
    ylabel('Y axis')
    zlabel('Z axis')
else
    title('3D Plane Visualization') %#ok<*UNRCH>
    xlabel('X axis')
    ylabel('Y axis')
    zlabel('Z axis')
    figure('units','normalized','outerposition',[0 0 1 1]);
    % Plotting only translational point of each image
    min_index = 155431; % Found from Volume Reconstruction
    scatter3(US_Images_Trans(min_index:Im_rows:end,1),...
        US_Images_Trans(min_index:Im_rows:end,2),...
        US_Images_Trans(min_index:Im_rows:end,3),5,'r','filled')
    title('3D Plane Visualization - Translation only')
    xlabel('X axis')
    ylabel('Y axis')
    zlabel('Z axis')
end

%% Saving the output file
if save_data
    filename = strcat(pwd,'\2019-07-10T11-20-44_OnlyTransForce_12.mat');
    tic;
    save(filename,'US_Images_Trans','-v7.3')
    telapsed = round(toc);
    fprintf('Took %d seconds to save transformed points.\n\n',telapsed)
end

%% Looking at all unique (non zero) points
% % Finding all intensity values = 0
% unique_vals = US_Images_Trans(US_Images_Trans(:,4) ~= 0,:);
% 
% % Plotting unique values
% num = 50;
% figure('units','normalized','outerposition',[0 0 1 1]);
% scatter3(unique_vals(1:num:end,1),unique_vals(1:num:end,2),...
%     unique_vals(1:num:end,3),1,'k','filled')
% title('3D Plane Visualization')
% xlabel('X axis')
% ylabel('Y axis')
% zlabel('Z axis')


