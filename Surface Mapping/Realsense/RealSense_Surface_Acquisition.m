clearvars; clc; close all;

% Make Pipeline object to manage streaming
pipe = realsense.pipeline();
marker_size = 3;

pointcloud = realsense.pointcloud();

% Start streaming on an arbitrary camera with default settings
profile = pipe.start();

% figure('visible','on');
% hold on;
figure('units','normalized','outerposition',[0 0 1 1])

% Creating structure for sample data
sample = struct('depthFrameData',[]);

% Main loop
frames = 25; % Indicate how many frames to catch for one image
for i = 1:frames+1
    
    % Obtain frames from a streaming device
    fs = pipe.wait_for_frames();
    
    % Select depth frame
    depth = fs.get_depth_frame();
    %color = fs.get_color_frame();
    
    % Produce pointcloud
    if (depth.logical())% && color.logical())
        
        %pointcloud.map_to(color);
        points = pointcloud.calculate(depth);
        
        % Adjust frame CS to matlab CS
        vertices = points.get_vertices();
        X = vertices(:,1,1);
        Y = vertices(:,2,1);
        Z = vertices(:,3,1);
        
        
        scatter3(X,Z,-Y,marker_size,'filled','k')
        grid on
        hold off;
        view([45 30]);
        
        xlim([-0.5 0.5])
        ylim([0.3 1])
        zlim([-0.5 0.5])
        
        xlabel('X');
        ylabel('Z');
        zlabel('Y');
        
        pause(0.01);
        
        if i > 1
            X_realsense(:,:,i-1) = [X(:) Y(:) Z(:)];
            
            counter = 1;
            for j = 1:length(X)
                if X(j) && Y(j) && Z(j)
                    %                     fprintf('The values of X, Y, and Z are %2.2f, %2.2f, and %2.2f\n',...
                    %                     X(j),Y(j),Z(j))
                    if -0.3 < X(j) && X(j) < 0.32 && ...
                            0.83 < Y(j) && Y(j) < 0.86 && ...
                            0.7 < Z(j) && Z(j) < 0.95
                        X_realsense(counter,:,i) = [X(j) Y(j)];
                        fprintf('The values of X, Y, and Z are %2.2f, %2.2f, and %2.2f\n',...
                            X(j),Y(j),Z(j))
                        counter = counter + 1;
                    end
                end
            end
            % Saves to structure after all frames are collected
            if i == frames + 1
                mean_vertices = mean(X_realsense,3);
                scatter3(mean_vertices(:,1),mean_vertices(:,3),...
                    -mean_vertices(:,2),marker_size,'filled','k')
                grid on
                hold off;
                view([45 30]);
                axis square
                
                xlim([-0.5 0.5])
                ylim([0.3 1])
                zlim([-0.5 0.5])
                
                xlabel('X');
                ylabel('Z');
                zlabel('Y');
            end
        end
    end
    % pcshow(vertices); Toolbox required
end

% Stop streaming
pipe.stop();